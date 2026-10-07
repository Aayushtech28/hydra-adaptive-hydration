import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/config/feature_flags.dart';
import '../../core/units/formatters.dart';
import '../../domain/hre/types.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/notifications/notification_copy.dart';
import '../common/widgets.dart';

class NextReminderCard extends ConsumerStatefulWidget {
  const NextReminderCard({super.key, required this.state});
  final DashboardState state;
  @override
  ConsumerState<NextReminderCard> createState() => _NextReminderCardState();
}

class _NextReminderCardState extends ConsumerState<NextReminderCard> {
  bool _why = false;

  Future<void> _pause(String choice) async {
    final core = ref.read(coreProvider);
    final l = AppLocalizations.of(context);
    switch (choice) {
      case '15':
        await core.pauseFor(const Duration(minutes: 15));
      case '30':
        await core.pauseFor(const Duration(minutes: 30));
      case '60':
        await core.pauseFor(const Duration(hours: 1));
      case '3pm':
        final loc = widget.state.ctx.location;
        final n = tz.TZDateTime.from(core.clock.now().toUtc(), loc);
        var t = tz.TZDateTime(loc, n.year, n.month, n.day, 15);
        if (!t.isAfter(n)) t = t.add(const Duration(days: 1));
        await core.pauseUntil(t);
      case 'log':
        await core.pauseUntilNextLog();
      case 'resume':
        await core.resumeReminders();
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l.pauseWelcomeBack)));
        }
    }
    ref.read(revisionProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final s = widget.state;
    final d = s.decision;
    final locale = s.ctx.profile.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final flags = ref.watch(servicesProvider).flags;
    final whyOn = flags.isOn(Flag.whyNow);

    String headline;
    String? sub;
    if (!s.ctx.profile.remindersEnabled) {
      headline = l.nextReminderOff;
    } else if (s.ctx.paused && d.nextReminder == null) {
      headline = l.nextReminderPaused;
    } else if (d.nextReminder == null) {
      headline = l.nextReminderNone;
    } else {
      final time = Formatters.time(d.nextReminder!, s.ctx.location, locale, use24h: use24);
      headline = d.deferredToTomorrow ? l.nextReminderTomorrowAt(time) : l.nextReminderAt(time);
    }
    if (s.ctx.paused && d.nextReminder != null) sub = l.nextReminderPaused;

    final last = s.ctx.entries.isEmpty ? null : s.ctx.entries.last.timestampUtc;
    final minutes = last == null ? null : s.ctx.now.difference(last).inMinutes;

    return HCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.notifications_none, size: 20, color: t.accent),
            const SizedBox(width: 8),
            Expanded(child: Text(l.nextReminderTitle, style: context.text.labelMedium)),
            PopupMenuButton<String>(
              tooltip: l.a11yRemindersMenu,
              icon: Icon(Icons.more_horiz, color: t.inkMuted),
              onSelected: _pause,
              itemBuilder: (_) => [
                if (s.ctx.paused) PopupMenuItem(value: 'resume', child: Text(l.nextReminderResume)),
                if (!s.ctx.paused) ...[
                  PopupMenuItem(value: '15', child: Text('${l.nextReminderPause} · ${l.pause15}')),
                  PopupMenuItem(value: '30', child: Text('${l.nextReminderPause} · ${l.pause30}')),
                  PopupMenuItem(value: '60', child: Text('${l.nextReminderPause} · ${l.pause60}')),
                  PopupMenuItem(value: '3pm', child: Text('${l.nextReminderPause} · ${l.pauseUntil3pm}')),
                  PopupMenuItem(value: 'log', child: Text('${l.nextReminderPause} · ${l.pauseUntilLog}')),
                ],
              ],
            ),
          ]),
          Text(headline, style: context.text.headlineSmall),
          if (sub != null) Text(sub, style: context.text.bodySmall),
          if (whyOn) ...[
            const SizedBox(height: Gap.xs),
            Semantics(
              button: true,
              expanded: _why,
              child: InkWell(
                onTap: () => setState(() => _why = !_why),
                borderRadius: BorderRadius.circular(Radii.sm),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: kMinTap - 8),
                  child: Row(children: [
                    Text(_why ? l.dashWhyHide : l.nextReminderWhy,
                        style: context.text.labelLarge?.copyWith(color: t.accent)),
                    Icon(_why ? Icons.expand_less : Icons.expand_more, color: t.accent, size: 20),
                  ]),
                ),
              ),
            ),
            if (_why)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(NotificationCopy.explain(l, d.explanation), style: context.text.bodyMedium),
                  if (minutes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(l.nextReminderLastDrink('$minutes'), style: context.text.bodySmall),
                    ),
                ]),
              ),
          ],
        ],
      ),
    );
  }
}

/// Maps pace state to chip text/kind (symbol + text, never colour alone).
({StatusKind kind, String label}) paceChipFor(AppLocalizations l, PaceSnapshot s) {
  if (s.goalReached) return (kind: StatusKind.good, label: l.paceGoalReached);
  if (s.beforeWake) return (kind: StatusKind.neutral, label: l.paceBeforeWake);
  return switch (s.state) {
    PaceState.ahead => (kind: StatusKind.good, label: l.paceAhead),
    PaceState.onTrack => (kind: StatusKind.good, label: l.paceOnTrack),
    PaceState.slightlyBehind => (kind: StatusKind.adjust, label: l.paceSlightlyBehind),
    PaceState.significantlyBehind => (kind: StatusKind.attention, label: l.paceNeedsAttention),
    PaceState.dayClosing => (kind: StatusKind.adjust, label: l.paceDayClosing),
  };
}
