# Implementation Progress — Sanathana Dharma Clock

A live checklist of what is built. It mirrors the phases in
[implementation_plan.md](implementation_plan.md). Tick items as they are done and update
the status overview.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · the build plan in
[implementation_plan.md](implementation_plan.md) · the design in
[architecture.md](architecture.md).

**Date:** 2026-07-21
**Overall status:** Phases 1–9 done. The Flutter Android app skeleton, `dev`/`prod`
flavors, core dependencies, the `lib/` layout, and the data-driven About config are in
place (Phase 1); the core immutable models — `DharmaTime`, `SavedLocation`, and
`AppConstants` — are written (Phase 2); the pure clock math — `SolarCalculator` (NOAA
sunrise + day resolution) and `TimeCalculator` (civil ↔ dharma, reversible) — is written
with its first unit tests (Phase 3); the location layer — `LocationService`
(geolocator, permission at point of use), `LocationRepository` (saved location in prefs),
and the pure `LocationResolver` (live → saved → none fallback), plus the manifest location
permissions and backup exclusion — is in place (Phase 4); and the Riverpod state layer —
service providers, the location and display-settings notifiers, the `effectiveLocation`
selector, and the once-per-second `clockProvider` (once-per-day sunrise cache, day-boundary
roll, `AppLifecycleListener` lifecycle), plus the global error handlers in `main()` — is
wired (Phase 5); and the main UI — the `AppTheme` (vermillion-on-chandan), the
`DharmaDialPainter` analog face, the `ClockScreen` (dial + digital readout + screen-reader
label), and the `go_router` navigation — is built (Phase 6); and the settings and about UI —
the card-based `SettingsScreen` (Location / Display / About) and the data-driven
`AboutScreen` (all values from `AppConfig`) — is built (Phase 7); and the Panchang tab
is now reachable — a bottom `NavigationBar` (via `StatefulShellRoute.indexedStack` and a
new `HomeShell`) switches between the Clock and Panchang tabs, with Panchang kept fully
decoupled from the clock (Phase 8); and the test suite is filled out (Phase 9) — new
`test/models/` round-trips (`SavedLocation` JSON, `DisplayMode` storage) and
`test/screens/` widget tests (clock readout / display modes / anchor footer,
and the three Settings cards) added on top of the existing math and provider
tests. `flutter analyze` is clean and `flutter test` is green (70 tests).
Phase 10 is **partly done** — the in-repo release config is in place (R8/ProGuard
enabled with `android/app/proguard-rules.pro`, and `.gitignore` already covers
the signing material and symbols), but the steps that need the release keystore
and an Android device — creating the keystore, building the signed/obfuscated
APK + app bundle, verifying the built manifest, and the cold-start check — are
handed to the developer to run.

---

## 1. Status overview

| Phase | Name | Status |
|-------|------|--------|
| 1 | Project scaffold and config | ☑ Done |
| 2 | Core models | ☑ Done |
| 3 | Solar and time services | ☑ Done |
| 4 | Location | ☑ Done |
| 5 | State layer (Riverpod) | ☑ Done |
| 6 | UI: clock screen | ☑ Done |
| 7 | UI: settings and about | ☑ Done |
| 8 | Panchang tab wiring | ☑ Done |
| 9 | Tests | ☑ Done |
| 10 | Release hardening | ◐ In progress (config done; build handed off) |

Legend: ☐ Not started · ◐ In progress · ☑ Done.

---

## 2. Detailed checklist

### Phase 1 — Project scaffold and config

- [x] Flutter app created with applicationId `in.sreerajp.sanathana_dharma_clock`
- [x] `dev` and `prod` flavors set up; `AppFlavorConfig` reads `FLUTTER_APP_FLAVOR`
      (plus `APP_FLAVOR` for future desktop)
- [x] Core dependencies added (Riverpod, go_router, shared_preferences), each confirmed
      open source and offline-safe. **Deviation:** `package_info_plus` dropped and the
      `geolocator` umbrella replaced with `geolocator_android` +
      `geolocator_platform_interface` so no transitive `http` client enters the tree.
      Version/build now come from `app_config.json`.
- [x] `lib/` folder skeleton created (core/config, core/constants, core/utils, models,
      services, repositories, providers, screens, widgets, theme, main.dart)
