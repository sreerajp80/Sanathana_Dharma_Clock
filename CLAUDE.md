# CLAUDE.md — Sanathana Dharma Clock

This file is read by Claude Code at the start of every session in this repository.
Read it before making any change. See the docs table below for full detail — this file points to
the `docs/` files rather than repeating them.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | Sanathana Dharma Clock |
| Type | A clock that keeps time in the Sanātana Dharma (Vedic) system (Ghaṭikā : Vināḍī : Prāṇa), anchored to local sunrise, shown next to civil time. Includes a Panchang tab and Settings. |
| Platform(s) | Android only (minSdk 24, targetSdk 35 — confirm before first release) |
| Package / org id | `in.sreerajp.sanathana_dharma_clock` (also the Android namespace and applicationId) |
| Flutter SDK | 3.41.9 (stable) |
| Dart SDK | 3.11.5 |
| State management | Riverpod |
| Navigation | go_router |
| Database | none — `shared_preferences` for the saved location and settings |
| Orientation | portrait (confirm) |
| Connectivity | fully offline — no `INTERNET` permission |

> Keep this table honest and current. It is the fastest way to orient.

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Changing structure, screens, state, services, models, repositories, the dial, or the clock math |
| [docs/security.md](docs/security.md) | Touching permissions, logging, storage, or the manifest |
| [docs/release_process.md](docs/release_process.md) | Building a release, versioning, signing, release checklist |
| [docs/Sanathana_Dharma_Clock-Idea.md](docs/Sanathana_Dharma_Clock-Idea.md) | Understanding the product concept and the time-unit math |
| [docs/guidelines/flutter_build_flavors_guide.md](docs/guidelines/flutter_build_flavors_guide.md) | Build config, signing, flavors, Gradle, ProGuard |
| [docs/guidelines/flutter_project_engineering_standard.md](docs/guidelines/flutter_project_engineering_standard.md) | Any code change — layers, naming, testing |
| [docs/guidelines/guideline.md](docs/guidelines/guideline.md) | About-screen config, keystore rules, `lib/` layout |
| [docs/GUIDELINES_MANIFEST.md](docs/GUIDELINES_MANIFEST.md) | The shared Flutter guidelines index |

> If a doc is copied into this project's own `docs/`, the local copy wins over the submodule copy.

---

## Hard rules (must follow — these override convenience)

1. **Offline only.** The app works fully offline. Never add the `INTERNET` permission or any
   networking package. The sunrise math is computed on the device.
2. **Open source only.** Every package must be open source. Check the licence before adding one.
3. **Location stays on the device.** Never send location anywhere; never log exact coordinates.
4. **Never crash on a missing anchor.** No location or no sunrise for a date must fall back
   safely (saved location → midnight-anchored day; polar day → fixed 86,400 s span).
5. **About screen is data-driven.** About values come from `assets/config/app_config.json` via
   `AppConfig` / `ConfigService`. Never hard-code About text (see guideline §1).

---

## Architecture rules

- Layout: Tier 1 layer-first under `lib/` — `core/config`, `core/constants`, `core/utils`,
  `models/`, `services/`, `repositories/`, `providers/`, `screens/`, `widgets/`, `theme/`,
  `main.dart`. Do not restructure without instruction. Full detail:
  [docs/architecture.md](docs/architecture.md).
- Layer boundaries: widgets must not know the solar formula, `shared_preferences` keys, or plugin
  APIs. Services must not know `BuildContext`, routes, or UI strings.
- Dependency direction: `screens → providers → services/repositories → shared_preferences/models`.
- Models are immutable. Recompute the dharma-time reading each tick; do not mutate in place.
- The Panchang tab is a separate concern — do not couple it to the clock.

---

## Build & run commands

```bash
flutter pub get                        # install dependencies
flutter run --flavor dev               # daily development
flutter run --flavor prod              # production-like run
flutter analyze                        # static analysis (must be clean)
flutter test                           # run all tests
dart format .                          # format before committing

# Production release APK (split per ABI)
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/ --split-per-abi

# Production Play Store bundle
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/
```

