import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/config/feature_flags.dart';
import '../../data/repositories/misc_repositories.dart';
import '../../domain/sync/health_reconciler.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/health/health_service.dart';
import '../../services/health/health_sync_service.dart';
import '../common/pro_gate.dart';
import '../common/widgets.dart';

class _HealthState {
  const _HealthState(
    this.availability,
    this.permission,
    this.enabled,
    this.direction,
    this.lastSync,
  );
  final HealthAvailability availability;
  final HealthPermissionState permission;
  final bool enabled;
  final SyncDirection direction;
  final DateTime? lastSync;
}

final _healthStateProvider = FutureProvider.autoDispose<_HealthState>((
  ref,
) async {
  ref.watch(revisionProvider);
  final svc = ref.watch(servicesProvider);
  return _HealthState(
    await svc.health.availability(),
    await svc.health.permission(),
    await svc.healthSync.enabled,
    await svc.healthSync.direction(),
    await svc.core.settings.getTime(SettingKeys.healthLastSync),
  );
});

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});
  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  SyncReport? _report;
  bool _busy = false;

  Future<void> _sync() async {
    final svc = ref.read(servicesProvider);
    setState(() => _busy = true);
    final r = await svc.healthSync.sync();
    if (r.ok) {
      // Imported entries can land on closed days; invalidate cached stats.
      await svc.core.summaries.invalidateAll();
      await svc.core.reschedule(reason: 'health_sync');
    }
    if (!mounted) return;
    setState(() {
      _report = r;
      _busy = false;
    });
    ref.read(revisionProvider.notifier).bump();
  }

  Future<void> _enable(SyncDirection d) async {
    final svc = ref.read(servicesProvider);
    setState(() => _busy = true);
    final granted = await svc.health.requestPermission();
    if (granted) {
      await svc.healthSync.enable(d);
      svc.analytics.log(AnalyticsEvent.healthSyncEnabled);
      await _sync();
    } else {
      setState(() => _busy = false);
      ref.read(revisionProvider.notifier).bump();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isPro = ref.watch(isProProvider);
    final flagOn = ref.watch(servicesProvider).flags.isOn(Flag.healthSync);
    final st = ref.watch(_healthStateProvider).value;
    final locale = ref.watch(profileProvider).value?.locale ?? 'en';
    final svc = ref.watch(servicesProvider);

    String dirName(SyncDirection d) => switch (d) {
      SyncDirection.twoWay => l.healthDirectionTwoWay,
      SyncDirection.importOnly => l.healthDirectionImport,
      SyncDirection.exportOnly => l.healthDirectionExport,
    };

    Widget body;
    if (!flagOn || !isPro) {
      body = ProUpsell(message: l.healthProBody);
    } else if (st == null) {
      body = const SkeletonBox(height: 120);
    } else if (st.availability == HealthAvailability.unsupported) {
      body = EmptyState(
        icon: Icons.favorite_border,
        title: l.youHealth,
        message: l.healthAvailabilityUnsupported,
      );
    } else if (st.availability == HealthAvailability.notInstalled) {
      body = EmptyState(
        icon: Icons.download_outlined,
        title: l.youHealth,
        message: l.healthAvailabilityMissing,
        action: FilledButton(
          onPressed: svc.health.installProvider,
          child: Text(l.healthInstall),
        ),
      );
    } else if (!st.enabled) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (st.permission == HealthPermissionState.denied)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: ErrorNotice(
                title: l.healthPermissionDenied,
                message: l.healthDeleteNote,
              ),
            ),
          Text(l.healthDirection, style: context.text.titleMedium),
          const SizedBox(height: Gap.sm),
          for (final d in SyncDirection.values)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm),
              child: SizedBox(
                width: double.infinity,
                child: d == SyncDirection.twoWay
                    ? FilledButton(
                        onPressed: _busy ? null : () => _enable(d),
                        child: Text('${l.healthEnable} · ${dirName(d)}'),
                      )
                    : OutlinedButton(
                        onPressed: _busy ? null : () => _enable(d),
                        child: Text(dirName(d)),
                      ),
              ),
            ),
        ],
      );
    } else {
      final last = st.lastSync;
      final r = _report;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r != null && !r.ok)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: ErrorNotice(
                title: l.healthFailedTitle,
                message: l.healthFailedBody,
                primaryLabel: l.commonTryAgain,
                onPrimary: _busy ? null : _sync,
                secondaryLabel: l.healthContinueWithout,
                onSecondary: () async {
                  await svc.healthSync.disable();
                  setState(() => _report = null);
                  ref.read(revisionProvider.notifier).bump();
                },
              ),
            ),
          TileGroup(
            children: [
              HTile(title: l.healthDirection, subtitle: dirName(st.direction)),
              HTile(
                title: last == null
                    ? l.healthNever
                    : l.healthLastSync(
                        DateFormat.yMMMd(locale)
                            .add_jm()
                            .format(last.toLocal()),
                      ),
              ),
            ],
          ),
          if (r != null && r.ok)
            Padding(
              padding: const EdgeInsets.only(top: Gap.sm),
              child: Text(
                l.healthSynced('${r.imported}', '${r.exported}'),
                style: context.text.bodyMedium,
              ),
            ),
          const SizedBox(height: Gap.lg),
          FilledButton(
            onPressed: _busy ? null : _sync,
            child: Text(l.healthSyncNow),
          ),
          const SizedBox(height: Gap.sm),
          TextButton(
            onPressed: () async {
              await svc.healthSync.disable();
              ref.read(revisionProvider.notifier).bump();
            },
            child: Text(l.healthDisable),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.healthTitle)),
      body: SafeArea(
        child: PageBody(
          children: [
            Text(l.healthIntro, style: context.text.bodyLarge),
            const SizedBox(height: Gap.lg),
            body,
            const SizedBox(height: Gap.xl),
            Text(l.healthDuplicateNote, style: context.text.bodySmall),
            const SizedBox(height: Gap.sm),
            Text(l.healthDeleteNote, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
