# HRE_V1 — Hydration Rhythm Engine

Deterministic, explainable, never medical. It spaces reminders; it never changes the user's target
and never asks for a catch-up amount above 500 ml.

## Plan trajectory
Plan window = wake → sleep − wind-down (min(60 min, 15% of window)). With progress `p∈[0,1]`
through it, planned fraction `f(p) = 1.2p − 0.2p²` (gently front-loaded, f(1)=1).
`expected(t) = target · f(p(t))`; `gap = expected − consumed`.

## Pace state
goal reached ⇒ AHEAD · past plan end ⇒ DAY_CLOSING · ≤60 min left and gap>10% ⇒ DAY_CLOSING ·
gap ≤ −5% ⇒ AHEAD · <8% ⇒ ON_TRACK · <20% ⇒ SLIGHTLY_BEHIND · else SIGNIFICANTLY_BEHIND.
Estimated finish = plan end + current lag behind the curve.

## Next reminder
`anchor` = latest of wake / last log / last reminder. `interval = base(mode) × paceMult
(1.5 / 1 / 0.8 / 0.65) × fatigueMult (1 / 1.3 / 1.7) × hot(0.85) × (1 + 0.25·unanswered)`, clamped to
[minGap, 240]. Base/minGap/first-offset/max-unanswered: Gentle 150/90/90/2 · Balanced 105/60/45/3 ·
Focus 75/40/30/4 minutes. Snooze = exact; pause = floor; quiet/workout spans push to their end;
past plan end ⇒ tomorrow's first reminder. Overdue reminders wait ≥10 min (no ping on app open).

## Explainability
Every `SchedulerDecision` has `reasons[]` (PACE_GAP, RECENT_IDLE_PERIOD, SCHEDULED_CHECK, RECOVERY,
QUIET_HOURS_EXIT, FATIGUE, SNOOZED, PAUSED, DAY_CLOSING, GOAL_REACHED, FIRST_OF_DAY, WORKOUT_ENDED…)
and one `ExplanationKey`; the "Why now?" sentence is localized from that key. Version string
`HRE_V1` is stamped on every decision/event so HRE_V2 can ship side by side.

## Fatigue
`index = (ignored·1 + snoozed·0.5 + opened·0.2)/resolved` over the last 20 reminders (≥6 needed).
≥0.30 moderate, ≥0.55 high; high with ≥10 samples offers "fewer reminders". Ignored reminders only
ever *widen* spacing.

## Behaviour metrics (documented formulas)
* Day adherence = 0.6·completion(capped at 1) + 0.4·timing (hourly checkpoints, only "behind" penalised).
* Consistency = recency-weighted (half-life 14 d) mean over 30 d; needs ≥3 days.
* Streak: miss consumes a recovery token (earned 1/7 good days, max 2).
* Momentum (0–100): consistency .40, response .20, stability .15, timing .15, self-started .10;
  needs ≥5 active days. A behaviour score, not health.
* Reminder independence: reminders/active day, first 14 d vs last 14 d (≥28 d history); celebrated
  only if consistency held. The engine never suppresses reminders to move this number.
* Insights are gated on data sufficiency (first day ⇒ no pattern claims).
