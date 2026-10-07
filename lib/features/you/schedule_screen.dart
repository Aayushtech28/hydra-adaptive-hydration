import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/time/hydra_time.dart';
import '../../core/units/formatters.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/time_wheel.dart';
import '../common/widgets.dart';

/// Shows a modal wheel picker and returns the chosen minute (or null).
Future<int?> pickMinute(BuildContext context, {required int initial, required String title, required String locale}) {
  var value = initial;
  return showModalBottomSheet<int>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, Gap.lg),
        child: StatefulBuilder(
          builder: (ctx, setState) => Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: ctx.text.titleMedium),
            TimeWheel(minute: value, locale: locale, semanticsLabel: title, onChanged: (m) => setState(() => value = m)),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(value),
                child: Text(AppLocalizations.of(ctx).commonDone),
              ),
            ),
          ]),
        ),
      ),
    ),
  );
}

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref, {int? wake, int? sleep, int? wWake, int? wSleep}) async {
    final l = AppLocalizations.of(context);
    final p = ref.read(profileProvider).value!;
    final w = wake ?? p.wakeMinute;
    final s = sleep ?? p.sleepMinute;
    final ww = wWake ?? p.weekendWakeMinute;
    final ws = wSleep ?? p.weekendSleepMinute;
    if (validateWakeSleep(w, s) != null || (p.weekendDifferent && validateWakeSleep(ww, ws) != null)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.scheduleInvalid)));
      return;
    }
    await ref.read(coreProvider).updateProfile((x) => x.copyWith(
          wakeMinute: w,
          sleepMinute: s,
          weekendWakeMinute: ww,
          weekendSleepMinute: ws,
        ));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.scheduleSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    final locale = p.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    String time(int m) => Formatters.minuteOfDay(m, locale, use24h: use24);

    return Scaffold(
      appBar: AppBar(title: Text(l.scheduleTitle)),
      body: SafeArea(
        child: PageBody(children: [
          Text(l.scheduleBody, style: context.text.bodyLarge),
          const SizedBox(height: Gap.lg),
          TileGroup(children: [
            HTile(
              leading: Icons.wb_sunny_outlined,
              title: l.scheduleWake,
              trailing: Text(time(p.wakeMinute), style: context.text.titleMedium),
              onTap: () async {
                final m = await pickMinute(context, initial: p.wakeMinute, title: l.scheduleWake, locale: locale);
                if (m != null && context.mounted) await _save(context, ref, wake: m);
              },
            ),
            HTile(
              leading: Icons.bedtime_outlined,
              title: l.scheduleSleep,
              trailing: Text(time(p.sleepMinute), style: context.text.titleMedium),
              onTap: () async {
                final m = await pickMinute(context, initial: p.sleepMinute, title: l.scheduleSleep, locale: locale);
                if (m != null && context.mounted) await _save(context, ref, sleep: m);
              },
            ),
          ]),
          const SizedBox(height: Gap.lg),
          TileGroup(children: [
            SwitchListTile(
              title: Text(l.scheduleWeekendToggle),
              value: p.weekendDifferent,
              onChanged: (v) => ref.read(coreProvider).updateProfile((x) => x.copyWith(weekendDifferent: v)),
            ),
            if (p.weekendDifferent) ...[
              HTile(
                title: l.scheduleWeekendWake,
                trailing: Text(time(p.weekendWakeMinute), style: context.text.titleMedium),
                onTap: () async {
                  final m = await pickMinute(context, initial: p.weekendWakeMinute, title: l.scheduleWeekendWake, locale: locale);
                  if (m != null && context.mounted) await _save(context, ref, wWake: m);
                },
              ),
              HTile(
                title: l.scheduleWeekendSleep,
                trailing: Text(time(p.weekendSleepMinute), style: context.text.titleMedium),
                onTap: () async {
                  final m = await pickMinute(context, initial: p.weekendSleepMinute, title: l.scheduleWeekendSleep, locale: locale);
                  if (m != null && context.mounted) await _save(context, ref, wSleep: m);
                },
              ),
            ],
          ]),
          const SizedBox(height: Gap.xl),
          Text(l.scheduleEnvironment, style: context.text.titleMedium),
          Text(l.scheduleEnvironmentBody, style: context.text.bodySmall),
          const SizedBox(height: Gap.sm),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l.scheduleEnvironmentNormal)),
              ButtonSegment(value: true, label: Text(l.scheduleEnvironmentHot)),
            ],
            selected: {p.environmentHot},
            onSelectionChanged: (s) => ref.read(coreProvider).updateProfile((x) => x.copyWith(environmentHot: s.first)),
          ),
        ]),
      ),
    );
  }
}

/// Style picker used from the notifications screen.
class StylePicker extends ConsumerWidget {
  const StylePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    Widget row(ReminderMode m, String title, String body) => RadioListTile<ReminderMode>(
          value: m,
          // ignore: deprecated_member_use
          groupValue: p.mode,
          // ignore: deprecated_member_use
          onChanged: (v) => ref.read(coreProvider).updateProfile((x) => x.copyWith(mode: v)),
          title: Text(title),
          subtitle: Text(body),
        );
    return TileGroup(children: [
      row(ReminderMode.gentle, l.styleGentle, l.styleGentleBody),
      row(ReminderMode.balanced, l.styleBalanced, l.styleBalancedBody),
      row(ReminderMode.focus, l.styleFocus, l.styleFocusBody),
    ]);
  }
}
