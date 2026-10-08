import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../core/util/validation.dart';
import '../../domain/models/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import 'log_sheet.dart';

/// One-tap logging: persist first, then let the ring animate. No modal, no
/// confirmation. Undo is offered for a few seconds.
Future<void> quickLog(
  BuildContext context,
  WidgetRef ref, {
  required int ml,
  Vessel? vessel,
}) async {
  final l = AppLocalizations.of(context);
  final core = ref.read(coreProvider);
  final profile = ref.read(profileProvider).value!;
  final messenger = ScaffoldMessenger.of(context);
  unawaited(HapticFeedback.lightImpact());
  try {
    final r = await core.log(volumeMl: ml, vesselId: vessel?.id);
    ref.read(logPulseProvider.notifier).fire();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l.logged(
              Formatters.volume(ml, profile.unit, profile.locale ?? 'en'),
            ),
          ),
          action: SnackBarAction(
            label: l.commonUndo,
            onPressed: () => core.deleteEntry(r.entry.id),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
  } on ValidationException {
    messenger.showSnackBar(SnackBar(content: Text(l.logFailed)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l.dashLogFailedOffline)));
  }
}

class QuickAddRow extends ConsumerWidget {
  const QuickAddRow({super.key, required this.amounts, required this.vessels});
  final List<int> amounts;
  final List<Vessel> vessels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final p = ref.watch(profileProvider).value!;
    final locale = p.locale ?? 'en';
    final favs = vessels.where((v) => v.isFavorite).toList();
    final shownVessels = (favs.isNotEmpty ? favs : vessels).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l.quickAddTitle, style: context.text.titleMedium),
        ),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            for (var i = 0; i < amounts.length.clamp(0, 3); i++) ...[
              if (i > 0) const SizedBox(width: Gap.sm),
              Expanded(
                child: _AmountButton(
                  label: Formatters.plusVolume(amounts[i], p.unit, locale),
                  semantics: l.a11yLogAmount(
                    Formatters.volume(amounts[i], p.unit, locale),
                  ),
                  onTap: () => quickLog(context, ref, ml: amounts[i]),
                  primary: i == 0,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Gap.sm),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final v in shownVessels)
              Semantics(
                button: true,
                label: l.a11yVesselLog(
                  v.name,
                  Formatters.volume(v.volumeMl, p.unit, locale),
                ),
                excludeSemantics: true,
                child: ActionChip(
                  avatar: Icon(_iconFor(v.icon), size: 18, color: t.accent),
                  label: Text(
                    '${v.name} · ${Formatters.volumeValue(v.volumeMl, p.unit, locale)}',
                  ),
                  onPressed: () =>
                      quickLog(context, ref, ml: v.volumeMl, vessel: v),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ActionChip(
              avatar: Icon(Icons.edit_outlined, size: 18, color: t.accent),
              label: Text(l.quickAddCustom),
              onPressed: () => showLogSheet(context),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ],
        ),
      ],
    );
  }

  static IconData _iconFor(String key) => switch (key) {
    'bottle' || 'bottle_large' => Icons.sports_bar_outlined,
    'mug' => Icons.coffee_outlined,
    'travel' => Icons.flight_takeoff,
    'sun' => Icons.wb_sunny_outlined,
    _ => Icons.local_drink_outlined,
  };
}

class _AmountButton extends StatelessWidget {
  const _AmountButton({
    required this.label,
    required this.semantics,
    required this.onTap,
    required this.primary,
  });
  final String label;
  final String semantics;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: Material(
        color: primary ? t.accent : t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: primary ? t.accent : t.hairline),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    style: context.text.titleMedium?.copyWith(
                      color: primary ? t.onAccent : t.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
