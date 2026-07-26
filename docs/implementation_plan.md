# Implementation Plan — Sanathana Dharma Clock

This is the phase-by-phase plan to build the app from an empty repository to a signed
release. Each phase has an **Objective** and **Action steps**. Read this before starting
a phase, then track progress in [implementation_progress.md](implementation_progress.md).

**Read first:** [../CLAUDE.md](../CLAUDE.md) · the design in
[architecture.md](architecture.md) · the product concept and time-unit math in
[Sanathana_Dharma_Clock-Idea.md](Sanathana_Dharma_Clock-Idea.md).

**Date:** 2026-07-21
**Scope:** The whole app build, Android only, offline only.
**Starting point:** Empty of source — docs and the guidelines submodule exist, but there
is no `lib/` folder yet.

---

## How to use this plan

- Build the phases in order. Each phase should leave `flutter analyze` clean and, from
  Phase 3 on, its tests passing.
- Follow every hard rule in [../CLAUDE.md](../CLAUDE.md): offline only, open source only,
  location stays on the device, never crash on a missing anchor, About screen is
  data-driven.
- Each change still follows the workflow rules — write a plan in `plans/`, get approval,
  then log in `change_log/`. This document is the overall map; the per-change plans are
  the detail.
- Mark work done in [implementation_progress.md](implementation_progress.md) as you go.

---

## Phase 1 — Project scaffold and config

**Objective:** A running Flutter app skeleton with flavors, dependencies, the folder
layout, and the data-driven About config in place.

**Action steps:**

- Create the Flutter application with namespace / applicationId
  `in.sreerajp.sanathana_dharma_clock`.
- Set up `dev` and `prod` flavors (app IDs and display names per
  [../CLAUDE.md](../CLAUDE.md)); wire `AppFlavorConfig` to read `FLUTTER_APP_FLAVOR`.
- Add core dependencies to `pubspec.yaml`: `flutter_riverpod`, `go_router`, `geolocator`,
  `shared_preferences`, `package_info_plus`. Check each is open source and has no
  networking that breaks the offline rule.
- Create the `lib/` skeleton: `core/config`, `core/constants`, `core/utils`, `models`,
  `services`, `repositories`, `providers`, `screens`, `widgets`, `theme`, `main.dart`.
- Add `assets/config/app_config.json` and the `AppConfig` model + `ConfigService` for the
  About screen (guideline §1). Register the asset in `pubspec.yaml`.
- Add `analysis_options.yaml`; confirm `flutter analyze` is clean and both flavors run.

---

## Phase 2 — Core models

**Objective:** The immutable data types the rest of the app depends on.

**Action steps:**

- `models/dharma_time.dart` — `DharmaTime` holding Ghaṭikā, Vināḍī, Prāṇa, Muhūrta plus
  `span`, `ghatikaLen`, and `sunrise`. Immutable; recomputed each tick.
- `models/saved_location.dart` — `SavedLocation` (latitude, longitude, label) with
  to/from JSON for `shared_preferences`.
- Add `core/constants/app_constants.dart` for pref keys and thresholds.

---

## Phase 3 — Solar and time services

**Objective:** The pure math at the heart of the clock, fully testable, no UI or plugins.

**Action steps:**

- `services/solar_calculator.dart` — `SolarCalculator` implementing the NOAA
  solar-position formula (Julian date → declination → hour angle → sunrise). All math in
  UTC; convert to local only for display.
- `services/time_calculator.dart` — map a civil time + today's sunrise + span to
  Ghaṭikā:Vināḍī:Prāṇa:Muhūrta, using the elastic-span formula (idea doc §4). Make it
  reversible (dharma reading → civil time).
- Add helpers in `core/utils/` for date/UTC handling (compute two sunrises: today and
  tomorrow; the gap is the day span).
- Write the first unit tests now (see Phase 9) so the math is proven before UI is built.

---

## Phase 4 — Location

**Objective:** Get a location safely, save it on the device, and never crash without one.

**Action steps:**

- `services/location_service.dart` — `LocationService` fetches live GPS via `geolocator`,
  requesting permission at the point of use with a short reason.
- `repositories/location_repository.dart` — read/write the single `SavedLocation` record
  in `shared_preferences`. Widgets never touch prefs directly.
- Add the Android location permission to the manifest; confirm `INTERNET` is **not**
  present.
- Implement the fallbacks: no location / denied → saved location → midnight-anchored day;
  polar no-sunrise → fixed 86,400 s span; `now` before sunrise → yesterday's sunrise.
- Exclude the saved-location pref from Android cloud backup.

---

## Phase 5 — State layer (Riverpod)

**Objective:** Wire services to the UI through providers, with a correct clock tick.

**Action steps:**

