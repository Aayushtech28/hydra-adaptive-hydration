import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/notifications/notification_service.dart';
import '../common/progress_ring.dart';
import '../common/widgets.dart';
import '../insights/insight_text.dart';
import 'log_sheet.dart';
import 'next_reminder_card.dart';
import 'quick_add.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    final profile = ref.watch(profileProvider).value;
    final l = AppLocalizations.of(context);

    // Local data renders immediately; while the first calculation is in
    // flight show calm skeletons instead of a spinner.
    final state = dash.value;
    if (state == null || profile == null) {
      if (dash.hasError) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(Gap.screen),
                child: ErrorNotice(
                  title: l.commonLoadFailed,
                  message: l.dashLogFailedOffline,
                  primaryLabel: l.commonTryAgain,
                  onPrimary: () => ref.invalidate(dashboardProvider),
                ),
              ),
            ),
          ),
        );
      }
      return const Scaffold(body: SafeArea(child: _DashboardSkeleton()));
    }
    return Scaffold(
      body: SafeArea(child: _DashboardBody(state: state)),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Gap.screen),
    child: Column(
      children: [
        SizedBox(height: Gap.xl),
        SkeletonBox(height: 28, width: 180),
        SizedBox(height: Gap.xl),
        SkeletonBox(height: 240, width: 240, radius: 120),
      ],
    ),
  );
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.state});
  final DashboardState state;

  String _greeting(AppLocalizations l, DateTime local) {
    final h = local.hour;
    if (h >= 5 && h < 12) return l.dashGreetMorning;
    if (h >= 12 && h < 17) return l.dashGreetAfternoon;
    if (h >= 17 && h < 22) return l.dashGreetEvening;
    return l.dashGreetNight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final p = state.ctx.profile;
    final locale = p.locale ?? 'en';
    final snap = state.snapshot;
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final pulse = ref.watch(logPulseProvider);
    final stats = ref.watch(statsProvider).value;
    final insight = stats?.dailyInsight;
    final firstDayEmpty =
        state.ctx.input.historyDays <= 1 && state.ctx.entries.isEmpty;
    final chip = paceChipFor(l, snap, firstDayEmpty: firstDayEmpty);

    final consumed = Formatters.volumeValue(
      state.ctx.consumedMl,
      p.unit,
      locale,
    );
    final target = Formatters.volume(p.dailyTargetMl, p.unit, locale);
    final percent = (snap.percent * 100).round();

    String? finishLine;
    if (firstDayEmpty) {
      finishLine = l.paceFirstDayBody;
    } else if (snap.goalReached) {
      finishLine = l.paceGoalReachedBody;
    } else if (snap.beforeWake) {
      finishLine = null;
    } else if (snap.state == PaceState.dayClosing) {
      finishLine = l.paceClosingBody;
    } else if (snap.finishBeyondWindow) {
      finishLine = l.paceFinishLater;
    } else if (snap.estimatedFinish != null) {
      finishLine = l.paceFinishBy(
        Formatters.time(
          snap.estimatedFinish!,
          state.ctx.location,
          locale,
          use24h: use24,
        ),
      );
    }
    final spread =
        (!snap.goalReached &&
            !firstDayEmpty &&
            snap.suggestedPerCheckInMl != null &&
            (snap.state == PaceState.slightlyBehind ||
                snap.state == PaceState.significantlyBehind))
        ? l.paceSpreadBody(
            Formatters.volume(snap.suggestedPerCheckInMl!, p.unit, locale),
          )
        : null;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(coreProvider).onResume();
        ref.invalidate(dashboardProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.screen,
          Gap.lg,
          Gap.screen,
          Gap.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(
              _greeting(l, state.ctx.now.toLocal()),
              style: context.text.headlineMedium,
            ),
          ),
          Text(
            l.dashToday,
            style: context.text.bodyMedium?.copyWith(color: t.inkMuted),
          ),
          const SizedBox(height: Gap.lg),
          Center(
            child: LayoutBuilder(
              builder: (context, c) {
                final size = c.maxWidth.clamp(200.0, 280.0);
                return ProgressRing(
                  size: size,
                  fraction: snap.percent,
                  pulse: pulse,
                  centerTop: '$percent%',
                  centerBottom: l.dashConsumedOfTarget(consumed, target),
                  semanticsLabel: l.dashProgressSemantics(
                    '$percent',
                    Formatters.volume(state.ctx.consumedMl, p.unit, locale),
                    target,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Gap.lg),
          Center(
            child: StatusChip(kind: chip.kind, label: chip.label),
          ),
          if (finishLine != null) ...[
            const SizedBox(height: Gap.sm),
            Text(
              finishLine,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: t.inkMuted),
            ),
          ],
          if (spread != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                spread,
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
            ),
          const SizedBox(height: Gap.xl),
          ..._banner(context, ref, l),
          NextReminderCard(state: state),
          const SizedBox(height: Gap.xl),
          QuickAddRow(amounts: _quickAdds(ref), vessels: state.vessels),
          const SizedBox(height: Gap.xl),
          _Timeline(entries: state.ctx.entries, profile: p, ctx: state),
          if (insight != null) ...[
            const SizedBox(height: Gap.xl),
            HCard(
              color: t.accentSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.insightCardTitle,
                    style: context.text.labelMedium?.copyWith(color: t.accent),
                  ),
                  const SizedBox(height: 4),
                  Text(insightText(l, insight), style: context.text.bodyLarge),
                ],
              ),
            ),
          ],
          const SizedBox(height: Gap.lg),
          Text(l.disclaimerShort, style: context.text.bodySmall),
        ],
      ),
    );
  }

  List<int> _quickAdds(WidgetRef ref) => state.ctx.today.quickAddsMl;

  /// At most one banner at a time keeps the dashboard calm.
  List<Widget> _banner(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) {
    final core = ref.read(coreProvider);
    Widget wrap(Widget w) => Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: w,
    );

    if (state.timezoneChangedTo != null) {
      final zone = state.timezoneChangedTo!;
      return [
        wrap(
          ErrorNotice(
            title: l.tzChangedTitle,
            message: l.tzChangedBody(zone),
            primaryLabel: l.tzChangedAdjust,
            onPrimary: () async {
              await core.acceptTimezone(zone);
              ref.invalidate(dashboardProvider);
            },
          ),
        ),
      ];
    }
    final fatigue = state.ctx.input.fatigue;
    if (fatigue.suggestFewerReminders) {
      return [
        wrap(
          ErrorNotice(
            title: l.fatigueTitle,
            message: l.fatigueBody,
            primaryLabel: l.fatigueAccept,
            onPrimary: () async {
              await core.acceptFewerReminders();
              ref.invalidate(dashboardProvider);
            },
            secondaryLabel: l.fatigueDecline,
            onSecondary: () async {
              await core.declineFewerReminders();
              ref.invalidate(dashboardProvider);
            },
          ),
        ),
      ];
    }
    if (state.permission != NotificationPermission.granted &&
        state.ctx.profile.remindersEnabled &&
        state.ctx.entries.length >= 2) {
      return [
        wrap(
          ErrorNotice(
            title: l.permNudgeTitle,
            message: l.permNudgeBody,
            primaryLabel: l.permNudgeAction,
            onPrimary: () async {
              await ref
                  .read(servicesProvider)
                  .notifications
                  .requestPermission();
              await core.reschedule(reason: 'permission');
              ref.read(revisionProvider.notifier).bump();
            },
          ),
        ),
      ];
    }
    return const [];
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline({
    required this.entries,
    required this.profile,
    required this.ctx,
  });
  final List<HydrationEntry> entries;
  final UserProfile profile;
  final DashboardState ctx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final locale = profile.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l.timelineTitle, style: context.text.titleMedium),
        ),
        const SizedBox(height: Gap.sm),
        if (entries.isEmpty)
          HCard(
            child: EmptyState(
              compact: true,
              icon: Icons.water_drop_outlined,
              title: l.timelineEmptyTitle,
              message: l.timelineEmptyBody,
            ),
          )
        else
          TileGroup(
            children: [
              for (final e in entries.reversed)
                Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
                    color: t.attention.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.delete_outline,
                      color: t.attention,
                      semanticLabel: l.a11yDeleteEntry,
                    ),
                  ),
                  onDismissed: (_) {
                    final core = ref.read(coreProvider);
                    core.deleteEntry(e.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(l.entryDeleted),
                          action: SnackBarAction(
                            label: l.commonUndo,
                            onPressed: () => core.restoreEntry(e),
                          ),
                        ),
                      );
                  },
                  child: HTile(
                    leading: Icons.water_drop_outlined,
                    title: Formatters.volume(e.volumeMl, profile.unit, locale),
                    subtitle: Formatters.time(
                      e.timestampUtc,
                      ctx.ctx.location,
                      locale,
                      use24h: use24,
                    ),
                    trailing: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: t.inkMuted,
                      semanticLabel: l.commonEdit,
                    ),
                    onTap: () => showLogSheet(context, editing: e),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
