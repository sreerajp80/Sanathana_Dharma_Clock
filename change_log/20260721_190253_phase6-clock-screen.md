# Change log — Phase 6: UI clock screen

**Date:** 2026-07-21
**Implements:** [../plans/20260721_185608_phase6-clock-screen.md](../plans/20260721_185608_phase6-clock-screen.md)
**Plan for the whole build:** [../docs/implementation_plan.md](../docs/implementation_plan.md) (Phase 6)

## What changed

Built the main user interface — the analog dial, the digital readout, the app
theme, and navigation. Before this, the app opened on a Phase 1 placeholder
screen with no theme. The non-UI stack (models, solar/time math, location,
Riverpod state) was already done in Phases 1–5.

### Files added

- **`lib/theme/app_theme.dart`** — one Material 3 light `ThemeData`,
  vermillion-on-chandan. Brand colours are named constants. For WCAG AA, text and
  icons use a darker vermillion `#B32D1F` (≈ 5:1 on the `#F1E4C3` chandan
  background); the bright `#E34234` is kept for the large dial strokes and
  highlights only, where AA-large (3:1) is enough.
- **`lib/core/constants/muhurta_names.dart`** — a pure constant table of the 30
  day-Muhūrta names (index 0 = sunrise), with a `MuhurtaNames.at(index)` lookup
  that clamps so a bad index cannot crash the readout. Added because the
  `DharmaTime` model does not carry the name, and the readout/ring show it.
- **`lib/widgets/dharma_dial_painter.dart`** — `DharmaDialPainter`, a
  `CustomPainter` that draws the face from a `DharmaTime`: a 30-Muhūrta outer ring
  (current one highlighted), 60 Ghaṭikā ticks (every 5th longer), three hands
  (Ghaṭikā, Vināḍī, and a smooth Prāṇa/fraction fast hand), and a "now" marker on
  the rim with sunrise fixed at the top. It takes its colours as arguments (no
  `Theme` lookups) and its `shouldRepaint` compares the reading, so it repaints
  only once per second (architecture §19).
- **`lib/screens/clock_screen.dart`** — the main screen. Watches `clockProvider`
  and `displayModeProvider`, showing the dial and/or the readout per the mode
  (analog / digital / both). The readout follows the idea doc §5 layout. The whole
  reading is wrapped in a `Semantics` label for screen readers, and a small footer
  shows where the anchor came from (live / saved / no-location midnight fallback).
  Civil time and sunrise are formatted with tiny local helpers — no `intl`
  package, so dependencies are unchanged.
- **`lib/screens/panchang_screen.dart`**, **`settings_screen.dart`**,
  **`about_screen.dart`** — minimal placeholder screens so the routes resolve.
  Their real content arrives in Phases 7 (settings, about) and 8 (panchang).
- **`lib/core/router.dart`** — a single `GoRouter` (`appRouter`) with the four
  routes `/`, `/panchang`, `/settings`, `/about` (architecture §13).

### Files changed

- **`lib/main.dart`** — replaced the Phase 1 placeholder home with
  `MaterialApp.router`, wiring `theme: AppTheme.light` and
  `routerConfig: appRouter`. The startup sequence, the `ProviderScope` overrides,
  and the global error handlers are unchanged. Removed the old
  `_ScaffoldPlaceholderScreen`.

## Rules honoured

- **Offline / open source:** no new packages added; no networking.
- **Never crash on a missing anchor:** the `Muhūrta` lookup clamps, and the
  screen shows the midnight-fallback state through `ClockSnapshot.source` /
  `isPolar` instead of failing.
- **Layer boundaries:** the painter and screens read providers only; the painter
  knows nothing of the solar formula or prefs. No business logic moved into the
  UI.
- **Data-driven About:** the About screen is still a placeholder — it will read
  from `AppConfig` in Phase 7; nothing About-related is hard-coded here.

## Verification

- `flutter analyze` — clean, no issues.
- `flutter test` — 48 tests, all green (no test changes this phase; widget tests
  are Phase 9).
- `dart format .` — applied.

## Not done here (later phases)

- Real Settings cards and the data-driven About screen — Phase 7.
- Panchang tab content — Phase 8.
- Widget tests for the clock readout and dial — Phase 9.
- A manual `flutter run --flavor dev` visual check is still recommended before
  release hardening.
