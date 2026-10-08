# Privacy architecture

**Two domains that never touch.**
`HEALTH/HYDRATION` (entries, pace, routines, health sync, insights) and `ADVERTISING`
(`lib/services/ads`, `lib/features/ads`). Enforced, not promised:
* `test/privacy_boundary_test.dart` fails if `services/ads` imports hydration/health/domain code.
* Ad requests are always contextual (`nonPersonalizedAds: true`, no keywords/content URL); not a user toggle.
* There is no `AdPlacement` for the dashboard, logging, onboarding, permission, privacy or
  notification flows — such an ad cannot be expressed. Policy lives in one `AdPolicyManager`
  (no ads for Pro / without UMP consent / offline / before 3 logs; ≤1 interstitial per session, ≤2/day).
* Android: `AD_ID` permission stripped; iOS: no ATT prompt, no `NSUserTrackingUsageDescription`.

**Analytics**: closed event enum + parameter allow-list (`AnalyticsService.sanitize`); no amounts or
history are representable. Default on only outside consent regions (UMP), otherwise off until opt-in.
**Logs/crashes**: `Redactor` strips volumes, dates and emails; only allow-listed field keys survive.
**Health**: only water intake (`READ/WRITE_HYDRATION`, HealthKit dietaryWater). Deleting HYDRA data
does not delete Health records (stated in the UI).
**Export**: CSV `id,date,timestamp_utc,timezone,volume_ml,beverage,vessel,source`; JSON
`hydra.export.v1` (profile, vessels, routines, entries). **Delete**: `AppDatabase.deleteEverything()`
in one transaction + cancel reminders + reset widget; then a fresh profile triggers onboarding.
**Widgets**: percentage + short labels only; optional "hide amounts".
