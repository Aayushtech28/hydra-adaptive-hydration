# Release readiness

> **HYDRA is NOT production-ready.** No Android or iOS build has been produced and nothing has run
> on a device. Everything below marked "Dart-tested" runs in the Flutter test VM only.

## Verification legend
| Tag | Meaning |
|---|---|
| **S** | statically verified (read/analyzed; analyzer clean) |
| **D** | Dart/Flutter tested (`flutter test`, in-memory DB, fake platform services) |
| **A** | Android device verified — *nothing yet* |
| **I** | iOS device verified — *nothing yet* |
| **C** | requires credentials |
| **M** | requires manual Xcode / Play Console / App Store Connect / AdMob / RevenueCat configuration |

## Status by area (last run: 243 tests passing, `dart analyze lib test` clean)
| Area | S | D | A | I | Notes |
|---|:-:|:-:|:-:|:-:|---|
| App boot, routing, onboarding redirect | ✓ | ✓ | ✗ | ✗ | real app booted in widget tests; startup-failure screen tested |
| Onboarding persistence, permission asked only on consent | ✓ | ✓ | ✗ | ✗ | "Start without reminders" disables reminders (even on Android ≤12) |
| Logging, undo, edit, delete, validation | ✓ | ✓ | ✗ | ✗ | future-dated logs rejected; 100 rapid taps coalesce |
| HRE_V1 scheduler (pace, quiet hours, workout, snooze, pause, fatigue, closing) | ✓ | ✓ | – | – | incl. DST spring/fall, overnight routines |
| Day rollover (04:00), timezone change | ✓ | ✓ | ✗ | ✗ | reminders re-planned on next app open (see limits) |
| Notification scheduling / actions logic | ✓ | ✓ | ✗ | ✗ | **delivery, action buttons, background isolate, reboot: unverified** |
| Health sync logic (dedupe, idempotent, tombstones, failure-safe) | ✓ | ✓ | ✗ | ✗ | HealthKit/Health Connect calls themselves unverified; needs **M**/**C** |
| Ads policy / consent / privacy boundary | ✓ | ✓ | ✗ | ✗ | SDK, UMP forms, real units unverified; needs **C**/**M** |
| Entitlement logic (trial/active/grace/billing/expired/offline) | ✓ | ✓ | ✗ | ✗ | purchase flow with real store unverified; needs **C**/**M** |
| Paywall states (unavailable, plans, success, cancel, restore, Pro, billing issue) | ✓ | ✓ | ✗ | ✗ | uses a fake subscription service |
| Export (CSV/JSON) content & escaping | ✓ | ✓ | ✗ | ✗ | share sheet unverified |
| Delete-all-data | ✓ | ✓ | ✗ | ✗ | always re-bootstraps; Health records untouched by design |
| Accessibility: 2× text, tap targets, labels, contrast | ✓ | ✓ (key screens) | ✗ | ✗ | **VoiceOver/TalkBack never run** |
| Localization | ✓ | – | – | – | English only; RTL layout-safe by construction, untested |
| Android manifest/Gradle | ✓ | – | ✗ | – | **never compiled** (no SDK) |
| iOS Info.plist/entitlements/xcconfig | ✓ | – | – | ✗ | **never compiled** (no Xcode) |
| Android widget | ✓ | – | ✗ | – | Kotlin/XML written against home_widget 0.10 API, uncompiled |
| iOS widget | – | – | – | ✗ | Swift source only; **no Xcode target exists** |
| Store compliance | – | – | – | – | not claimed |

## Known limitations (by design or unverified)
* Reminders are an OS-scheduled chain (≤6). After a **timezone change while the app is closed** they fire at the old absolute times until the next app open.
* No exact alarms: delivery can be delayed by Doze/battery saver (documented in-app via the notification check-up).
* Reminder "sent/ignored" is inferred (no delivery receipts on either OS).
* Deleting a record in the health app is **not mirrored** into HYDRA (iOS hides denied reads; mirroring risked data loss).
* Data export is free (portability right) although the original matrix listed it under Pro.
* Only English strings. No app icon artwork yet (default Flutter icon). No Watch/Wear, weather, cloud sync, smart bottle.

## Exact remaining steps

### A. On your computer (no accounts needed)
```bash
git pull && flutter pub get
flutter doctor -v                       # install Android SDK / Xcode as prompted
flutter test && dart analyze lib test   # expect 243 passing, 0 issues
flutter run                             # Android emulator or iOS simulator, dev env, Google TEST ads
```
Then walk through, on **a real Android device and a real iPhone**:
1. Fresh install → onboarding → allow notifications → log a drink → reminder arrives → tap **+250 ml** from the notification with the app **killed** → reopen: entry present.
2. Snooze from the notification; reboot the phone; confirm the next reminder still fires (Android boot receiver).
3. Change timezone in system settings, open the app: banner shows, next reminder in local time.
4. Revoke the notification permission → app keeps working; nudge appears.
5. Airplane mode: log, history, reminders all work; no ad slot appears.
6. Android: add the home-screen widget, tap **+250 ml** on it with the app closed; check progress updates. (If the widget does not build, fix `HydraWidgetProvider.kt` against the compiler output.)
7. TalkBack / VoiceOver pass over Home, log sheet, History, Privacy Center; Dynamic Type at the largest sizes.
8. Privacy Center: export CSV/JSON (opens share sheet), delete all data → returns to onboarding.
9. `flutter build apk --debug` and `flutter build ios --debug --no-codesign`; fix any native build errors.

### B. Apple (needs Apple Developer account) — **M/C**
* Final bundle id (currently `com.hydra.hydra`); enable **HealthKit** capability (entitlement file is in the repo; the profile must include it).
* App Store Connect: app record, subscription group with monthly/annual (+lifetime) products, price tiers, review notes, screenshots (plan below), age rating, **App Privacy** labels (Health & Fitness: water intake; analytics only if enabled), privacy-policy URL.
* Add a **Widget Extension** target in Xcode from `ios/HydraWidget/HydraWidget.swift`; enable App Group `group.com.hydra.hydra` on Runner and the extension and add it to `Runner.entitlements`.
* AdMob iOS app id → `ios/Flutter/Hydra.local.xcconfig` (`ADMOB_APP_ID=…`, git-ignored); replace the single SKAdNetwork entry with Google's full list.
* No ATT prompt is used or needed; do **not** add `NSUserTrackingUsageDescription`.
* Signing, TestFlight, then submit.

### C. Google Play (needs Play Console) — **M/C**
* Package name (currently `com.hydra.hydra`), Play App Signing, create `android/key.properties` + keystore (git-ignored).
* Declarations: **Health apps**, **Health Connect permissions** (READ/WRITE_HYDRATION with rationale), **Data safety**, **Ads** (contextual only; `AD_ID` permission is removed), content rating, target audience (not child-directed), subscriptions, data-deletion URL.
* Internal testing track → closed test → production.

### D. AdMob — **C**
Create the Android/iOS apps; put the real app ids in (`-PADMOB_APP_ID=…`, `ADMOB_APP_ID` xcconfig) and the four unit ids per platform as `--dart-define=ADMOB_BANNER_ANDROID=… ADMOB_NATIVE_… ADMOB_INTERSTITIAL_… ADMOB_REWARDED_…` (and `_IOS`). Configure the UMP consent message (EEA/UK, US states). Prod never falls back to test ads: a missing unit disables that format.

### E. RevenueCat — **C**
Project + both store apps, products, entitlement id **`hydra_pro`**, an offering with annual/monthly (+lifetime) packages, public SDK keys → `--dart-define=RC_KEY_ANDROID=… RC_KEY_IOS=…`. Test purchase, restore, cancel and a sandbox billing-issue on both platforms.

### F. Web / legal — **M**
Publish Privacy Policy and Terms (`PRIVACY_URL`, `TERMS_URL`), support email (`SUPPORT_EMAIL`). The app logs a *critical* "release config" message and the diagnostics report lists a problem if a prod build still has placeholders. Have the health/wellness disclaimer reviewed for your launch regions.

### G. Optional
Firebase: `flutterfire configure`, build with `FIREBASE_ENABLED=true` (analytics/crash stay off until the user opts in or UMP says consent isn't required). `REMOTE_CONFIG_URL` must be https.

### H. Production build
```bash
flutter build appbundle --release --dart-define=HYDRA_ENV=prod \
  --dart-define=RC_KEY_ANDROID=… --dart-define=ADMOB_BANNER_ANDROID=… (all units) \
  --dart-define=PRIVACY_URL=https://… --dart-define=TERMS_URL=https://… --dart-define=SUPPORT_EMAIL=… \
  -PADMOB_APP_ID=ca-app-pub-…~…
flutter build ipa --release --dart-define=HYDRA_ENV=prod …   # same defines
```

## Store assets to produce
App icon (droplet + circular rhythm, readable at 20 px; adaptive icon for Android); screenshots —
1 *Hydration that adapts to your day* (dashboard) · 2 *Log in one tap* (quick add + undo) ·
3 *Reminders that learn your rhythm* (next reminder + "Why now?") · 4 *Know whether you're on pace* ·
5 *Build consistency* (week/calendar + momentum) · 6 *Your data. Your control.* (Privacy Center).
Title *HYDRA: Smart Water Reminder*, subtitle *Adaptive hydration tracking*.

## Estimated remaining work to a store release
| Block | Estimate |
|---|---|
| First device builds + fixing native build/runtime issues (Gradle, widget, Pods, plugins) | 2–4 days |
| Device QA: notifications (kill/reboot/Doze/OEM), widget, Health Connect/HealthKit, a11y with screen readers | 4–6 days |
| Store accounts, AdMob, RevenueCat products, sandbox purchase testing | 3–5 days |
| Icon, screenshots, listing copy, legal pages, privacy/Data-safety forms | 3–4 days |
| Beta (TestFlight / Play internal+closed, Play requires a 14-day closed test for new personal accounts) and fixes | 2–3 weeks elapsed |
| Optional: translations, second-language QA | +1–2 weeks |
Realistic: **~3–4 weeks elapsed** to first store submission if accounts are ready, mostly device QA and review cycles.
