import '../../domain/challenges/challenges.dart';
import '../../domain/insights/momentum.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';

String stageName(AppLocalizations l, HabitStage s) => switch (s) {
  HabitStage.remember => l.stageRemember,
  HabitStage.respond => l.stageRespond,
  HabitStage.predict => l.stagePredict,
  HabitStage.routine => l.stageRoutine,
  HabitStage.automatic => l.stageAutomatic,
};

String stageBody(AppLocalizations l, HabitStage s) => switch (s) {
  HabitStage.remember => l.stageRememberBody,
  HabitStage.respond => l.stageRespondBody,
  HabitStage.predict => l.stagePredictBody,
  HabitStage.routine => l.stageRoutineBody,
  HabitStage.automatic => l.stageAutomaticBody,
};

String tierName(AppLocalizations l, MomentumTier t) => switch (t) {
  MomentumTier.building => l.momentumTierBuilding,
  MomentumTier.steady => l.momentumTierSteady,
  MomentumTier.strong => l.momentumTierStrong,
  MomentumTier.excellent => l.momentumTierExcellent,
};

String componentName(AppLocalizations l, MomentumComponent c) => switch (c) {
  MomentumComponent.consistency => l.momentumComponentConsistency,
  MomentumComponent.stability => l.momentumComponentStability,
  MomentumComponent.response => l.momentumComponentResponse,
  MomentumComponent.timing => l.momentumComponentTiming,
  MomentumComponent.independence => l.momentumComponentIndependence,
};

String challengeTitle(AppLocalizations l, ChallengeKind k) => switch (k) {
  ChallengeKind.morningMomentum => l.challengeMorningMomentumTitle,
  ChallengeKind.quietConsistency => l.challengeQuietConsistencyTitle,
  ChallengeKind.weekdayRhythm => l.challengeWeekdayRhythmTitle,
  ChallengeKind.afternoonRescue => l.challengeAfternoonRescueTitle,
  ChallengeKind.routineBuilder => l.challengeRoutineBuilderTitle,
};

String challengeBody(AppLocalizations l, ChallengeKind k) => switch (k) {
  ChallengeKind.morningMomentum => l.challengeMorningMomentumBody,
  ChallengeKind.quietConsistency => l.challengeQuietConsistencyBody,
  ChallengeKind.weekdayRhythm => l.challengeWeekdayRhythmBody,
  ChallengeKind.afternoonRescue => l.challengeAfternoonRescueBody,
  ChallengeKind.routineBuilder => l.challengeRoutineBuilderBody,
};

String segmentName(AppLocalizations l, int i) =>
    i == 0 ? l.segMorning : (i == 1 ? l.segAfternoon : l.segEvening);

String routineKindName(AppLocalizations l, RoutineKind k) => switch (k) {
  RoutineKind.weekday => l.routineKindWeekday,
  RoutineKind.weekend => l.routineKindWeekend,
  RoutineKind.work => l.routineKindWork,
  RoutineKind.study => l.routineKindStudy,
  RoutineKind.workout => l.routineKindWorkout,
  RoutineKind.travel => l.routineKindTravel,
  RoutineKind.custom => l.routineKindCustom,
};
