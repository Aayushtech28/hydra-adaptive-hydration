# Release

## Manual setup checklist (needs accounts/credentials — NOT done)
**Apple**: bundle id (currently `com.hydra.hydra` — choose final) · enable HealthKit capability ·
App Store Connect app + subscription group (monthly, annual, optional lifetime) · App Privacy
labels (Health & Fitness: water intake, not linked/tracking; Diagnostics if analytics on) ·
Widget Extension target from `ios/HydraWidget/HydraWidget.swift` + App Group `group.com.hydra.hydra`
(also add to `Runner.entitlements`) · full SKAdNetwork list from AdMob · signing/TestFlight.
**Google Play**: package name · App signing + `android/key.properties` (+ keystore, never commit) ·
Health apps declaration · Health Connect permission declaration (READ/WRITE_HYDRATION) · Data safety form ·
Ads declaration (contextual, no AD_ID) · subscriptions · content rating · account-deletion/data-deletion URL.
**AdMob**: create apps → real app ids (`ADMOB_APP_ID`) + banner/native/interstitial/rewarded unit ids (`ADMOB_*`);
configure UMP consent messages; GDPR/US-states messages.
**RevenueCat**: project, store connections, products, entitlement `hydra_pro`, offering with
annual/monthly/(lifetime) packages, public SDK keys → `RC_KEY_*`.
**Firebase (optional)**: `flutterfire configure`, then build with `FIREBASE_ENABLED=true`.
**Web**: live Privacy Policy + Terms URLs (`PRIVACY_URL`, `TERMS_URL`), support email, optional `REMOTE_CONFIG_URL`.
**Legal**: review disclaimer text per launch region; do not claim store compliance before submission.

## Build
```bash
flutter build appbundle --release --dart-define=HYDRA_ENV=prod \
  --dart-define=RC_KEY_ANDROID=… --dart-define=ADMOB_BANNER_ANDROID=… (etc.) -PADMOB_APP_ID=…
flutter build ipa --release --dart-define=HYDRA_ENV=prod …
```

## Store listing
Title: *HYDRA: Smart Water Reminder* · Subtitle: *Adaptive hydration tracking*.
Screenshots (headline → content): 1 *Hydration that adapts to your day* (dashboard) ·
2 *Log in one tap* (quick add + undo) · 3 *Reminders that learn your rhythm* (next reminder + Why now?) ·
4 *Know whether you're on pace* (pace chip + expected finish) · 5 *Build consistency* (week/calendar + momentum) ·
6 *Your data. Your control.* (Privacy Center). Icon: droplet + subtle circular rhythm — **not yet designed**.

## Status (see final report for evidence)
Validated here: Dart compile, analyzer, 160+ automated tests incl. booting the real app in a widget test.
**Not validated** (no SDK/device/credentials): Android/iOS builds, real notifications & background actions,
Health Connect/HealthKit, AdMob/UMP, RevenueCat purchases, home-screen widgets, store compliance.
Not implemented: translations other than English, Apple Watch/Wear OS, smart bottle, weather, cloud sync,
app icon artwork, iOS widget target (source provided).
