# Architecture — Sanathana Dharma Clock

This document describes the design of the Sanathana Dharma Clock app. Read it before changing
structure, screens, state, services, models, repositories, or the clock math.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · the product idea in
[Sanathana_Dharma_Clock-Idea.md](Sanathana_Dharma_Clock-Idea.md) · the master rules in
[guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)
and the folder rules in [guidelines/guideline.md](guidelines/guideline.md).

---

## 1. Scope

- Product: Sanathana Dharma Clock
- Repository type: `application`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension` — the app is shipped to real users / stores.
  - `Sensitive Data Extension` — the app reads and stores the user's location (moderate PII).
- Platforms: `Android` (only, for now).

---

## 2. Goals And Non-Goals

### Goals

- Show the current time in the Sanātana Dharma (Vedic) system — Ghaṭikā : Vināḍī : Prāṇa — and
  always show the correct civil time next to it.
- Start each day at **local sunrise** and split it into 60 elastic Ghaṭikā (the "Sunrise,
  proportional" model, Design C in the idea doc).
- Work **fully offline**. The sunrise math is computed on the device; no internet is used.
- Let the user save a location once and run from it, or use live GPS when enabled.

### Non-Goals

- No online features, accounts, cloud sync, or ads.
- The Panchang tab stays a separate concern from the clock: it shares the sunrise anchor but
  none of the dial/dharma-time code. Its lunar math lives in its own services.
- No iOS or Windows build for now (Android only).

---

## 3. Architecture Summary

> The app uses a Tier 1 layer-first Flutter structure with **Riverpod** for state management.
> Screens read state from Riverpod providers; providers call services for the clock and solar
> math and a repository for the saved location. Local persistence is limited to a single saved
> location kept in `shared_preferences` behind a repository. The app is fully offline — the
> Android manifest has no `INTERNET` permission and the solar math is pure on-device
> computation. Navigation uses **go_router**.

---

## 4. Repository Structure

### Current Structure Tier

- `Tier 1` (layer-first).
- Why this tier is appropriate now:
  - The app is small — one main clock screen, a Panchang tab, and a Settings screen.
  - A single developer maintains it; a flat layer-first layout is easy to navigate.

### Top-Level Source Layout

Follows the baseline layout in [guidelines/guideline.md](guidelines/guideline.md) §3.

```text
lib/
|-- core/
|   |-- config/          # AppConfig + ConfigService (About screen). REQUIRED, fixed path.
|   |-- constants/       # app_constants.dart — technical constants (pref keys, thresholds)
|   `-- utils/           # small helpers (date/UTC math helpers)
|-- models/              # dharma_time.dart, saved_location.dart, muhurta_window.dart, hora_window.dart, panchang_day.dart (immutable)
|-- services/            # solar_calculator.dart, lunar_calculator.dart, time_calculator.dart, muhurta_kala_calculator.dart, hora_calculator.dart, panchang_calculator.dart, location_service.dart
|-- repositories/        # location_repository.dart (shared_preferences)
|-- providers/           # Riverpod providers (clock tick, location, settings)
|-- screens/             # clock_screen.dart, muhurta_screen.dart, hora_screen.dart, panchang_screen.dart, settings_screen.dart, about_screen.dart
|-- widgets/             # dharma_dial_painter.dart, moon_phase_painter.dart, cards
|-- theme/               # app_theme.dart — vermillion-on-chandan ThemeData
`-- main.dart
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/core/config/` | Load About-screen values from `assets/config/app_config.json`. Fixed pattern. |
| `lib/models/` | Immutable data (dharma time reading, saved location). No logic beyond mapping. |
| `lib/services/` | Solar/sunrise math, dharma-time mapping, GPS access. No `BuildContext`, no UI. |
| `lib/repositories/` | Read/write the saved location via `shared_preferences`. |
| `lib/providers/` | App state and the once-per-second tick; wire services to screens. |
| `lib/screens/` | Full-page UI. Read providers; never call services or prefs directly. |
| `lib/widgets/` | Reusable UI, including the `CustomPainter` dial. No business logic. |

---

## 5. App Initialization Sequence

Order of steps in `main()` before `runApp`.

| Step | Code / Call | Notes |
|------|-------------|-------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Always first |
| 2 | Flavor config load | `AppFlavorConfig.instance` from `FLUTTER_APP_FLAVOR` |
| 3 | Load `SharedPreferences` instance | Needed by the location repository |
| 4 | Load `AppConfig` via `ConfigService.loadAndVerify()` | About-screen values |
| 5 | Build `ProviderScope` with overrides (prefs, config) | Riverpod root |
| 6 | `runApp(...)` | |

No database open step — the app has no database (see §11).

---

## 6. App Lifecycle Behavior

| Lifecycle State | App Behavior |
|----------------|--------------|
| `resumed` | Restart the clock tick; recompute sunrises if the date changed while paused. |
| `inactive` | No action. |
| `paused` | Stop the clock tick timer to save battery. |
| `detached` | No action needed (no open file handles or DB). |
| Memory pressure | No large caches to clear. |

---

## 7. Offline Behavior

- **Connectivity requirement**: `fully offline`.
- **Network permission**: `INTERNET permission absent`.
- **Offline data source**: `shared_preferences` (saved location only). No network data.

Because the app is fully offline:
- The merged Android release manifest MUST NOT contain
  `<uses-permission android:name="android.permission.INTERNET" />`. Verify on the built APK with
  `aapt2 dump permissions build/app/outputs/apk/prod/release/<apk>` or by opening the merged
  manifest in Android Studio (Build → Analyze APK).
- The solar/sunrise math is written directly (NOAA solar-position formula) — no package that
  makes network calls is used.
- Location is read from device GPS via the location plugin; GPS is not network.

---

## 8. State Management

- Primary pattern: **Riverpod**.
- Why this pattern was chosen:
  - A single ticking clock value is naturally a provider that many widgets watch.
  - Easy to override providers (prefs, config, a fake clock) in tests.
- State boundaries:
  - Widgets own: layout, painting, reading provider values.
  - State layer (providers) owns: the current dharma-time reading, the active location, settings.
  - Services own: solar math, dharma-time mapping, GPS access.

---

## 9. Data Flow

```text
Widget (screen) -> Riverpod provider -> Service (solar / time / location) -> Repository -> shared_preferences
```

### Rules

- Widgets must not know: the solar formula, `shared_preferences` keys, or plugin APIs.
- Services must not know: navigation routes, widget code, or UI strings.
- Repositories abstract: the `shared_preferences` read/write for the saved location.

---

## 10. Error Handling Architecture

- **Global error handler**: `FlutterError.onError` and `PlatformDispatcher.instance.onError`
  configured in `main()`.
- The app must never crash on missing location or a date with no sunrise (see §21 and the idea
  doc §6 edge cases). Each of these has a safe fallback.

| Situation | Handling |
|-----------|----------|
| No location / permission denied | Fall back to the saved location, or to a plain midnight-anchored day. |
| Polar day with no sunrise | Use a fixed 86,400 s span for that day. |
| `now` before today's sunrise | Anchor to yesterday's sunrise. |

---

## 11. Domain Model

The app has **no SQLite database**. State is small and either computed or stored as one
key-value record. This section documents the in-memory models.

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `DharmaTime` | One reading: Ghaṭikā, Vināḍī, Prāṇa, Muhūrta + `span`, `ghatikaLen`, `sunrise`. | No | Computed each tick from civil time + sunrise. |
| `SavedLocation` | Latitude, longitude, and a label for the saved place. | No | Persisted in `shared_preferences`. |
| `MuhurtaWindow` | One named window: name, kind (auspicious/inauspicious/neutral), UTC start/end. | No | Built by `MuhurtaKalaCalculator` for the 30 muhūrtas and the daytime kālas (Abhijit, Rāhu, Yamagaṇḍa, Gulika). |
| `HoraWindow` | One horā (planetary hour): ruling planet, day/night flag, UTC start/end. | No | Built by `HoraCalculator` — 12 day horās (sunrise→sunset) + 12 night horās (sunset→next sunrise); lords from `HoraNames` (weekday lord first, then the fixed horā order). |
| `AppConfig` | About-screen values from `app_config.json`. | No | Fixed pattern (guideline §1). |

### Serialization Strategy

- JSON models: `SavedLocation` (to/from a small JSON string in prefs) and `AppConfig`.
- Database models: N/A — no database.

---

## 12. Dependency Management And Injection

- DI approach: Riverpod provider tree. `SharedPreferences` and `AppConfig` are provided at the
  root `ProviderScope` and read by other providers.
- App-root dependencies: `SharedPreferences` instance, `AppConfig`.
- Test replacement strategy: override providers with fakes (a fake clock, an in-memory prefs, a
  stub location service).

---

## 13. Navigation

- Navigation approach: **go_router**.
- Route definition location: `lib/core/router.dart` (or `lib/router.dart`).
- Routes: `/` (clock), `/muhurta` (Muhurta & Kalas), `/hora` (planetary hours), `/panchang`,
  `/settings`, `/about`.
  The first four are tabs inside a `StatefulShellRoute` with a bottom `NavigationBar`.
- Protected-route strategy: N/A — no auth or app lock.
- Deep-link support: not required.

---

## 14. Persistence And External Systems

### Local Storage

- Database: `none`.
- Key-value storage: `shared_preferences` — stores the saved location and display settings.
- Secure storage: `none` — no secrets are stored.

### Network

- Network client: `none`.
- Offline behavior: `fully offline`.

### Platform Channels Or Native Integrations

- Location plugin (e.g. `geolocator`): read the device GPS position for live location.

---

## 15. Environment And Build Model

- Flavors used: `dev` / `prod`.
- Runtime config mechanism: native flavor + `FLUTTER_APP_FLAVOR` read by `AppFlavorConfig`.
- Build outputs supported:
  - debug apk (dev)
  - release apk split-per-abi (prod)
  - app bundle (prod, Play Store)
- Obfuscation: enabled for prod release — symbols stored at
  `build/symbols/android-prod-<version>/`.

See [release_process.md](release_process.md) and
[guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).

---

## 16. UI System

- Theme source of truth: `lib/theme/app_theme.dart` — a single `ThemeData`.
- Colour theme (from the idea doc §8): **vermillion** (sindūr, ≈ `#E34234`) foreground/accent on
  a **chandan** (sandalwood, ≈ `#F1E4C3`) background. Used across clock, Panchang, and Settings.
