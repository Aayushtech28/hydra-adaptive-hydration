import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';



import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../application/reminder_coordinator.dart';
import '../../core/config/feature_flags.dart';
import '../../core/time/hydra_time.dart';
import '../../core/units/formatters.dart';
import '../../domain/hre/response_patterns.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/notifications/notification_service.dart';
import '../common/pro_gate.dart';
import '../common/widgets.dart';
import 'schedule_screen.dart' show StylePicker;

final _quietSuggestionProvider = FutureProvider<List<TimeSpan>>((ref) async {
  ref.watch(revisionProvider);
  final core = ref.watch(coreProvider);
  final events = await core.reminders.recentResolved(limit: 200);
  final zone = await core.timezoneName();
  final loc = locationFor(zone);
  final samples = [
    for (final e in events)
      ReminderSample(
        e.localDate,
        minuteOfDayOf(tzFrom(e.scheduledAt, loc)),
        e.outcome,
      ),
  ];
  final p = await core.profiles.get();
  final rs = await core.routines.getAll();
  final existing = <TimeSpan>[
    for (final r in rs) ...r.quietSpans,
  ];
  if (p == null) return const [];
  return ResponsePatternAnalyzer.suggestQuietSpans(samples, existing: existing);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    final perm = ref.watch(notificationPermissionProvider).value;
    final isPro = ref.watch(isProProvider);
    final flags = ref.watch(servicesProvider).flags;
    final locale = p.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final suggestions = ref.watch(_quietSuggestionProvider).value ?? const [];

    String tone(NotificationTone t) => switch (t) {
          NotificationTone.auto => l.toneAuto,
          NotificationTone.gentle => l.toneGentle,
          NotificationTone.neutral => l.toneNeutral,
          NotificationTone.encouraging => l.toneEncouraging,
          NotificationTone.progress => l.toneProgress,
        };

    return Scaffold(
      appBar: AppBar(title: Text(l.remindersTitle)),
      body: SafeArea(
        child: PageBody(children: [
          if (perm != null && perm != NotificationPermission.granted)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: ErrorNotice(
                title: l.permNudgeTitle,
                message: l.remindersPermissionOff,
                primaryLabel: l.remindersPermissionAllow,
                onPrimary: () async {
                  await ref.read(servicesProvider).notifications.requestPermission();
                  await ref.read(coreProvider).reschedule(reason: 'permission');
                  ref.read(revisionProvider.notifier).bump();
                },
              ),
            ),
          TileGroup(children: [
            SwitchListTile(
              title: Text(l.remindersToggle),
              subtitle: Text(l.remindersToggleBody),
              value: p.remindersEnabled,
              onChanged: (v) => ref.read(coreProvider).updateProfile((x) => x.copyWith(remindersEnabled: v)),
            ),
          ]),
          SectionHeader(l.remindersStyle),
          const StylePicker(),
          const SizedBox(height: Gap.sm),
          Text(l.remindersFatigueNote, style: context.text.bodySmall),
          SectionHeader(l.remindersTone),
          TileGroup(children: [
            for (final t in NotificationTone.values)
              RadioListTile<NotificationTone>(
                value: t,
                // ignore: deprecated_member_use
                groupValue: p.tone,
                // ignore: deprecated_member_use
                onChanged: (v) => ref.read(coreProvider).updateProfile((x) => x.copyWith(tone: v)),
                title: Text(tone(t)),
                subtitle: t == NotificationTone.auto ? Text(l.toneAutoBody) : null,
              ),
          ]),
          if (flags.isOn(Flag.smartQuietHours)) ...[
            SectionHeader(l.remindersQuietHours),
            Text(l.remindersQuietBody, style: context.text.bodySmall),
            const SizedBox(height: Gap.sm),
            if (!isPro)
              ProUpsell(message: l.remindersQuietBody)
            else if (suggestions.isEmpty)
              HCard(child: Text(l.remindersQuietNone, style: context.text.bodyMedium))
            else
              for (final s in suggestions)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                  child: HCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        l.remindersQuietSuggestion(
                          Formatters.minuteOfDay(s.startMinute, locale, use24h: use24),
                          Formatters.minuteOfDay(s.endMinute, locale, use24h: use24),
                        ),
                        style: context.text.bodyLarge,
                      ),
                      const SizedBox(height: Gap.sm),
                      FilledButton(
                        onPressed: () async {
                          final core = ref.read(coreProvider);
                          final rs = await core.routines.getAll();
                          // Add to the routine in use (or create a default one).
                          Routine target;
                          final active = rs.where((r) => r.id == p.activeRoutineId).firstOrNull;
                          if (active != null) {
                            target = active;
                          } else {
                            target = core.routines.blank(
                              name: l.youRoutines,
                              kind: RoutineKind.custom,
                              wake: p.wakeMinute,
                              sleep: p.sleepMinute,
                              weekdays: {1, 2, 3, 4, 5, 6, 7},
                              mode: p.mode,
                            );
                          }
                          await core.routines.upsert(target.copyWith(quietSpans: [...target.quietSpans, s]));
                          await core.reschedule(reason: 'quiet_hours');
                          ref.read(revisionProvider.notifier).bump();
                        },
                        child: Text(l.remindersQuietAccept),
                      ),
                    ]),
                  ),
                ),
          ],
          const SizedBox(height: Gap.xl),
          TileGroup(children: [
            HTile(leading: Icons.build_circle_outlined, title: l.remindersHelp, onTap: () => context.push('/you/notifications/help')),
          ]),
        ]),
      ),
    );
  }
}

