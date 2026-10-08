import 'dart:convert';

import 'package:flutter/widgets.dart' show Locale;

import '../core/logging/log.dart';
import '../core/units/formatters.dart';
import '../core/util/ids.dart';
import '../data/repositories/hydration_repository.dart';
import '../data/repositories/misc_repositories.dart';
import '../data/repositories/reminder_repository.dart';
import '../domain/hre/types.dart';
import '../domain/models/entities.dart';
import '../domain/models/enums.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/notifications/notification_copy.dart';
import '../services/notifications/notification_service.dart';
import 'plan_service.dart';

/// Resolves a locale code to localized strings without a BuildContext, so the
/// same code runs in the UI isolate and in background notification handlers.
AppLocalizations localizationsFor(String? code) {
  final lang = (code ?? 'en').split(RegExp('[-_]')).first;
  final supported = AppLocalizations.supportedLocales.map(
    (l) => l.languageCode,
  );
  return lookupAppLocalizations(Locale(supported.contains(lang) ? lang : 'en'));
}

/// Turns scheduler decisions into OS notifications + persisted reminder
/// events, and later resolves each event's outcome.
class ReminderCoordinator {
  ReminderCoordinator({
    required this.plans,
    required this.reminders,
    required this.hydration,
    required this.settings,
    required this.notifications,
    required this.localeCode,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PlanService plans;
  final ReminderRepository reminders;
  final HydrationRepository hydration;
  final SettingsRepository settings;
  final NotificationService notifications;
  final String? Function() localeCode;
  final DateTime Function() _now;

  static const int _idBase = 4000;
  static const int _chainSize = 6;

  /// Marks past reminders as logged / ignored. Idempotent.
  Future<void> resolveElapsed(DateTime now) async {
    final pending = await reminders.pendingBefore(now);
    if (pending.isEmpty) return;
    for (final e in pending) {
      final windowEnd = e.scheduledAt.add(
        const Duration(minutes: PlanService.responseWindowMin),
      );
      final logs = await hydration.entriesForDay(e.localDate);
      final responded = logs.any(
        (l) =>
            !l.timestampUtc.isBefore(e.scheduledAt) &&
            !l.timestampUtc.isAfter(windowEnd),
      );
      if (responded) {
        await reminders.resolve(e.id, ReminderOutcome.logged, now);
      } else if (!now.isBefore(windowEnd)) {
        await reminders.resolve(e.id, ReminderOutcome.ignored, windowEnd);
      }
    }
  }

  ActionLabels labelsFor(PlanContext ctx, AppLocalizations l) {
    final qa = ctx.today.quickAddsMl;
    final picks = <int>{
      if (qa.isNotEmpty) qa.first,
      if (qa.length > 1) qa.last,
    }.toList();
    final locale = ctx.profile.locale ?? 'en';
    return ActionLabels(
      logActions: [
        for (final ml in picks)
          (
            ml: ml,
            label: l.notifActionAdd(
              Formatters.volume(ml, ctx.profile.unit, locale),
            ),
          ),
      ],
      snooze: l.notifActionSnooze,
    );
  }

  /// Recomputes the reminder chain and replaces everything scheduled with
  /// the OS. Safe to call repeatedly; failures never propagate.
  /// Returns null when there is no profile yet (fresh install or after the
  /// user deleted all data) — there is nothing to schedule.
  Future<SchedulerSummary?> reschedule({String reason = 'unspecified'}) async {
    final now = _now().toUtc();
    await resolveElapsed(now);
    final PlanContext ctx;
    try {
      ctx = await plans.load(now);
    } on NoProfileException {
      return null;
    }
    final l = localizationsFor(localeCode() ?? ctx.profile.locale);
    final chain = plans.chain(ctx, maxCount: _chainSize);
    final first = chain.isEmpty ? plans.decide(ctx) : chain.first;
    final summary = SchedulerSummary(decision: first, scheduledCount: 0);

    await settings.setJson(SettingKeys.lastDecisionJson, {
      'state': first.state.name,
      'reasons': first.reasons.map((r) => r.name).toList(),
      'explanation': first.explanation.name,
      'adjustment': first.adjustment.name,
      'next': first.nextReminder?.toUtc().millisecondsSinceEpoch,
      'algorithm': first.algorithmVersion,
      'at': now.millisecondsSinceEpoch,
      'why': reason,
    });

    final permission = await notifications.permission();
    if (permission != NotificationPermission.granted ||
        !ctx.profile.remindersEnabled) {
      await reminders.cancelFuturePending(now);
      await notifications.cancelAll();
      return summary;
    }

    final labels = labelsFor(ctx, l);
    final events = <ReminderEvent>[];
    final scheduled = <ScheduledReminder>[];
    for (var i = 0; i < chain.length; i++) {
      final d = chain[i];
      final at = d.nextReminder;
      if (at == null) continue;
      final id = newId();
      final percent = (d.snapshot.percent * 100).round().clamp(0, 100);
      events.add(
        ReminderEvent(
          id: id,
          scheduledAt: at.toUtc(),
          localDate: ctx.date,
          type: d.deferredToTomorrow
              ? ReminderType.firstOfDay
              : (d.reasons.contains(ReasonCode.recovery)
                    ? ReminderType.recovery
                    : ReminderType.adaptive),
          outcome: ReminderOutcome.pending,
          reason: d.reasons.map((r) => r.name).join(','),
          algorithmVersion: d.algorithmVersion,
        ),
      );
      scheduled.add(
        ScheduledReminder(
          id: _idBase + i,
          eventId: id,
          at: at,
          title: l.notifTitle,
          body: NotificationCopy.body(
            l,
            d.copy,
            d.copyVariant,
            percent: percent,
          ),
        ),
      );
    }

    try {
      await reminders.cancelFuturePending(now);
      await reminders.insertScheduled(events);
      await notifications.replaceAll(scheduled, labels: labels);
    } catch (e, st) {
      Log.error('notifications', 'reschedule failed', error: e, stack: st);
    }
    await settings.setTime(SettingKeys.lastScheduledAt, now);
    return SchedulerSummary(decision: first, scheduledCount: scheduled.length);
  }

  /// Records the user's interaction with a specific reminder.
  Future<void> recordInteraction(
    String? eventId,
    ReminderOutcome outcome,
  ) async {
    if (eventId == null) return;
    final e = await reminders.getById(eventId);
    if (e == null) return;
    // Do not overwrite a stronger outcome (e.g. logged) with a weaker one.
    if (e.outcome == ReminderOutcome.logged) return;
    await reminders.resolve(eventId, outcome, _now());
  }

  static String encode(SchedulerSummary s) =>
      jsonEncode({'count': s.scheduledCount});
}

class SchedulerSummary {
  const SchedulerSummary({
    required this.decision,
    required this.scheduledCount,
  });
  final SchedulerDecision decision;
  final int scheduledCount;
}
