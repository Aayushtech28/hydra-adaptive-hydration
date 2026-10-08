import '../../domain/insights/insights.dart';
import '../../l10n/gen/app_localizations.dart';

/// Localized sentence for a structured [Insight]. Parameters come from the
/// insight's own evidence — nothing is invented here.
String insightText(AppLocalizations l, Insight i) {
  String p(String k) => '${i.params[k]}';
  return switch (i.type) {
    InsightType.noData => l.insightNoData,
    InsightType.firstDay => l.insightFirstDay,
    InsightType.earlyDays => l.insightEarlyDays(p('days')),
    InsightType.morningStrength => l.insightMorningStrength(p('percent')),
    InsightType.afternoonDrift => l.insightAfternoonDrift(p('percent')),
    InsightType.eveningDrift => l.insightEveningDrift(p('percent')),
    InsightType.earlyFirstDrink => l.insightEarlyFirstDrink(p('minutes')),
    InsightType.weekdayStable => l.insightWeekdayStable,
    InsightType.weekendVariance => l.insightWeekendVariance(
      p('weekday'),
      p('weekend'),
    ),
    InsightType.reminderResponse => l.insightReminderResponse(
      p('percent'),
      p('count'),
    ),
    InsightType.routineImprovement => l.insightRoutineImprovement(p('points')),
    InsightType.recoveryAfterMiss => l.insightRecovery,
  };
}