class NotificationHelpScreen extends ConsumerStatefulWidget {
  const NotificationHelpScreen({super.key});
  @override
  ConsumerState<NotificationHelpScreen> createState() => _NotificationHelpScreenState();
}

class _NotificationHelpScreenState extends ConsumerState<NotificationHelpScreen> {
  int? _pending;

  @override
  void initState() {
    super.initState();
    ref.read(servicesProvider).notifications.pendingCount().then((n) {
      if (mounted) setState(() => _pending = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final dash = ref.watch(dashboardProvider).value;
    final perm = ref.watch(notificationPermissionProvider).value;
    final p = ref.watch(profileProvider).value!;
    final locale = p.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);

    Widget check(bool ok, String title, {String? sub, VoidCallback? fix}) => ListTile(
          leading: Text(ok ? '✓' : '!', style: context.text.titleLarge?.copyWith(color: ok ? t.good : t.attention)),
          title: Text(title),
          subtitle: sub == null ? null : Text(sub),
          trailing: ok || fix == null ? null : TextButton(onPressed: fix, child: Text(l.notifHelpFix)),
        );

    final next = dash?.decision.nextReminder;
    return Scaffold(
      appBar: AppBar(title: Text(l.notifHelpTitle)),
      body: SafeArea(
        child: PageBody(children: [
          Text(l.notifHelpBody, style: context.text.bodyLarge),
          const SizedBox(height: Gap.lg),
          TileGroup(children: [
            check(perm == NotificationPermission.granted, l.notifHelpPermission, fix: () async {
              await ref.read(servicesProvider).notifications.requestPermission();
              ref.read(revisionProvider.notifier).bump();
            }),
            check(p.remindersEnabled, l.notifHelpRemindersOn,
                fix: () => ref.read(coreProvider).updateProfile((x) => x.copyWith(remindersEnabled: true))),
            check(!(dash?.ctx.paused ?? false), l.notifHelpNotPaused, fix: () async {
              await ref.read(coreProvider).resumeReminders();
              ref.read(revisionProvider.notifier).bump();
            }),
            check(next != null && (_pending ?? 0) > 0, l.notifHelpScheduled,
                sub: next == null ? null : l.notifHelpNextAt(Formatters.time(next, dash!.ctx.location, locale, use24h: use24))),
          ]),
          const SizedBox(height: Gap.lg),
          HCard(child: Text(l.notifHelpBattery, style: context.text.bodyMedium)),
          const SizedBox(height: Gap.sm),
          HCard(child: Text(l.notifHelpFocus, style: context.text.bodyMedium)),
          const SizedBox(height: Gap.xl),
          OutlinedButton(
            onPressed: () async {
              final loc = localizationsFor(p.locale);
              await ref.read(servicesProvider).notifications.showTest(title: loc.notifTitle, body: loc.notifTestBody);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.notifHelpTestSent)));
              }
            },
            child: Text(l.notifHelpTest),
          ),
        ]),
      ),
    );
  }
}
