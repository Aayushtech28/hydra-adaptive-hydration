# HYDRA — Adaptive Hydration Tracker

*Hydration that adapts to your day. The smarter it gets, the quieter it gets.*

A local-first, accountless Flutter app (iOS + Android). A deterministic,
explainable scheduler (HRE_V1) spaces reminders by comparing your intake with a
planned curve across your waking day, learns from how you respond, and gets
**quieter** as your habit forms. No LLM, no backend required.

## Run it

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift (generated files are committed)
flutter gen-l10n                                           # only after editing lib/l10n/app_en.arb
flutter run                                                # dev env, Google TEST ads, no credentials needed
```

Optional configuration (all via `--dart-define`, nothing secret is in git):
`HYDRA_ENV=dev|staging|prod`, `RC_KEY_ANDROID`, `RC_KEY_IOS`, `ADMOB_*` unit ids
(prod only), `REMOTE_CONFIG_URL`, `FIREBASE_ENABLED`, `PRIVACY_URL`, `TERMS_URL`,
`SUPPORT_EMAIL`. See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Checks

```bash
dart analyze          # 0 issues
flutter test          # unit + data + pipeline + widget (app boot) + a11y + privacy-boundary tests
```

## Docs

| | |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | layers, data flow, failure behaviour |
| [SCHEDULER.md](docs/SCHEDULER.md) | HRE_V1 maths, states, reasons, metrics formulas |
| [PRIVACY_ARCHITECTURE.md](docs/PRIVACY_ARCHITECTURE.md) | health ⟂ advertising separation, export/delete |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | environments, testing, debug tools, flags |
| [RELEASE.md](docs/RELEASE.md) | manual setup checklist, store notes, audit status |

HYDRA is a wellness and habit tool, not a medical device.
