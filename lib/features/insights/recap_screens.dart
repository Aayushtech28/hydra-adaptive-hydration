import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../domain/insights/recaps.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/ads/ad_policy.dart';
import '../../services/analytics/analytics_service.dart';
import '../common/share_image.dart';
import '../common/widgets.dart';
import 'l10n_helpers.dart';

enum _Item {
  consistency,
  strongestDay,
  bestWindow,
  opportunity,
  completion,
  response,
  trend,
  reminders,
}

class WeeklyRecapScreen extends ConsumerStatefulWidget {
  const WeeklyRecapScreen({super.key});
  @override
  ConsumerState<WeeklyRecapScreen> createState() => _WeeklyRecapScreenState();
}

class _WeeklyRecapScreenState extends ConsumerState<WeeklyRecapScreen> {
  final _key = GlobalKey();
  final Set<_Item> _shown = {..._Item.values};
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final b = ref.watch(statsProvider).value;
    final locale = ref.watch(profileProvider).value?.locale ?? 'en';
    final w = b?.weekly;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.recapWeeklyTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: w == null
            ? EmptyState(
                icon: Icons.calendar_view_week_outlined,
                title: l.recapNeedMoreTitle,
                message: l.recapNeedMoreBody,
              )
            : ListView(
                padding: const EdgeInsets.all(Gap.screen),
                children: [
                  RepaintBoundary(
                    key: _key,
                    child: _RecapCard(
                      title: l.recapWeeklyTitle,
                      rows: [
                        if (_shown.contains(_Item.consistency))
                          (l.recapConsistency, '${w.consistency}%'),
                        if (_shown.contains(_Item.strongestDay) &&
                            w.strongestDay != null)
                          (
                            l.recapStrongestDay,
                            DateFormat.EEEE(locale).format(
                              DateTime(
                                w.strongestDay!.year,
                                w.strongestDay!.month,
                                w.strongestDay!.day,
                              ),
                            ),
                          ),
                        if (_shown.contains(_Item.bestWindow) &&
                            w.strongestSegment != null)
                          (
                            l.recapBestWindow,
                            segmentName(l, w.strongestSegment!),
                          ),
                        if (_shown.contains(_Item.opportunity) &&
                            w.opportunitySegment != null)
                          (
                            l.recapOpportunity,
                            segmentName(l, w.opportunitySegment!),
                          ),
                        if (_shown.contains(_Item.completion))
                          (
                            l.recapCompletion,
                            l.recapCompletionValue(
                              '${w.planCompletionDays}',
                              '${w.eligibleDays}',
                            ),
                          ),
                        if (_shown.contains(_Item.response) &&
                            w.responsePercent != null)
                          (l.recapResponse, '${w.responsePercent}%'),
                        if (_shown.contains(_Item.trend) &&
                            w.trendPoints != null)
                          (
                            l.recapTrend,
                            w.trendPoints! > 0
                                ? '↑ ${l.recapTrendUp('${w.trendPoints}')}'
                                : w.trendPoints! < 0
                                ? '↓ ${l.recapTrendDown('${-w.trendPoints!}')}'
                                : l.recapTrendFlat,
                          ),
                        if (_shown.contains(_Item.reminders) &&
                            w.remindersTrendPercent != null)
                          (
                            l.recapReminders,
                            w.remindersTrendPercent! <= 0
                                ? l.recapRemindersFewer(
                                    '${-w.remindersTrendPercent!}',
                                  )
                                : l.recapRemindersMore(
                                    '${w.remindersTrendPercent}',
                                  ),
                          ),
                      ],
                      footer: (w.trendPoints ?? 0) > 2
                          ? l.recapEncourageUp
                          : (w.trendPoints ?? 0) < -5
                          ? l.recapEncourageDown
                          : l.recapEncourageSteady,
                    ),
                  ),
                  SectionHeader(l.recapShareChoose),
                  Text(l.recapShareHint, style: context.text.bodySmall),
                  const SizedBox(height: Gap.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final i in _Item.values)
                        FilterChip(
                          label: Text(_label(l, i)),
                          selected: _shown.contains(i),
                          onSelected: (v) => setState(
                            () => v ? _shown.add(i) : _shown.remove(i),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gap.xl),
                  FilledButton.icon(
                    onPressed: _sharing
                        ? null
                        : () async {
                            setState(() => _sharing = true);
                            final ok = await shareBoundaryAsImage(
                              _key,
                              name: 'hydra-week',
                            );
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l.recapShareFailed)),
                              );
                            }
                            if (mounted) setState(() => _sharing = false);
                          },
                    icon: const Icon(Icons.ios_share),
                    label: Text(l.recapShare),
                  ),
                  const SizedBox(height: Gap.md),
                  Text(
                    l.disclaimerShort,
                    style: context.text.bodySmall?.copyWith(color: t.inkMuted),
                  ),
                ],
              ),
      ),
    );
  }

  String _label(AppLocalizations l, _Item i) => switch (i) {
    _Item.consistency => l.recapConsistency,
    _Item.strongestDay => l.recapStrongestDay,
    _Item.bestWindow => l.recapBestWindow,
    _Item.opportunity => l.recapOpportunity,
    _Item.completion => l.recapCompletion,
    _Item.response => l.recapResponse,
    _Item.trend => l.recapTrend,
    _Item.reminders => l.recapReminders,
  };
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.title,
    required this.rows,
    required this.footer,
  });
  final String title;
  final List<(String, String)> rows;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return Container(
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.waterBottom, t.accent.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'HYDRA',
                style: context.text.labelLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Text(
            title,
            style: context.text.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: Gap.lg),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.$1,
                      style: context.text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Text(
                    r.$2,
                    style: context.text.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Gap.lg),
          Text(
            footer,
            style: context.text.bodyLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class MonthlyRecapScreen extends ConsumerStatefulWidget {
  const MonthlyRecapScreen({super.key});
  @override
  ConsumerState<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends ConsumerState<MonthlyRecapScreen> {
  final _key = GlobalKey();
  bool _unlockedOnce = false;
  bool _busy = false;

  Future<void> _watch() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final svc = ref.read(servicesProvider);
    final earned = await svc.adCoordinator.showRewarded(
      AdPlacement.rewardedRecap,
    );
    if (earned)
      svc.analytics.log(AnalyticsEvent.rewardedCompleted, {
        'placement': 'recap',
      });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _unlockedOnce = earned;
    });
    if (!earned) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.recapMonthlyAdFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = ref.watch(statsProvider).value;
    final isPro = ref.watch(isProProvider);
    final m = b?.monthly;
    final unlocked = isPro || _unlockedOnce;
    final p = ref.watch(profileProvider).value;
    final locale = p?.locale ?? 'en';
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recapMonthlyTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: m == null || b == null
            ? EmptyState(
                icon: Icons.calendar_month_outlined,
                title: l.recapNeedMoreTitle,
                message: l.recapNeedMoreBody,
              )
            : ListView(
                padding: const EdgeInsets.all(Gap.screen),
                children: [
                  if (!unlocked) ...[
                    HCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.recapMonthlyLocked,
                            style: context.text.titleMedium,
                          ),
                          const SizedBox(height: Gap.md),
                          FilledButton(
                            onPressed: () => context.push('/pro'),
                            child: Text(l.recapMonthlyUnlock),
                          ),
                          const SizedBox(height: Gap.sm),
                          OutlinedButton(
                            onPressed: _busy ? null : _watch,
                            child: Text(l.recapMonthlyWatch),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    RepaintBoundary(
                      key: _key,
                      child: _RecapCard(
                        title: DateFormat.yMMMM(locale).format(DateTime.now()),
                        rows: [
                          (l.recapConsistency, '${m.consistency}%'),
                          (l.recapMonthlyActive, '${m.activeDays}'),
                          (
                            l.recapCompletion,
                            l.recapCompletionValue(
                              '${m.planCompletionDays}',
                              '${m.eligibleDays}',
                            ),
                          ),
                          if (m.bestRoutine != null)
                            (
                              l.recapMonthlyBestRoutine,
                              routineKindName(l, m.bestRoutine!),
                            ),
                          if (m.favoriteVesselName != null &&
                              m.favoriteVesselMl != null &&
                              p != null)
                            (
                              l.recapMonthlyFavoriteVessel,
                              '${m.favoriteVesselName} · ${Formatters.volume(m.favoriteVesselMl!, p.unit, locale)}',
                            ),
                          if (m.responsePercent != null)
                            (l.recapResponse, '${m.responsePercent}%'),
                          if (b.momentum.sufficient)
                            (l.recapMonthlyMomentum, '${b.momentum.score}'),
                          (l.recapMonthlyHabit, stageName(l, b.habit.stage)),
                          if (m.mostImprovedSegment != null)
                            (
                              l.recapMonthlyImproved,
                              segmentName(l, m.mostImprovedSegment!),
                            ),
                        ],
                        footer: stageBody(l, b.habit.stage),
                      ),
                    ),
                    const SizedBox(height: Gap.xl),
                    FilledButton.icon(
                      onPressed: () async {
                        final ok = await shareBoundaryAsImage(
                          _key,
                          name: 'hydra-month',
                        );
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.recapShareFailed)),
                          );
                        }
                      },
                      icon: const Icon(Icons.ios_share),
                      label: Text(l.recapShare),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

// ignore: unused_element
typedef _Unused = MonthlyRecap;