- Provide `SharedPreferences` and `AppConfig` at the root `ProviderScope` (set up in
  `main.dart` per architecture §5).
- Add a once-per-second clock-tick provider that produces the current `DharmaTime`.
- Add providers for the active location (live vs saved) and for display settings.
- Handle lifecycle: stop the tick on `paused`, restart on `resumed`, and recompute
  sunrises **once per day** (not every tick), rolling the anchor at the day boundary.
- Add the global error handlers (`FlutterError.onError`, `PlatformDispatcher.onError`).

---

## Phase 6 — UI: clock screen

**Objective:** The main analog dial and digital readout, themed and accessible.

**Action steps:**

- `theme/app_theme.dart` — a single `ThemeData`: vermillion (`≈ #E34234`) on chandan
  (`≈ #F1E4C3`). Check contrast meets WCAG AA; darken vermillion for small text if needed.
- `widgets/dharma_dial_painter.dart` — a `CustomPainter` for the analog face: 30 Muhūrta
  outer ring, 60 Ghaṭikā marks, Vināḍī and Prāṇa hands, a sunrise/now rim marker. Keep the
  painter cheap (repaints once per second).
- `screens/clock_screen.dart` — the dial plus the digital readout (dharma units, Muhūrta
  name, civil time, sunrise). Give the clock a screen-reader label.
- Set up `go_router` with routes `/`, `/panchang`, `/settings`, `/about`.

---

## Phase 7 — UI: settings and about

**Objective:** A card-based Settings screen and a data-driven About screen.

**Action steps:**

- `screens/settings_screen.dart` — one card per section: **Location** (fetch/save,
  live vs saved toggle, show current saved location), **Display** (analog / digital /
  both, format options), **About** (opens the About screen).
- `screens/about_screen.dart` — read all values from `AppConfig` (never hard-code About
  text). Show name, version (via `package_info_plus`), author, etc.
- Ensure touch targets are at least 48 × 48 dp and the screens read well at 1.0×, 1.5×,
  and 2.0× text scale.

---

## Phase 8 — Panchang tab wiring

**Objective:** Make the Panchang tab reachable without coupling it to the clock.

**Action steps:**

- Add `screens/panchang_screen.dart` (or wire the existing Panchang concern) into
  navigation as a separate tab.
- Do not share clock state, the solar formula, or the dharma-time mapping with Panchang —
  it stays an independent concern.

---

## Phase 9 — Tests

**Objective:** Cover the critical, high-risk areas before release.

**Action steps:**

- Mirror `lib/` under `test/` (`test/services/`, `test/models/`, `test/widgets/`,
  `test/helpers/`).
- **Sunrise math** — known lat/lon/date → expected sunrise, compared against a NOAA
  reference value.
- **Dharma-time mapping** — a civil time + sunrise + span maps to the exact
  Ghaṭikā:Vināḍī:Prāṇa, and back (reversible).
- **Edge cases** — before-sunrise anchor, polar no-sunrise 86,400 s span, day-boundary
  roll.
- **Model round-trip** — `SavedLocation` encode → decode → equal.
- **Widget** — clock readout and Settings cards render with a fake clock provider.
- Keep `flutter analyze` at zero warnings and `flutter test` green.

---

## Phase 10 — Release hardening

**Objective:** A signed, obfuscated, verified production build.

**Action steps:**

- Create the release keystore at `android/<name>.jks` and `android/key.properties`
  (see [release_process.md](release_process.md) §7). Keep at least two offline backups.
- Confirm `.gitignore` includes `android/key.properties`, `android/*.jks`,
  `android/*.keystore`, and `build/symbols/`.
- Verify the **merged release manifest has no `INTERNET` permission** (analyze the built
  APK).
- Build the obfuscated split-per-abi release APK and the Play Store app bundle with
  `--split-debug-info` symbols saved under `build/symbols/android-prod-<version>/`.
- Confirm cold start is under 2 seconds to first frame.

---

## Definition of Done

- All ten phases complete and checked off in
  [implementation_progress.md](implementation_progress.md).
- `flutter analyze` clean; `flutter test` green; `dart format .` applied.
- All five hard rules from [../CLAUDE.md](../CLAUDE.md) hold, verified on the built
  artifact (offline, open-source deps, location on-device, safe fallbacks, data-driven
  About).
- The critical test areas (sunrise math, dharma mapping + reverse, edge cases) pass.
- A signed prod release APK and app bundle build successfully with obfuscation and saved
  symbols.

---

## Related documents

- [../CLAUDE.md](../CLAUDE.md)
- [architecture.md](architecture.md)
- [Sanathana_Dharma_Clock-Idea.md](Sanathana_Dharma_Clock-Idea.md)
- [security.md](security.md)
- [release_process.md](release_process.md)
- [implementation_progress.md](implementation_progress.md)
