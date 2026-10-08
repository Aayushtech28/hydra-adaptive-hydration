import 'dart:math' as math;

import '../../core/time/local_date.dart';
import 'day_stats.dart';

/// A day counts as "good" at or above this adherence.
const double kGoodDayAdherence = 0.75;

/// A day counts as a completed plan day at or above this adherence.
const double kCompletedDayAdherence = 0.85;

class ConsistencyResult {
  const ConsistencyResult({
    required this.score,
    required this.eligibleDays,
    required this.completedDays,
    required this.goodDays,
    required this.sufficient,
  });

  /// 0–100, or null when there is not enough history to say anything.
  final int? score;
  final int eligibleDays;
  final int completedDays;
  final int goodDays;
  final bool sufficient;
}

/// ## Consistency
/// Recency-weighted mean of daily adherence over a trailing window
/// (default 30 days), `weight = 0.5^(ageDays / 14)`. A single missed day
/// therefore dents the score slightly instead of resetting it to zero.
/// Requires [minDays] eligible days. Days before the user started (or today,
/// unless already good) must be excluded by the caller via [eligibleDays].
abstract final class ConsistencyCalculator {
  static const int window = 30;
  static const int minDays = 3;
  static const double halfLifeDays = 14;

  /// [days] are eligible days (any order), each with stats (empty = missed).
  static ConsistencyResult compute(List<DayStats> days, LocalDate asOf) {
    final inWindow = days
        .where(
          (d) =>
              asOf.differenceInDays(d.date) < window && !d.date.isAfter(asOf),
        )
        .toList();
    if (inWindow.length < minDays) {
      return ConsistencyResult(
        score: null,
        eligibleDays: inWindow.length,
        completedDays: 0,
        goodDays: 0,
        sufficient: false,
      );
    }
    var wSum = 0.0, vSum = 0.0;
    var completed = 0, good = 0;
    for (final d in inWindow) {
      final age = asOf.differenceInDays(d.date);
      final w = math.pow(0.5, age / halfLifeDays).toDouble();
      wSum += w;
      vSum += w * d.adherence;
      if (d.adherence >= kCompletedDayAdherence) completed++;
      if (d.adherence >= kGoodDayAdherence) good++;
    }
    return ConsistencyResult(
      score: (100 * vSum / wSum).round().clamp(0, 100),
      eligibleDays: inWindow.length,
      completedDays: completed,
      goodDays: good,
      sufficient: true,
    );
  }
}

class StreakResult {
  const StreakResult({
    required this.current,
    required this.best,
    required this.recoveryTokens,
    required this.recoveryUsedRecently,
  });
  final int current;
  final int best;

  /// Forgiveness tokens currently banked (0–2).
  final int recoveryTokens;

  /// True if the current streak survived a missed day via a token.
  final bool recoveryUsedRecently;
}

/// Streak with recovery: a missed day consumes a banked recovery token
/// instead of resetting; one token is earned per 7 good days (max 2).
abstract final class StreakCalculator {
  /// [days] ordered oldest → newest and contiguous. Today (last element) is
  /// only counted if already good; otherwise ignored (it is still in progress).
  static StreakResult compute(
    List<DayStats> days, {
    bool todayInProgress = true,
  }) {
    var list = days;
    if (todayInProgress &&
        list.isNotEmpty &&
        list.last.adherence < kGoodDayAdherence) {
      list = list.sublist(0, list.length - 1);
    }
    var streak = 0, best = 0, tokens = 0;
    var usedRecently = false;
    for (final d in list) {
      if (d.adherence >= kGoodDayAdherence) {
        streak++;
        if (streak % 7 == 0) tokens = math.min(2, tokens + 1);
        usedRecently = false;
      } else if (tokens > 0 && streak > 0) {
        tokens--;
        usedRecently = true;
      } else {
        streak = 0;
        usedRecently = false;
      }
      best = math.max(best, streak);
    }
    return StreakResult(
      current: streak,
      best: best,
      recoveryTokens: tokens,
      recoveryUsedRecently: usedRecently,
    );
  }
}
