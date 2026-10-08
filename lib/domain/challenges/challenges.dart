import '../../core/time/local_date.dart';
import '../insights/day_stats.dart';

/// Behavioural challenge kinds. None reward drinking more.
enum ChallengeKind {
  morningMomentum,
  quietConsistency,
  weekdayRhythm,
  afternoonRescue,
  routineBuilder,
}

/// Declarative definition so challenges can be tuned remotely without code.
class ChallengeDefinition {
  const ChallengeDefinition({
    required this.id,
    required this.kind,
    required this.windowDays,
    required this.goal,
    this.threshold = 0.8,
    this.enabled = true,
  });

  final String id;
  final ChallengeKind kind;

  /// Rolling window ending today.
  final int windowDays;

  /// Number of qualifying days required.
  final int goal;

  /// Adherence / ratio threshold used by the kind's qualifier.
  final double threshold;
  final bool enabled;

  static ChallengeDefinition? fromJson(Map<String, Object?> j) {
    try {
      final kind = ChallengeKind.values.firstWhere((k) => k.name == j['kind']);
      final window = (j['windowDays']! as num).toInt();
      final goal = (j['goal']! as num).toInt();
      if (window < 1 || window > 31 || goal < 1 || goal > window) return null;
      final th = (j['threshold'] as num?)?.toDouble() ?? 0.8;
      if (th <= 0 || th > 1) return null;
      return ChallengeDefinition(
        id: j['id']! as String,
        kind: kind,
        windowDays: window,
        goal: goal,
        threshold: th,
        enabled: j['enabled'] as bool? ?? true,
      );
    } catch (_) {
      return null;
    }
  }

  /// Built-in defaults (used when remote content is absent or invalid).
  static const List<ChallengeDefinition> defaults = [
    ChallengeDefinition(
      id: 'morning_momentum',
      kind: ChallengeKind.morningMomentum,
      windowDays: 7,
      goal: 5,
      threshold: 90,
    ),
    ChallengeDefinition(
      id: 'quiet_consistency',
      kind: ChallengeKind.quietConsistency,
      windowDays: 7,
      goal: 4,
      threshold: 0.8,
    ),
    ChallengeDefinition(
      id: 'weekday_rhythm',
      kind: ChallengeKind.weekdayRhythm,
      windowDays: 7,
      goal: 5,
      threshold: 0.75,
    ),
    ChallengeDefinition(
      id: 'afternoon_rescue',
      kind: ChallengeKind.afternoonRescue,
      windowDays: 7,
      goal: 4,
      threshold: 0.8,
    ),
    ChallengeDefinition(
      id: 'routine_builder',
      kind: ChallengeKind.routineBuilder,
      windowDays: 7,
      goal: 5,
      threshold: 30,
    ),
  ];
}

class ChallengeProgress {
  const ChallengeProgress(this.definition, this.progress, this.completed);
  final ChallengeDefinition definition;
  final int progress;
  final bool completed;
  double get fraction => (progress / definition.goal).clamp(0.0, 1.0);
}

abstract final class ChallengeEvaluator {
  /// Evaluates [def] over the trailing window of [days] ending at [today].
  static ChallengeProgress evaluate(
    ChallengeDefinition def,
    List<DayStats> days,
    LocalDate today,
  ) {
    final window = days
        .where(
          (d) =>
              !d.date.isAfter(today) &&
              today.differenceInDays(d.date) < def.windowDays,
        )
        .toList();
    final count = switch (def.kind) {
      // First drink within `threshold` minutes of waking (default 90).
      ChallengeKind.morningMomentum =>
        window
            .where(
              (d) =>
                  d.firstLogDelayMin != null &&
                  d.firstLogDelayMin! <= def.threshold,
            )
            .length,
      // Good adherence with at most 3 reminders sent that day.
      ChallengeKind.quietConsistency =>
        window
            .where(
              (d) =>
                  d.adherence >= def.threshold &&
                  d.remindersSent <= 3 &&
                  d.active,
            )
            .length,
      // Weekdays only.
      ChallengeKind.weekdayRhythm =>
        window
            .where((d) => !d.isWeekend && d.adherence >= def.threshold)
            .length,
      // Afternoon segment hit its plan.
      ChallengeKind.afternoonRescue =>
        window.where((d) => (d.segmentRatio(1) ?? 0) >= def.threshold).length,
      // First drink within ±threshold minutes of the window's median.
      ChallengeKind.routineBuilder => _routineBuilder(window, def.threshold),
    };
    return ChallengeProgress(def, count, count >= def.goal);
  }

  static int _routineBuilder(List<DayStats> window, double tolerance) {
    final delays =
        window.map((d) => d.firstLogDelayMin).whereType<int>().toList()..sort();
    if (delays.length < 3) return 0;
    final median = delays[delays.length ~/ 2];
    return delays.where((d) => (d - median).abs() <= tolerance).length;
  }
}