- [x] `assets/config/app_config.json` + `AppConfig` + `ConfigService` in place
      (`ConfigService.loadAndVerify` adapted to take expected version/build, no
      `package_info_plus`)
- [x] `analysis_options.yaml` present (Flutter default `flutter_lints`); `flutter analyze`
      clean; dev flavor builds (debug APK)

### Phase 2 — Core models

- [x] `DharmaTime` model (Ghaṭikā, Vināḍī, Prāṇa, Muhūrta, fraction, span, ghatikaLen,
      sunrise) — immutable, value equality, no JSON (always computed)
- [x] `SavedLocation` model with JSON to/from (defensive per-field fallback; `toString`
      omits coordinates)
- [x] `core/constants/app_constants.dart` (pref keys, dharma-time nesting, `secondsPerDay`)

### Phase 3 — Solar and time services

- [x] `SolarCalculator` (NOAA sunrise formula, UTC math; `sunriseUtc` returns `null` for
      polar; `resolveDay` picks anchor + span with safe fallbacks)
- [x] `time_calculator.dart` mapping civil ↔ Ghaṭikā:Vināḍī:Prāṇa (elastic span), reversible
- [x] Date/UTC helpers in `core/utils/` (`startOfDayUtc`, `addDays`, `julianDay`; today +
      tomorrow sunrise and the day span computed in `SolarCalculator.resolveDay`)
- [x] First unit tests for the math (date utils, sunrise vs reference + polar + before-sunrise,
      mapping + reverse + day boundary) — 21 tests, all green

### Phase 4 — Location

- [x] `LocationService` (geolocator, permission at point of use; returns a
      `LocationResult`/`LocationStatus`, never throws)
- [x] `LocationRepository` (shared_preferences, single saved location + use-live flag;
      defensive reads)
- [x] Android location permission added (`ACCESS_COARSE`/`FINE_LOCATION`); `INTERNET`
      confirmed absent from the source manifest
- [x] Safe fallbacks: location selection via pure `LocationResolver` (live → saved →
      none → midnight day). Polar → 86,400 s and before-sunrise → yesterday already done
      in Phase 3's `SolarCalculator.resolveDay`.
- [x] Saved-location pref excluded from Android cloud backup (`android:allowBackup="false"`)

### Phase 5 — State layer (Riverpod)

- [x] `SharedPreferences` and `AppConfig` provided at root `ProviderScope` (Phase 1's
      `core_providers.dart`, overridden in `main.dart`); Phase 5 adds `service_providers.dart`
      (solar/time calculators, location service, location repository) on top.
- [x] Once-per-second clock-tick provider producing a `ClockSnapshot`. **Deviation:** the
      tick produces a `ClockSnapshot` (civil time + `DharmaTime` + `isPolar` + location
      `source`), a superset of `DharmaTime`, so the readout has everything it needs.
- [x] Providers for active location (`LocationNotifier` + `effectiveLocationProvider`,
      live vs saved) and display settings (`SettingsNotifier` / `displayModeProvider`)
- [x] Lifecycle handling: `AppLifecycleListener` stops the tick on pause/hide, restarts and
      recomputes on resume/show; the resolved `SolarDay` is cached and re-resolved only on
      the day-boundary roll (once per day, not per tick). A `nowProvider` makes the clock
      injectable for tests.
- [x] Global error handlers (`FlutterError.onError`,
      `WidgetsBinding.instance.platformDispatcher.onError`) set in `main()`; verbose detail
      gated by the flavor, never logging coordinates.

### Phase 6 — UI: clock screen

- [x] `app_theme.dart` (vermillion-on-chandan) with WCAG AA contrast checked
      (text uses the darker `#B32D1F`, the bright `#E34234` is for large dial strokes)
- [x] `DharmaDialPainter` custom painter (Muhūrta ring, Ghaṭikā/Vināḍī/Prāṇa hands, rim
      marker); `shouldRepaint` gated on the reading so it repaints once per second
- [x] `clock_screen.dart` with dial + digital readout (honours the display mode) +
      screen-reader `Semantics` label + an anchor-source footer
