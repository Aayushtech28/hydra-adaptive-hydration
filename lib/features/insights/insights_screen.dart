import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../application/stats_bundle.dart';
import '../../core/config/feature_flags.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/ads/ad_policy.dart';
import '../ads/ad_slot.dart';
import '../common/widgets.dart';
import '../history/charts.dart';
import 'insight_text.dart';
import 'l10n_helpers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stats = ref.watch(statsProvider);
    final b = stats.value;
    final advanced = ref.watch(servicesProvider).flags.isOn(Flag.advancedInsights);
    return Scaffold(
      appBar: AppBar(title: Text(l.insightsTitle)),
      body: SafeArea(
        child: b == null
            ? const Padding(padding: EdgeInsets.all(Gap.screen), child: SkeletonBox(height: 160))
            : ListView(
                padding: const EdgeInsets.fromLTRB(Gap.screen, Gap.sm, Gap.screen, Gap.xxl),
                children: [
                  _MomentumCard(b: b),
                  const SizedBox(height: Gap.md),
                  _ConsistencyCard(b: b),
                  const SizedBox(height: Gap.md),
                  _IndependenceCard(b: b),
                  const SizedBox(height: Gap.md),
                  _HabitCard(b: b),
                  if (advanced) ...[
                    SectionHeader(l.insightsPatternsTitle),
                    for (final i in b.insights.take(4))
                      Padding(
                        padding: const EdgeInsets.only(bottom: Gap.sm),
                        child: HCard(child: Text(insightText(l, i), style: context.text.bodyLarge)),
                      ),
                  ],
                  const AdSlot(placement: AdPlacement.insightsNative),
                  SectionHeader(l.recapWeeklyTitle),
                  HCard(
                    onTap: () => context.push('/recap/weekly'),
                    child: Row(children: [
                      Icon(Icons.calendar_view_week_outlined, color: context.hx.accent),
                      const SizedBox(width: Gap.md),
                      Expanded(child: Text(b.weekly == null ? l.recapNeedMoreBody : l.recapWeeklyCta, style: context.text.bodyLarge)),
                      const Icon(Icons.chevron_right),
                    ]),
                  ),
                  const SizedBox(height: Gap.sm),
                  HCard(
                    onTap: () => context.push('/recap/monthly'),
                    child: Row(children: [
                      Icon(Icons.calendar_month_outlined, color: context.hx.accent),
                      const SizedBox(width: Gap.md),
                      Expanded(child: Text(l.recapMonthlyCta, style: context.text.bodyLarge)),
                      const Icon(Icons.chevron_right),
                    ]),
                  ),
                  SectionHeader(l.challengesTitle),
                  Text(l.challengesBody, style: context.text.bodySmall),
                  const SizedBox(height: Gap.sm),
                  if (b.challenges.isEmpty)
                    EmptyState(icon: Icons.flag_outlined, title: l.challengesEmptyTitle, message: l.challengesEmptyBody)
                  else
                    for (final c in b.challenges)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Gap.sm),
                        child: HCard(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(challengeTitle(l, c.definition.kind), style: context.text.titleSmall)),
                              if (c.completed)
                                StatusChip(kind: StatusKind.good, label: l.challengeCompleted)
                              else
                                Text(l.challengeProgress('${c.progress}', '${c.definition.goal}'), style: context.text.labelMedium),
                            ]),
                            const SizedBox(height: 2),
                            Text(challengeBody(l, c.definition.kind), style: context.text.bodySmall),
                            const SizedBox(height: Gap.sm),
                            MeterBar(fraction: c.fraction, height: 8),
                            const SizedBox(height: 4),
                            Text(l.challengeWindow('${c.definition.windowDays}'), style: context.text.labelSmall),
                          ]),
                        ),
                      ),
                ],
              ),
      ),
    );
  }
}

