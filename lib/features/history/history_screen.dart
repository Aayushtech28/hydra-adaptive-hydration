import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../application/stats_service.dart';
import '../../core/time/local_date.dart';
import '../../core/units/formatters.dart';
import '../../domain/insights/consistency.dart';
import '../../domain/insights/day_stats.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/ads/ad_policy.dart';
import '../ads/ad_slot.dart';
import '../common/widgets.dart';
import '../dashboard/log_sheet.dart';
import 'charts.dart';

enum DayStatus { onPlan, building, attention, noData }

DayStatus dayStatusOf(DayStats s) {
  if (!s.active) return DayStatus.noData;
  if (s.adherence >= kCompletedDayAdherence) return DayStatus.onPlan;
  if (s.adherence >= 0.5) return DayStatus.building;
  return DayStatus.attention;
}

String dayStatusSymbol(DayStatus s) => switch (s) {
  DayStatus.onPlan => '✓',
  DayStatus.building => '→',
  DayStatus.attention => '!',
  DayStatus.noData => '·',
};

String dayStatusLabel(AppLocalizations l, DayStatus s) => switch (s) {
  DayStatus.onPlan => l.historyDayStatusOnPlan,
  DayStatus.building => l.historyDayStatusSteady,
  DayStatus.attention => l.historyDayStatusAttention,
  DayStatus.noData => l.historyDayStatusNoData,
};

Color dayStatusColor(HydraTokens t, DayStatus s) => switch (s) {
  DayStatus.onPlan => t.good,
  DayStatus.building => t.adjust,
  DayStatus.attention => t.attention,
  DayStatus.noData => t.inkMuted,
};

final dayDetailProvider = FutureProvider.family<DayDetail, LocalDate>((
  ref,
  date,
) async {
  ref.watch(entriesChangedProvider);
  ref.watch(profileProvider);
  ref.watch(tickProvider);
  final core = ref.watch(coreProvider);
  return core.stats.detail(date, now: core.clock.now().toUtc());
});

typedef DateRange = (LocalDate, LocalDate);

final rangeStatsProvider = FutureProvider.family<List<DayStats>, DateRange>((
  ref,
  r,
) async {
  ref.watch(entriesChangedProvider);
  ref.watch(profileProvider);
  final core = ref.watch(coreProvider);
  final today = await core.today();
  return core.stats.rangeStats(
    r.$1,
    r.$2,
    today: today,
    now: core.clock.now().toUtc(),
  );
});

enum _View { day, week, month, calendar }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _View _view = _View.day;
  LocalDate? _selected;
  LocalDate? _month; // first day of displayed month

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = ref.watch(todayDateProvider).value;
    final profile = ref.watch(profileProvider).value;
    if (today == null || profile == null)
      return const Scaffold(body: SafeArea(child: SizedBox()));
    final selected = _selected ?? today;
    final month = _month ?? LocalDate(today.year, today.month, 1);

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Gap.screen,
            Gap.sm,
            Gap.screen,
            Gap.xxl,
          ),
          children: [
            SegmentedButton<_View>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: _View.day, label: Text(l.historyDay)),
                ButtonSegment(value: _View.week, label: Text(l.historyWeek)),
                ButtonSegment(value: _View.month, label: Text(l.historyMonth)),
                ButtonSegment(
                  value: _View.calendar,
                  label: Text(l.historyCalendar),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
            const SizedBox(height: Gap.lg),
            switch (_view) {
              _View.day => _DayView(
                date: selected,
                today: today,
                onDate: (d) => setState(() => _selected = d),
              ),
              _View.week => _WeekView(today: today),
              _View.month => _MonthView(today: today),
              _View.calendar => _CalendarView(
                today: today,
                month: month,
                onMonth: (m) => setState(() => _month = m),
                onPick: (d) => setState(() {
                  _selected = d;
                  _view = _View.day;
                }),
              ),
            },
            const AdSlot(placement: AdPlacement.historyBanner),
          ],
        ),
      ),
    );
  }
}

// ---- Day ---------------------------------------------------------------------