> This app defines flavors, so a bare `flutter run` fails — always pass `--flavor`.

---

## Build flavors

| Flavor | App ID | Display name | Signing |
|--------|--------|--------------|---------|
| dev | `in.sreerajp.sanathana_dharma_clock.dev` | Sanathana Dharma Clock Dev | Debug keystore (automatic) |
| prod | `in.sreerajp.sanathana_dharma_clock` | Sanathana Dharma Clock | Release keystore (`android/key.properties`) |

> Flutter ≥ 3.19 sets `FLUTTER_APP_FLAVOR` for you; read it with
> `String.fromEnvironment('FLUTTER_APP_FLAVOR')`. Do not pass it explicitly on Android.

---

## Signing / keystore

- Keystore at `android/<name>.jks`; `android/key.properties` points to it. Keep at least two
  offline backups. Full rules: [docs/guidelines/guideline.md](docs/guidelines/guideline.md) §2 and
  [docs/release_process.md](docs/release_process.md) §7.
- `.gitignore` must include: `android/key.properties`, `android/*.jks`, `android/*.keystore`,
  `build/symbols/`.

---

## Security rules

- Never add `INTERNET`; verify it is absent from the merged release manifest.
- Request location only at the point of use, with a short reason. Fall back safely if denied.
- Never log exact coordinates at `info` level or above.
- Exclude the `shared_preferences` location record from Android cloud backup.
- Full detail: [docs/security.md](docs/security.md).

---

## Code style / naming

- Files `snake_case.dart`; classes `PascalCase`; variables/methods `camelCase`; Riverpod
  providers `camelCase` + `Provider` suffix.
- Use `package:` imports, not relative. Prefer `const` constructors, `final` locals, single quotes.
- Run `dart format .` and keep `flutter analyze` at zero warnings before every commit.

---

## Testing rules

- Mirror `lib/` structure in `test/` (`test/services/`, `test/models/`, `test/widgets/`).
- Critical areas that must be covered before release:
  - Sunrise math (known lat/lon/date → expected sunrise).
  - Dharma-time mapping and its reverse (civil ↔ Ghaṭikā:Vināḍī:Prāṇa).
  - Edge cases: before-sunrise anchor, polar no-sunrise span, day-boundary roll.
- Add or update a test whenever you change a service or model. Full detail:
  [docs/architecture.md](docs/architecture.md) §18.

---

## Dependency constraints

- Blocked (never add, never accept as a transitive dep): http clients, cloud/BaaS, analytics,
  crash reporting, ads, network-status packages — the app is offline.
- Allowed core deps: a location plugin (e.g. `geolocator`), `shared_preferences`,
  `package_info_plus`, Riverpod, go_router. The solar math is written directly — no package.
- Before adding any package: check its `pubspec.yaml` for networking deps, confirm it is open
  source, and confirm it fits the hard rules.

---

## Where things live

```
CLAUDE.md            # this file — project rules
docs/                # design docs (architecture, security, release, idea)
docs/guidelines/     # shared guidelines Git submodule — read-only, never edit here
plans/               # one plan per change (see workflow rules)
change_log/          # one log per implemented change
lib/                 # app source (see docs/architecture.md §4)
test/                # tests
```

---

## Workflow rules (mandatory — from global rules)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to change, the issue,
   and the fix. Then **STOP and get explicit approval** before editing, creating, or deleting any
   project file (other than the plan). A question or ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to `change_log/` named
   `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in
  plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## What Claude must always / never do

**Always:** read this file first; state the target layer before adding a class; keep `main.dart`
thin; recompute sunrises once per day, not every tick; run `flutter analyze` + `flutter test`
after changes.

**Never:** add the `INTERNET` permission or a networking package; log exact coordinates; put the
solar or dharma-time math in a widget; call `shared_preferences` from a widget; hard-code About
text; edit files inside `docs/guidelines/` (the submodule).