- [x] `go_router` routes `/`, `/panchang`, `/settings`, `/about` in `core/router.dart`
      (the three non-clock routes are placeholder screens, filled in Phases 7–8)

### Phase 7 — UI: settings and about

- [x] `settings_screen.dart` with Location, Display, and About cards
- [x] `about_screen.dart` reading all values from `AppConfig` (nothing hard-coded)
- [x] Touch targets ≥ 48 dp (ListTile/SwitchListTile/RadioListTile/buttons);
      both screens scroll so they hold up at 1.5×/2.0× text scale

### Phase 8 — Panchang tab wiring

- [x] `panchang_screen.dart` wired into navigation as a separate tab (bottom
      `NavigationBar` via `StatefulShellRoute.indexedStack`; new `HomeShell`)
- [x] No coupling to clock state, solar formula, or dharma-time mapping
      (`HomeShell` and `PanchangScreen` import none of them)

### Phase 9 — Tests

- [x] `test/` mirrors `lib/` (services, models, screens; helpers folder not
      needed — date/UTC helpers live under `test/core/utils/`)
- [x] Sunrise math test vs NOAA reference value (Phase 3 —
      `test/services/solar_calculator_test.dart`)
- [x] Dharma-time mapping test + reverse (Phase 3 —
      `test/services/time_calculator_test.dart`)
- [x] Edge-case tests (before-sunrise anchor, polar 86,400 s span, day-boundary
      roll — in the solar/time/clock provider tests)
- [x] `SavedLocation` JSON round-trip test (new `test/models/saved_location_test.dart`;
      plus `DisplayMode` storage round-trip in `test/models/display_settings_test.dart`)
- [x] Widget tests (clock readout, Settings cards) with a fake clock provider
      (new `test/screens/clock_screen_test.dart` + `test/screens/settings_screen_test.dart`)
- [x] `flutter analyze` zero warnings; `flutter test` green (70 tests)

### Phase 10 — Release hardening

- [x] R8 / ProGuard enabled for the release build: `android/app/proguard-rules.pro`
      added (keeps `io.flutter.**` + the geolocator plugin) and
      `isMinifyEnabled` / `isShrinkResources` / `proguardFiles` wired in
      `android/app/build.gradle.kts`
- [x] `.gitignore` covers `key.properties`, `*.jks`, `*.keystore`, `build/symbols/`
      (already present from Phase 1; re-verified)
- [ ] **(developer)** Release keystore + `key.properties` created; two offline
      backups made — needs the developer's secrets (not created here)
- [ ] **(developer)** Merged release manifest verified to have no `INTERNET`
      permission — needs the built APK
- [ ] **(developer)** Obfuscated split-per-abi APK + app bundle built; symbols
      saved under `build/symbols/android-prod-1.0.0/` — needs the keystore + build
- [ ] **(developer)** Cold start under 2 seconds to first frame confirmed —
      needs a device/emulator

---

## 3. Notes and dated updates

Add dated notes here as phases complete or blockers appear. Use absolute dates.

- 2026-07-21 — Progress tracker created. No source written yet; all phases Not started.
- 2026-07-21 — Phase 1 done. Scaffold, flavors, deps, `lib/` layout, and About config in
  place; `flutter analyze` clean. Key decision: to honour the "no http client, even
  transitively" hard rule, `package_info_plus` was dropped and `geolocator` (umbrella) was
  replaced by `geolocator_android` + `geolocator_platform_interface`. The dependency tree is
  now http-free. See the change log
  `change_log/20260721_151052_phase1-scaffold-and-config.md`.
- 2026-07-21 — Phase 2 done. Added the three core immutable models: `DharmaTime` (clock
  reading, computed each tick, no JSON), `SavedLocation` (JSON round-trip, defensive
  `fromJson`, `toString` hides coordinates), and `AppConstants` (pref keys + dharma-time
  nesting numbers). No math/services/UI yet. `flutter analyze` clean. See the change log
  `change_log/20260721_161611_phase2-core-models.md`.
