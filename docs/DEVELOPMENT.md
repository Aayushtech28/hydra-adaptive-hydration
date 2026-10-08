# Development

## Toolchain
Flutter 3.47 / Dart 3.13. `flutter pub get`; Drift code: `dart run build_runner build`;
strings: edit `lib/l10n/app_en.arb` (placeholders are positional by first appearance) then `flutter gen-l10n`.

## Environments
`--dart-define=HYDRA_ENV=dev|staging|prod` (default dev). Dev/staging use Google's public **test**
ad units; **prod never falls back to test ads** — a missing `ADMOB_*` define disables that format.
Android: `-PADMOB_APP_ID=…` and `-PAPP_ID_SUFFIX=.dev` Gradle properties (defaults: Google test app id, no suffix).
iOS: `ADMOB_APP_ID` in `ios/Flutter/Hydra.local.xcconfig` (git-ignored). RevenueCat public SDK keys via
`RC_KEY_ANDROID/IOS`; without them the paywall says purchases are unavailable and the app stays free.

## Tests
243 tests. Files: `test/domain`, `test/data`, `test/services` (entitlements, ad policy, config), `test/application` (pipeline, hardening), `test/ui_flows_test.dart` (log sheet, onboarding, settings, paywall states, privacy), `test/accessibility_test.dart`, `test/app_smoke_test.dart`, `test/privacy_boundary_test.dart`. Helpers: `test/support/{harness,fakes,ui}.dart` (`bootApp`, `settle`, `tapVisible`).

`flutter test` — domain (scheduler, DST, analytics, units, reconciliation), data (Drift in-memory),
`test/application` (full pipeline with fake notifications/widgets), `app_smoke_test` (boots the real
app: onboarding → dashboard → log → tabs → every settings page), `accessibility_test`
(2× text, tap-target/label/contrast guidelines), `privacy_boundary_test`.
Widget tests don't `db.close()` (drift waits on fake-async timers) and use explicit `pump`
because the ring animates forever.

## Debug tools
You ▸ Developer tools exists only when `!kReleaseMode && env != prod`: engine panel, simulate
tomorrow, missed reminder, snooze, force Pro, reset consent, test notification.

## Flags & remote config
`Flag` enum has safe defaults; `RemoteConfig.parse` validates everything (ad caps can only get stricter).
The scheduler algorithm is not remotely configurable.