- Layout: modern, card-based, rounded corners, soft shadows, generous spacing.
- The analog dial is drawn by `DharmaDialPainter` (a `CustomPainter`), a sibling of the existing
  `moon_phase_painter.dart`.
- Accessibility expectations:
  - Minimum touch target: 48 × 48 dp.
  - Colour contrast: check vermillion-on-chandan meets WCAG AA (4.5:1 for normal text); darken
    the vermillion for small text if needed.
  - Screen reader: give the clock a text label with the current reading.
  - Text scale: verify Settings and readout at 1.0×, 1.5×, 2.0×.

---

## 17. Logging

- Logger implementation: `logger` package or a thin wrapper (see engineering standard §14).
- Verbose logging gate: `AppFlavorConfig.enableVerboseLogging` (on in dev, off in prod).
- Log level in production: `info` and above.
- Sensitive data policy: never log exact latitude/longitude at `info` level or above. See
  [security.md](security.md) §9.

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | Solar and dharma-time math | The highest-value tests — see below. |
| Unit | `SavedLocation` JSON round-trip | Encode → decode → equal. |
| Widget | Clock readout and Settings cards | Render with a fake clock provider. |
| Integration | Offline scenario | Airplane mode simulated; verify no network attempt. |

### Test Layout

```text
test/
|-- services/
|-- models/
|-- widgets/
`-- helpers/
```

### Critical Test Areas

- **Sunrise math** — known lat/lon/date → expected sunrise (compare against NOAA reference).
- **Dharma-time mapping** — a civil time + sunrise + span maps to the exact
  Ghaṭikā:Vināḍī:Prāṇa, and back (reversible).
- **Edge cases** — before-sunrise anchor, polar no-sunrise 86,400 s span, day-boundary roll.

---

## 19. Operational Constraints

- Minimum supported OS: Android — set `minSdk` in `CLAUDE.md` identity table.
- Performance constraints:
  - Cold startup under 2 seconds to first frame (release).
  - The dial repaints once per second (Prāṇa is 4 s, fraction is smooth) — keep the painter cheap.
  - Recompute sunrises **once per day**, not every tick (idea doc §6).
- Team constraints: single developer.
- Offline constraints: no `INTERNET` permission, no network packages.

---

## 20. Decisions And Tradeoffs

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| Day model | Sunrise, proportional (Design C) | Most faithful to classical texts; no mid-day jump. | Ghaṭikā length changes with season. |
| Sunrise math | Hand-written NOAA formula | No package, no network, full control. | Must be tested carefully against a reference. |
| Storage | `shared_preferences` only | One tiny record (saved location); no DB needed. | Not suitable if data grows later. |
| State | Riverpod | Clean provider for the ticking clock; testable. | Small learning cost vs plain `setState`. |

---

## 21. Known Risks And Follow-Ups

- Risk: sunrise math error gives a wrong dial.
  Mitigation: unit tests with known reference values before release.
- Risk: location permission denied leaves the clock without an anchor.
  Mitigation: fall back to saved location, then to a midnight-anchored day.
- Risk: contrast of vermillion-on-chandan fails WCAG AA for small text.
  Mitigation: measure contrast; use a darker vermillion shade for small text.

---

## 22. Related Documents

- [../CLAUDE.md](../CLAUDE.md)
- [Sanathana_Dharma_Clock-Idea.md](Sanathana_Dharma_Clock-Idea.md)
- [security.md](security.md)
- [release_process.md](release_process.md)
- [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)
- [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md)
- [guidelines/guideline.md](guidelines/guideline.md)