- 2026-07-21 — Phase 3 done. Added the pure clock math: `DateUtils` (date/UTC helpers),
  `SolarCalculator` (hand-written NOAA sunrise in UTC, `null` for polar, `resolveDay` for the
  anchor + span with safe fallbacks), and `TimeCalculator` (elastic-span civil ↔ dharma
  mapping, reversible). First unit tests added (21, all green); `flutter analyze` clean. One
  deviation: the reverse snaps the cell start **up** (`ceil`) instead of rounding, so the
  round-trip is exact for an elastic span. See the change log
  `change_log/20260721_165257_phase3-solar-time-services.md`.
- 2026-07-21 — Phase 4 done. Added the location layer: `LocationService` (wraps
  `GeolocatorPlatform.instance`, asks permission at the point of use, returns a
  `LocationResult`/`LocationStatus` and never throws), `LocationRepository` (the only
  reader/writer of the saved location + use-live flag in `shared_preferences`, with
  defensive reads and a `clear` action), and the pure `LocationResolver` (live → saved →
  none fallback chain, fully unit-testable). Manifest gained the coarse/fine location
  permissions and `android:allowBackup="false"`; no `INTERNET`. Added 12 tests (repository
  round-trip/corruption/clear + resolver chain); 33 tests total, all green; `flutter
  analyze` clean. Riverpod wiring of these is Phase 5. See the change log
  `change_log/20260721_171500_phase4-location.md`.
- 2026-07-21 — Phase 5 done. Added the Riverpod state layer: `service_providers.dart`
  (solar/time calculators, location service + repository), `location_providers.dart`
  (`LocationNotifier` state + `effectiveLocationProvider` live → saved → none selector),
  `settings_providers.dart` + `models/display_settings.dart` (`DisplayMode`, persisted),
  `models/clock_snapshot.dart`, and `clock_providers.dart` (`nowProvider` + `clockProvider`:
  the 1 s tick, once-per-day sunrise cache with day-boundary roll, and `AppLifecycleListener`
  pause/resume). `main()` gained the global error handlers. Two decisions: the tick emits a
  `ClockSnapshot` (superset of `DharmaTime`) so the readout also has civil time / polar flag /
  location source; and no logging package was added (used `debugPrint` gated by the flavor).
  Added 15 provider tests (settings persistence, location resolve chain, clock mapping +
  no-location fallback + day roll); 48 tests total, all green; `flutter analyze` clean. See
  the change log `change_log/20260721_184112_phase5-state-layer.md`.
- 2026-07-21 — Phase 6 done. Built the main UI: `theme/app_theme.dart` (one Material 3
  vermillion-on-chandan `ThemeData`; text uses the darker `#B32D1F` for WCAG AA on the
  `#F1E4C3` background, the bright `#E34234` is kept for large dial strokes),
  `core/constants/muhurta_names.dart` (the 30 day-Muhūrta names + a clamped `at` lookup),
  `widgets/dharma_dial_painter.dart` (the analog face: 30-Muhūrta ring, 60-Ghaṭikā ticks,
  three hands, and a sunrise/now rim marker; `shouldRepaint` gated on the reading),
  `screens/clock_screen.dart` (dial + digital readout honouring the display mode, a
  `Semantics` label, and an anchor-source footer), and `core/router.dart` (go_router with
  the four routes). `main.dart` now uses `MaterialApp.router` with the theme and router.
  The three non-clock routes are placeholder screens for now (Phases 7–8 fill them). No new
  dependencies. `flutter analyze` clean; 48 tests still green (widget tests are Phase 9).
  See the change log `change_log/20260721_190000_phase6-clock-screen.md`.
- 2026-07-21 — Phase 7 done. Built the settings and about UI. `SettingsScreen` is
  now a `ConsumerWidget` with three cards: **Location** (a "use live location"
  switch, a "save current location" button that fetches a fix and stores it, the
  saved place shown on screen with a "Clear" action, and plain-English status
  lines), **Display** (a `RadioGroup` of the three `DisplayMode`s), and **About**
  (a tile that pushes the About screen). `AboutScreen` is a `ConsumerWidget` that
  reads every value from `appConfigProvider` — app name, description,
  version/build, and the details rows — so nothing is hard-coded (hard rule 5). All
  interaction goes through the existing notifiers; no widget touches prefs or the
  plugin. One deviation: switched `RadioListTile`'s deprecated `groupValue`/
  `onChanged` for a `RadioGroup` ancestor (Flutter 3.41.9). No new files, no new
  dependencies. `flutter analyze` clean; 48 tests still green (widget tests are
  Phase 9). See the change log
  `change_log/20260721_191330_phase7-settings-about.md`.