class _DayView extends ConsumerWidget {
  const _DayView({
    required this.date,
    required this.today,
    required this.onDate,
  });
  final LocalDate date;
  final LocalDate today;
  final ValueChanged<LocalDate> onDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final p = ref.watch(profileProvider).value!;
    final locale = p.locale ?? 'en';
    final isPro = ref.watch(isProProvider);
    final detail = ref.watch(dayDetailProvider(date)).value;
    final dateLabel = DateFormat.yMMMEd(locale)
        .format(DateTime(date.year, date.month, date.day));
    final isFuture = date.isAfter(today);
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);

    final consumed =
        detail?.entries.fold<int>(0, (s, e) => s + e.volumeMl) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l.historyPrevDay,
              onPressed: () => onDate(date.addDays(-1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      date == today ? l.historyToday : dateLabel,
                      style: context.text.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (date == today)
                    Text(dateLabel, style: context.text.bodySmall),
                ],
              ),
            ),
            IconButton(
              tooltip: l.historyNextDay,
              onPressed: date.isBefore(today)
                  ? () => onDate(date.addDays(1))
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        if (isFuture)
          EmptyState(
            icon: Icons.hourglass_empty,
            title: l.historyFutureTitle,
            message: l.historyFutureBody,
          )
        else if (detail == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(Gap.xl),
              child: SkeletonBox(height: 120),
            ),
          )
        else ...[
          HCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.historyDayTotal(
                    Formatters.volume(consumed, p.unit, locale),
                    Formatters.volume(p.dailyTargetMl, p.unit, locale),
                  ),
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: Gap.md),
                MeterBar(
                  fraction: p.dailyTargetMl == 0
                      ? 0
                      : consumed / p.dailyTargetMl,
                ),
                const SizedBox(height: Gap.lg),
                Text(l.historyPlanVsActual, style: context.text.labelMedium),
                const SizedBox(height: Gap.sm),
                TrajectoryChart(
                  trajectory: detail.trajectory,
                  entries: detail.entries,
                  now: date == today
                      ? ref.read(coreProvider).clock.now().toUtc()
                      : null,
                  semanticsLabel: l.historyChartSemantics(
                    Formatters.volume(
                      detail.trajectory
                          .expectedMlAt(
                            date == today
                                ? ref.read(coreProvider).clock.now()
                                : detail.trajectory.window.sleep,
                          )
                          .round(),
                      p.unit,
                      locale,
                    ),
                    Formatters.volume(consumed, p.unit, locale),
                  ),
                ),
                const SizedBox(height: Gap.sm),
                Row(
                  children: [
                    _Legend(color: t.inkMuted, label: l.historyLegendPlan),
                    const SizedBox(width: Gap.lg),
                    _Legend(color: t.accent, label: l.historyLegendActual),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          if (detail.entries.isEmpty)
            EmptyState(
              icon: Icons.water_drop_outlined,
              title: l.historyNoEntriesTitle,
              message: l.historyNoEntriesBody,
            )
          else
            TileGroup(
              children: [
                for (final e in detail.entries.reversed)
                  HTile(
                    leading: Icons.water_drop_outlined,
                    title: Formatters.volume(e.volumeMl, p.unit, locale),
                    subtitle: Formatters.time(
                      e.timestampUtc,
                      detail.trajectory.window.location,
                      locale,
                      use24h: use24,
                    ),
                    trailing: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: t.inkMuted,
                      semanticLabel: l.commonEdit,
                    ),
                    onTap: () {
                      // Free: today only. Pro: any day.
                      if (date != today && !isPro) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(l.historyEditPro)),
                          );
                        return;
                      }
                      showLogSheet(context, editing: e);
                    },
                  ),
              ],
            ),
          const SizedBox(height: Gap.sm),
          Center(
            child: TextButton.icon(
              onPressed: () => showLogSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l.quickAddCustom),
            ),
          ),
        ],
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 18,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall),
    ],
  );
}

// ---- Week --------------------------------------------------------------------