class _MomentumCard extends StatelessWidget {
  const _MomentumCard({required this.b});
  final StatsBundle b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final m = b.momentum;
    if (!m.sufficient) {
      return HCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.momentumTitle, style: context.text.labelMedium),
          const SizedBox(height: 4),
          Text(l.momentumInsufficient, style: context.text.bodyLarge),
        ]),
      );
    }
    final trend = m.trend;
    final trendText = trend == null
        ? null
        : trend > 0
            ? '↑ ${l.momentumTrendUp('$trend')}'
            : trend < 0
                ? '↓ ${l.momentumTrendDown('${-trend}')}'
                : l.momentumTrendFlat;
    return HCard(
      semanticsLabel: '${l.momentumTitle}: ${m.score}, ${tierName(l, m.tier)}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.momentumTitle, style: context.text.labelMedium),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${m.score}', style: context.text.displayMedium),
          const SizedBox(width: Gap.md),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(tierName(l, m.tier), style: context.text.titleMedium?.copyWith(color: t.accent)),
          ),
        ]),
        MeterBar(fraction: (m.score ?? 0) / 100),
        if (trendText != null) ...[
          const SizedBox(height: Gap.sm),
          Text(trendText, style: context.text.bodyMedium),
        ],
        const SizedBox(height: Gap.sm),
        for (final r in m.reasons)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(children: [
              SizedBox(
                width: 36,
                child: Text('${r.deltaPoints >= 0 ? '+' : ''}${r.deltaPoints}',
                    style: context.text.labelLarge?.copyWith(color: r.deltaPoints >= 0 ? t.good : t.attention)),
              ),
              Expanded(child: Text(componentName(l, r.component), style: context.text.bodyMedium)),
            ]),
          ),
        const SizedBox(height: Gap.sm),
        Text(l.momentumDisclaimer, style: context.text.bodySmall),
      ]),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({required this.b});
  final StatsBundle b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final c = b.consistency;
    final s = b.streak;
    return HCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.consistencyTitle, style: context.text.labelMedium),
        if (!c.sufficient)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.consistencyInsufficient, style: context.text.bodyLarge))
        else ...[
          Text('${c.score}%', style: context.text.displayMedium),
          MeterBar(fraction: (c.score ?? 0) / 100),
          const SizedBox(height: Gap.sm),
          Text(l.consistencyBody, style: context.text.bodySmall),
          if ((c.score ?? 0) >= 60)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.consistencyBuilding, style: context.text.bodyMedium)),
        ],
        if (s.current > 0) ...[
          const Divider(height: Gap.xl),
          Row(children: [
            Text(l.streakTitle, style: context.text.labelMedium),
            const Spacer(),
            Text(l.streakDays('${s.current}'), style: context.text.titleMedium),
          ]),
          if (s.best > s.current) Text(l.streakBest('${s.best}'), style: context.text.bodySmall),
          if (s.recoveryUsedRecently)
            Text(l.streakRecoveryUsed, style: context.text.bodyMedium?.copyWith(color: t.good))
          else if (s.recoveryTokens > 0)
            Text(l.streakRecovery, style: context.text.bodySmall),
        ],
      ]),
    );
  }
}

class _IndependenceCard extends StatelessWidget {
  const _IndependenceCard({required this.b});
  final StatsBundle b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final r = b.independence;
    return HCard(
      color: r.celebrate ? t.accentSoft : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.independenceTitle, style: context.text.labelMedium),
        const SizedBox(height: 4),
        if (!r.sufficient)
          Text(l.independenceInsufficient, style: context.text.bodyLarge)
        else if (r.celebrate) ...[
          Text(l.independenceCelebrate('${r.reductionPercent}'), style: context.text.titleMedium),
          const SizedBox(height: 4),
          Text(l.independenceCelebrateBody, style: context.text.bodyMedium),
        ] else
          Text(l.independenceSteady, style: context.text.bodyLarge),
      ]),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.b});
  final StatsBundle b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final h = b.habit;
    return HCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.habitTitle, style: context.text.labelMedium),
        const SizedBox(height: Gap.sm),
        Row(children: [
          for (final s in HabitStage.values)
            Expanded(
              child: Column(children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.index <= h.stage.index ? t.accent : t.surfaceRaised,
                    border: Border.all(color: s == h.stage ? t.accent : t.hairline, width: 2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(stageName(l, s),
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall?.copyWith(
                        color: s == h.stage ? t.ink : t.inkMuted,
                        fontWeight: s == h.stage ? FontWeight.w800 : FontWeight.w500)),
              ]),
            ),
        ]),
        const SizedBox(height: Gap.md),
        Text(stageName(l, h.stage), style: context.text.titleMedium),
        Text(stageBody(l, h.stage), style: context.text.bodyMedium),
        if (h.nextStage != null) ...[
          const SizedBox(height: Gap.sm),
          Text(l.habitNext(stageName(l, h.nextStage!)), style: context.text.bodySmall),
        ],
      ]),
    );
  }
}