- 2026-07-21 — Phase 8 done. Wired the Panchang tab into navigation. Added
  `screens/home_shell.dart` (a pure bottom-nav shell holding the go_router
  `StatefulNavigationShell`) and wrapped `/` (Clock) and `/panchang` in a
  `StatefulShellRoute.indexedStack` in `core/router.dart`; `/settings` and
  `/about` stay outside the shell and open full-screen as before. Replaced the
  Panchang placeholder body with a cleaner "not ready yet" note. Panchang stays
  decoupled — `HomeShell` and `PanchangScreen` import no clock provider, solar
  service, or dharma model. No real Panchang math yet (separate concern). No new
  dependencies. `flutter analyze` clean; 48 tests still green (widget tests are
  Phase 9). See the change log
  `change_log/20260721_192104_phase8-panchang-tab.md`.
- 2026-07-21 — Phase 9 done. Filled the two remaining test gaps and made
  `test/` mirror `lib/`. Added `test/models/saved_location_test.dart` (JSON
  round-trip, defensive `fromJson`, equality, and `toString` hides coordinates)
  and `test/models/display_settings_test.dart` (`DisplayMode` storage
  round-trip + corrupt-pref fallback). Added `test/screens/clock_screen_test.dart`
  (readout renders, saved vs midnight-anchored footer, and the analog/digital
  display modes hide the readout/dial) and `test/screens/settings_screen_test.dart`
  (the three cards render and tapping a display option updates the provider).
  The widget tests reuse the existing fake-clock seam (`nowProvider` +
  `effectiveLocationProvider`) and a mock `SharedPreferences`; no `lib/` source
  changed. The settings test uses a tall surface so the lazy `ListView` builds
  the off-screen About card. `flutter analyze` clean; 70 tests green (was 48).
  See the change log `change_log/20260721_194256_phase9-tests.md`.
- 2026-07-21 — Phase 10 partly done (release config). Enabled R8/ProGuard for the
  release build: added `android/app/proguard-rules.pro` (keeps `io.flutter.**`
  and `com.baseflow.geolocator.**` so reflection-only classes are not stripped)
  and set `isMinifyEnabled = true`, `isShrinkResources = true`, and `proguardFiles`
  in `android/app/build.gradle.kts`. Confirmed `.gitignore` already ignores
  `android/key.properties`, `android/*.jks`, `android/*.keystore`, and
  `build/symbols/`. No `lib/` change; `flutter analyze` clean, 70 tests green.
  The remaining Phase 10 steps need the developer's release keystore and an
  Android device and are handed off with exact commands (keystore creation, the
  obfuscated split-per-abi APK + app bundle build, built-manifest verification for
  no `INTERNET`/`debuggable`, and the cold-start check). See the change log
  `change_log/20260721_195816_phase10-release-hardening.md`.
- 2026-07-23 — Panchang tab filled in. The tab now shows the five limbs of the
  dharma day at sunrise (vāra, tithi, nakṣatra, yoga, karaṇa) with each limb's
  end time. New: `services/lunar_calculator.dart` (Moon/Sun ecliptic longitude
  from truncated Meeus series + Lahiri ayanāṁśa — fully offline),
  `services/panchang_calculator.dart` (limb at sunrise + bisected end time),
  `models/panchang_day.dart`, `core/constants/panchang_names.dart`, and
  `providers/panchang_providers.dart` (recomputes once per day roll, like the
  hora provider; `null` on a polar/no-location day). `PanchangScreen` renders
  the cards and a friendly no-sunrise message. Tests validate against Meeus
  worked examples and the 2026-08-12 solar eclipse (Amāvāsyā at sunrise, ending
  near the conjunction). `flutter analyze` clean; 108 tests green. See the
  change log `change_log/20260723_075550_panchang-tab-content.md`.

---

## Related documents

- [implementation_plan.md](implementation_plan.md)
- [../CLAUDE.md](../CLAUDE.md)
- [architecture.md](architecture.md)