class _WeekView extends ConsumerWidget {
  const _WeekView({required this.today});
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final p = ref.watch(profileProvider).value!;
    final locale = p.locale ?? 'en';
    final range = ref
        .watch(rangeStatsProvider((today.addDays(-6), today)))
        .value;
    if (range == null) return const SkeletonBox(height: 200);
    if (!range.any((d) => d.active)) {
      return EmptyState(
        icon: Icons.bar_chart,
        title: l.historyWeekEmptyTitle,
        message: l.historyWeekEmptyBody,
      );
    }
    return Column(
      children: [
        HCard(
          child: Column(
            children: [
              for (final d in range)
                _DayBarRow(stats: d, locale: locale, isToday: d.date == today),
            ],
          ),
        ),
        const AdSlot(placement: AdPlacement.historyNative),
        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.only(top: Gap.md),
          child: Text(
            '${l.historyDayStatusOnPlan}: ✓   ${l.historyDayStatusSteady}: →   ${l.historyDayStatusAttention}: !',
            style: TextStyle(color: t.inkMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _DayBarRow extends StatelessWidget {
  const _DayBarRow({
    required this.stats,
    required this.locale,
    required this.isToday,
  });
  final DayStats stats;
  final String locale;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final status = dayStatusOf(stats);
    final pct = (stats.adherence * 100).round();
    final name = DateFormat.E(locale)
        .format(DateTime(stats.date.year, stats.date.month, stats.date.day));
    final color = dayStatusColor(t, status);
    return Semantics(
      label:
          '$name, ${l.historyDayPercentStatus('$pct', dayStatusLabel(l, status))}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                name,
                style: context.text.labelLarge?.copyWith(
                  fontWeight: isToday ? FontWeight.w800 : null,
                ),
              ),
            ),
            Expanded(
              child: MeterBar(
                fraction: stats.active ? stats.adherence : 0,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 64,
              child: Text(
                stats.active ? '${dayStatusSymbol(status)} $pct%' : '·',
                textAlign: TextAlign.end,
                style: context.text.labelLarge?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Month -------------------------------------------------------------------

class _MonthView extends ConsumerWidget {
  const _MonthView({required this.today});
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(profileProvider).value?.locale ?? 'en';
    final range = ref
        .watch(rangeStatsProvider((today.addDays(-34), today)))
        .value;
    if (range == null) return const SkeletonBox(height: 200);
    final active = range.where((d) => d.active).toList();
    if (active.length < 3) {
      return EmptyState(
        icon: Icons.insights_outlined,
        title: l.historyMonthEmptyTitle,
        message: l.historyMonthEmptyBody,
      );
    }
    // five weekly buckets, oldest first
    final weeks = <List<DayStats>>[];
    for (var i = 0; i < 5; i++) {
      weeks.add(range.sublist(i * 7, i * 7 + 7));
    }
    final avg =
        (active.fold<double>(0, (s, d) => s + d.adherence) /
                active.length *
                100)
            .round();
    final complete = range
        .where((d) => d.adherence >= kCompletedDayAdherence)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.historyMonthAverage('$avg'),
                style: context.text.headlineSmall,
              ),
              Text(
                l.historyMonthSummary('${active.length}', '$complete'),
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
        SectionHeader(l.historyMonthTrendTitle),
        HCard(
          child: Column(
            children: [
              for (final w in weeks)
                Builder(
                  builder: (context) {
                    final act = w.where((d) => d.active).toList();
                    final m = act.isEmpty
                        ? 0.0
                        : act.fold<double>(0, (s, d) => s + d.adherence) /
                              act.length;
                    final label = l.historyWeekOf(
                      DateFormat.MMMd(locale).format(
                        DateTime(
                          w.first.date.year,
                          w.first.date.month,
                          w.first.date.day,
                        ),
                      ),
                    );
                    final status = act.isEmpty
                        ? DayStatus.noData
                        : (m >= kCompletedDayAdherence
                              ? DayStatus.onPlan
                              : m >= 0.5
                              ? DayStatus.building
                              : DayStatus.attention);
                    final color = dayStatusColor(context.hx, status);
                    return Semantics(
                      label:
                          '$label, ${act.isEmpty ? l.historyDayStatusNoData : l.historyDayPercentStatus('${(m * 100).round()}', dayStatusLabel(l, status))}',
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 88,
                              child: Text(label, style: context.text.bodySmall),
                            ),
                            Expanded(
                              child: MeterBar(fraction: m, color: color),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 64,
                              child: Text(
                                act.isEmpty
                                    ? '·'
                                    : '${dayStatusSymbol(status)} ${(m * 100).round()}%',
                                textAlign: TextAlign.end,
                                style: context.text.labelLarge?.copyWith(
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const AdSlot(placement: AdPlacement.historyNative),
      ],
    );
  }
}

// ---- Calendar ----------------------------------------------------------------

class _CalendarView extends ConsumerWidget {
  const _CalendarView({
    required this.today,
    required this.month,
    required this.onMonth,
    required this.onPick,
  });
  final LocalDate today;
  final LocalDate month;
  final ValueChanged<LocalDate> onMonth;
  final ValueChanged<LocalDate> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final locale = ref.watch(profileProvider).value?.locale ?? 'en';
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final last = LocalDate(month.year, month.month, daysInMonth);
    final range = ref.watch(rangeStatsProvider((month, last))).value;
    final firstWeekday = month.weekday; // 1..7 Monday-first
    final title = DateFormat.yMMMM(locale)
        .format(DateTime(month.year, month.month));
    final nextMonth = month.month == 12
        ? LocalDate(month.year + 1, 1, 1)
        : LocalDate(month.year, month.month + 1, 1);
    final canNext = nextMonth.isBefore(today.addDays(1));

    final names = [
      l.weekdayShortMon,
      l.weekdayShortTue,
      l.weekdayShortWed,
      l.weekdayShortThu,
      l.weekdayShortFri,
      l.weekdayShortSat,
      l.weekdayShortSun,
    ];
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l.historyPrevDay,
              onPressed: () => onMonth(
                month.month == 1
                    ? LocalDate(month.year - 1, 12, 1)
                    : LocalDate(month.year, month.month - 1, 1),
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: l.historyNextDay,
              onPressed: canNext ? () => onMonth(nextMonth) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: Gap.sm),
        Row(
          children: [
            for (final n in names)
              Expanded(
                child: Center(child: Text(n, style: context.text.labelSmall)),
              ),
          ],
        ),
        const SizedBox(height: Gap.sm),
        if (range == null)
          const SkeletonBox(height: 240)
        else
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
              for (final d in range)
                _CalendarCell(
                  stats: d,
                  today: today,
                  onTap: d.date.isAfter(today) ? null : () => onPick(d.date),
                ),
            ],
          ),
        const SizedBox(height: Gap.md),
        Text(
          '✓ ${l.historyDayStatusOnPlan}    → ${l.historyDayStatusSteady}    ! ${l.historyDayStatusAttention}    · ${l.historyDayStatusNoData}',
          style: context.text.bodySmall?.copyWith(color: t.inkMuted),
        ),
      ],
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.stats, required this.today, this.onTap});
  final DayStats stats;
  final LocalDate today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final future = stats.date.isAfter(today);
    final status = future ? DayStatus.noData : dayStatusOf(stats);
    final color = dayStatusColor(t, status);
    final isToday = stats.date == today;
    final label = l.historyCalendarCell(
      DateFormat.MMMd(Localizations.localeOf(context).toString())
          .format(DateTime(stats.date.year, stats.date.month, stats.date.day)),
      future
          ? ''
          : (stats.active
                ? l.historyDayPercentStatus(
                    '${(stats.adherence * 100).round()}',
                    dayStatusLabel(l, status),
                  )
                : l.historyDayStatusNoData),
    );
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          decoration: BoxDecoration(
            color: future
                ? Colors.transparent
                : color.withValues(
                    alpha: status == DayStatus.noData ? 0.06 : 0.14,
                  ),
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(
              color: isToday ? t.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${stats.date.day}',
                style: context.text.labelMedium?.copyWith(
                  color: future ? t.hairline : t.ink,
                ),
              ),
              Text(
                future ? '' : dayStatusSymbol(status),
                style: context.text.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
