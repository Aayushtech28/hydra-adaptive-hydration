import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../core/units/volume_unit.dart';
import '../../core/util/validation.dart';
import '../../data/repositories/misc_repositories.dart';
import '../../data/repositories/vessel_repository.dart';
import '../../domain/models/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/ads/ad_policy.dart';
import '../../services/analytics/analytics_service.dart';
import '../common/widgets.dart';

const _icons = <String, IconData>{
  'glass': Icons.local_drink_outlined,
  'bottle': Icons.sports_bar_outlined,
  'bottle_large': Icons.sports_bar_outlined,
  'mug': Icons.coffee_outlined,
  'travel': Icons.flight_takeoff,
  'sun': Icons.wb_sunny_outlined,
};

class VesselsScreen extends ConsumerWidget {
  const VesselsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, Vessel? v) async {
    final isPro = ref.read(isProProvider);
    final core = ref.read(coreProvider);
    final vessels = ref.read(vesselsProvider).value ?? const [];
    if (v == null && !isPro) {
      final today = DateTime.now();
      final rewardDate = await core.settings.getString(
        SettingKeys.rewardedExtraVesselDate,
      );
      final extra = rewardDate == '${today.year}-${today.month}-${today.day}'
          ? 1
          : 0;
      if (vessels.length >= VesselRepository.freeLimit + extra) {
        if (!context.mounted) return;
        await _limit(context, ref);
        return;
      }
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _VesselSheet(vessel: v),
    );
  }

  Future<void> _limit(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final svc = ref.read(servicesProvider);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.vesselsTitle),
        content: Text(l.vesselLimit('${VesselRepository.freeLimit}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonClose),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final earned = await svc.adCoordinator.showRewarded(
                AdPlacement.rewardedVessel,
              );
              if (earned) {
                final d = DateTime.now();
                await svc.core.settings.setString(
                  SettingKeys.rewardedExtraVesselDate,
                  '${d.year}-${d.month}-${d.day}',
                );
                svc.analytics.log(AnalyticsEvent.rewardedCompleted, {
                  'placement': 'vessel',
                });
              }
            },
            child: Text(l.vesselLimitWatch),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/pro');
            },
            child: Text(l.healthProCta),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    final vessels = ref.watch(vesselsProvider).value ?? const [];
    final locale = p.locale ?? 'en';
    return Scaffold(
      appBar: AppBar(title: Text(l.vesselsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(l.vesselsAdd),
      ),
      body: SafeArea(
        child: vessels.isEmpty
            ? EmptyState(
                icon: Icons.local_drink_outlined,
                title: l.vesselsEmptyTitle,
                message: l.vesselsEmptyBody,
                action: FilledButton(
                  onPressed: () => _edit(context, ref, null),
                  child: Text(l.vesselsAdd),
                ),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  Gap.screen,
                  Gap.sm,
                  Gap.screen,
                  96,
                ),
                itemCount: vessels.length,
                onReorderItem: (a, b) async {
                  final list = [...vessels];
                  final item = list.removeAt(a);
                  list.insert(b, item);
                  await ref
                      .read(coreProvider)
                      .vessels
                      .reorder(list.map((e) => e.id).toList());
                },
                itemBuilder: (context, i) {
                  final v = vessels[i];
                  return Padding(
                    key: ValueKey(v.id),
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: HCard(
                      onTap: () => _edit(context, ref, v),
                      child: Row(
                        children: [
                          Icon(
                            _icons[v.icon] ?? Icons.local_drink_outlined,
                            color: context.hx.accent,
                          ),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.name, style: context.text.titleSmall),
                                Text(
                                  Formatters.volume(v.volumeMl, p.unit, locale),
                                  style: context.text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (v.isFavorite)
                            Icon(
                              Icons.star,
                              size: 18,
                              color: context.hx.accent,
                              semanticLabel: l.vesselFavorite,
                            ),
                          const SizedBox(width: Gap.sm),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _VesselSheet extends ConsumerStatefulWidget {
  const _VesselSheet({this.vessel});
  final Vessel? vessel;
  @override
  ConsumerState<_VesselSheet> createState() => _VesselSheetState();
}

class _VesselSheetState extends ConsumerState<_VesselSheet> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late String _icon;
  late bool _fav;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider).value!;
    final v = widget.vessel;
    _name = TextEditingController(text: v?.name ?? '');
    _amount = TextEditingController(
      text: v == null
          ? ''
          : p.unit
                .fromMl(v.volumeMl.toDouble())
                .toStringAsFixed(p.unit.displayDecimals)
                .replaceFirst(RegExp(r'\.0+$'), ''),
    );
    _icon = v?.icon ?? 'glass';
    _fav = v?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final p = ref.read(profileProvider).value!;
    final r = validateVolume(parseLocalizedNumber(_amount.text), p.unit);
    if (r is! VolumeOk) {
      setState(() => _error = l.logFailed);
      return;
    }
    final nav = Navigator.of(context);
    final svc = ref.read(servicesProvider);
    try {
      await svc.core.vessels.upsert(
        id: widget.vessel?.id,
        name: _name.text,
        volumeMl: r.ml,
        icon: _icon,
        isFavorite: _fav,
      );
      if (widget.vessel == null)
        svc.analytics.log(AnalyticsEvent.vesselCreated);
      nav.pop();
    } on ValidationException {
      setState(() => _error = l.logFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vessel == null ? l.vesselsAdd : l.commonEdit,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: Gap.lg),
            TextField(
              controller: _name,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: l.vesselName,
                counterText: '',
              ),
            ),
            const SizedBox(height: Gap.md),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l.vesselAmount(p.unit.symbol),
                errorText: _error,
              ),
            ),
            const SizedBox(height: Gap.lg),
            Text(l.vesselIcon, style: context.text.labelMedium),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: 8,
              children: [
                for (final e in _icons.entries)
                  ChoiceChip(
                    label: Icon(e.value, size: 20),
                    selected: _icon == e.key,
                    onSelected: (_) => setState(() => _icon = e.key),
                    tooltip: e.key,
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.vesselFavorite),
              value: _fav,
              onChanged: (v) => setState(() => _fav = v),
            ),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                if (widget.vessel != null)
                  TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.vesselDeleteTitle),
                          content: Text(l.vesselDeleteBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l.commonCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l.commonDelete),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(coreProvider)
                            .vessels
                            .delete(widget.vessel!.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(
                      l.commonDelete,
                      style: TextStyle(color: context.hx.attention),
                    ),
                  ),
                const Spacer(),
                FilledButton(onPressed: _save, child: Text(l.commonSave)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
