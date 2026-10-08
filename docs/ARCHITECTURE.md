# Architecture

```
lib/
  main.dart            entry: local-only boot → ProviderScope → HydraApp (or StartupErrorApp)
  app/                 app.dart (lifecycle, notification actions), router.dart, shell.dart,
                       providers.dart (Riverpod), services.dart (composition root + headless runner), theme/
  application/         HydraCore (use-cases), PlanService, ReminderCoordinator, StatsService,
                       stats_bundle, diagnostics, composition.dart (buildCore)
  domain/              pure Dart: hre/ (scheduler, pace, fatigue, patterns), insights/, challenges/,
                       sync/ (health reconciliation), models/
  data/                Drift schema + repositories (SQLite)
  services/            platform boundaries: notifications, health, ads, purchase, analytics,
                       widgets, export, remote_config, smart_bottle, error_reporter
  features/            screens (presentation only, no business logic)
  core/                units, time (tz-aware), logging (redacting), config, util
  l10n/                ARB + generated AppLocalizations
```

## One pipeline for every mutation
`HydraCore.log/edit/delete/snooze/...`: **validate → persist → recompute → reschedule reminders →
publish widget**. The UI animates *after* `log()` returns. The same `HydraCore` is built by
`buildCore()` in three places: the UI isolate, the background notification isolate
(`hydraBackgroundNotificationHandler`) and the widget tap callback (`hydraWidgetCallback`), via
`runHeadless()`. Reschedules are serialised and coalesced (100 rapid taps ⇒ ≤ 1 in-flight + 1 follow-up).

## Reminders are a chain, not a loop
The OS cannot run our code at fire time, so `HydrationScheduler.planChain` projects up to 6
reminders assuming the user does **not** respond (spacing widens, stops after the policy's
unanswered limit, ends with tomorrow's first reminder). Any user action replaces the chain.
Outcomes (logged/ignored/snoozed) are resolved lazily on the next app interaction — there are no
delivery receipts, so "sent" is inferred. No background timers anywhere.

## Startup & failure behaviour
`AppServices.create()` does local work only (DB, profile, notification plugin). Ads/consent,
purchases, remote config, Firebase and analytics run in `deferredInit()` after the first frame and
are individually guarded (`ErrorReporter.guard`, `runZonedGuarded` for plugin errors).
| Dependency fails | Result |
|---|---|
| Ads / UMP / connectivity | no ads; app unaffected |
| RevenueCat key missing / offline | free tier or last cached entitlement (3-day offline grace) |
| Health unavailable/denied | Health screen explains; local tracking unaffected |
| Notifications denied/unavailable | tracking + pace still work; nudge to enable |
| Remote config | bundled defaults; scheduler is never remotely tunable |
| DB cannot open | `StartupErrorApp` with retry (data untouched) |

## State
Riverpod. Streams from Drift feed `dashboardProvider`/`statsProvider`; a 1-minute foreground
ticker refreshes pace. Heavy history maths is cached per closed day in `daily_summaries`.

## Time
Entries store UTC instant + IANA zone + logical date. The logical day rolls over at 04:00 local
(supports overnight routines). Reminders are computed in the *current* device zone; history is
never rewritten on timezone change.
