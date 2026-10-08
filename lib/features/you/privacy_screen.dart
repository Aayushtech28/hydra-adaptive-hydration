import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../app/services.dart';
import '../../app/theme/tokens.dart';
import '../../core/config/app_config.dart';
import '../../data/repositories/misc_repositories.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/notifications/notification_service.dart';
import '../common/widgets.dart';

Future<void> openUrl(BuildContext context, String url) async {
  final l = AppLocalizations.of(context);
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.privacyOpenFailed)));
  }
}

final _privacyStateProvider =
    FutureProvider.autoDispose<
      ({bool analytics, bool hideWidget, bool healthOn})
    >((ref) async {
      ref.watch(revisionProvider);
      final svc = ref.watch(servicesProvider);
      final s = svc.core.settings;
      final stored = await s.getString(SettingKeys.analyticsEnabled);
      return (
        analytics: stored == null
            ? !svc.consent.regionRequiresConsent
            : stored == '1',
        hideWidget: await s.getBool('privacy.widgetHideAmounts'),
        healthOn: await svc.healthSync.enabled,
      );
    });

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  Future<void> _export(
    BuildContext context,
    WidgetRef ref, {
    required bool csv,
  }) async {
    final l = AppLocalizations.of(context);
    final svc = ref.read(servicesProvider);
    try {
      await svc.export.share(csv: csv);
      svc.analytics.log(AnalyticsEvent.dataExported);
    } catch (_) {
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.privacyExportFailed)));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.privacyDeleteConfirmTitle),
        content: Text(l.privacyDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l.privacyDeleteConfirmAction,
              style: TextStyle(color: ctx.hx.attention),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final svc = ref.read(servicesProvider);
    await svc.core.deleteAllData();
    await svc.export.cleanup();
    // Fresh profile → router sends the user back to onboarding.
    await svc.core.bootstrap(locale: AppServices.systemLocaleCode);
    ref.invalidate(dashboardProvider);
    ref.invalidate(statsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.privacyDeleted)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final svc = ref.watch(servicesProvider);
    final st = ref.watch(_privacyStateProvider).value;
    final perm = ref.watch(notificationPermissionProvider).value;
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: SafeArea(
        child: PageBody(
          children: [
            Text(l.privacyIntro, style: context.text.bodyLarge),
            SectionHeader(l.privacyYourData),
            TileGroup(
              children: [
                HTile(
                  leading: Icons.phone_iphone,
                  title: l.privacyHydration,
                  trailing: Text(
                    l.privacyHydrationValue,
                    style: context.text.bodyMedium,
                  ),
                ),
                HTile(
                  leading: Icons.favorite_border,
                  title: l.privacyHealth,
                  trailing: Text(
                    st?.healthOn == true ? l.commonOn : l.commonOff,
                    style: context.text.bodyMedium,
                  ),
                  onTap: () => context.push('/you/health'),
                ),
                HTile(
                  leading: Icons.notifications_none,
                  title: l.privacyNotifications,
                  trailing: Text(
                    perm == NotificationPermission.granted
                        ? l.commonOn
                        : l.commonOff,
                    style: context.text.bodyMedium,
                  ),
                  onTap: () => context.push('/you/notifications'),
                ),
                HTile(
                  leading: Icons.sd_storage_outlined,
                  title: l.privacyStorage,
                  trailing: Text(
                    l.privacyStorageValue,
                    style: context.text.bodyMedium,
                  ),
                ),
                HTile(
                  leading: Icons.campaign_outlined,
                  title: l.privacyAds,
                  subtitle: isPro ? l.privacyPro : l.privacyAdsBody,
                  trailing: Text(
                    isPro ? l.commonOff : l.privacyAdsValue,
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.lg),
            TileGroup(
              children: [
                SwitchListTile(
                  title: Text(l.privacyAnalytics),
                  subtitle: Text(l.privacyAnalyticsBody),
                  value: st?.analytics ?? false,
                  onChanged: (v) async {
                    await svc.setAnalyticsEnabled(v);
                    ref.read(revisionProvider.notifier).bump();
                  },
                ),
                SwitchListTile(
                  title: Text(l.privacyWidgetHide),
                  subtitle: Text(l.privacyWidgetHideBody),
                  value: st?.hideWidget ?? false,
                  onChanged: (v) async {
                    await svc.core.settings.setBool(
                      'privacy.widgetHideAmounts',
                      v,
                    );
                    await svc.core.publishWidget();
                    ref.read(revisionProvider.notifier).bump();
                  },
                ),
              ],
            ),
            SectionHeader(l.privacyExport),
            Text(
              '${l.privacyExportBody}\n${l.privacyExportContents}',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: Gap.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _export(context, ref, csv: true),
                    child: Text(l.privacyExportCsv),
                  ),
                ),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _export(context, ref, csv: false),
                    child: Text(l.privacyExportJson),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
            TileGroup(
              children: [
                if (svc.consent.privacyOptionsRequired)
                  HTile(
                    leading: Icons.tune,
                    title: l.privacyChoices,
                    onTap: svc.consent.showPrivacyOptions,
                  ),
                HTile(
                  leading: Icons.health_and_safety_outlined,
                  title: l.privacyHealthPerms,
                  onTap: () => context.push('/you/health'),
                ),
                HTile(
                  leading: Icons.policy_outlined,
                  title: l.privacyPolicy,
                  onTap: () => openUrl(context, AppConfig.privacyPolicyUrl),
                ),
                HTile(
                  leading: Icons.description_outlined,
                  title: l.privacyTerms,
                  onTap: () => openUrl(context, AppConfig.termsUrl),
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
            HCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.privacyDelete, style: context.text.titleSmall),
                  Text(l.privacyDeleteBody, style: context.text.bodySmall),
                  const SizedBox(height: Gap.md),
                  OutlinedButton(
                    onPressed: () => _delete(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.hx.attention,
                    ),
                    child: Text(l.privacyDelete),
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(l.healthDeleteNote, style: context.text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
