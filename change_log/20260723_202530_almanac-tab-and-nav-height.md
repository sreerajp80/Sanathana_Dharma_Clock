# Almanac tab (yearly view) + shorter bottom tab bar

Implements plan `plans/20260723_201354_almanac-tab-and-nav-height.md`.

## What changed

### New: Almanac tab (fifth bottom tab, route `/almanac`)

A yearly view for the effective location:

- **Sun events card** — the year's six events in date order, each with its
  local date, time, and a one-line plain-word note:
  - March equinox, June solstice, September equinox, December solstice
    (tropical sun longitude crossing 0° / 90° / 180° / 270°).
  - Uttarāyaṇa start (Makara Saṅkrānti, sidereal sun at 270°) and
    Dakṣiṇāyana start (Karka Saṅkrānti, sidereal sun at 90°).
- **Monthly sunrise/sunset table** — twelve expandable month cards; each day
  row shows the date, sunrise, sunset, and day length. Polar gaps show a
  dash. Today's row is tinted and the current month starts open.
- **Year selector** — back/next arrows; starts at the current year.

The whole year is computed once per year/location change — never per tick.
No location → a friendly message, no fake table. No new packages; all math
reuses `SolarCalculator` and `LunarCalculator`.

### Changed: shorter bottom tab bar

`NavigationBar` height set to 64 (default 80) with labels always shown, in
`lib/screens/home_shell.dart`.

## Files

| File                                         | Change                                                                                      |
| -------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `lib/models/almanac_year.dart`               | New — `AlmanacYear`, `AlmanacEvent`, `AlmanacDay` (immutable).                              |
| `lib/services/almanac_calculator.dart`       | New — daily scan + bisection for the six longitude crossings; per-day sunrise/sunset table. |
| `lib/providers/almanac_providers.dart`       | New — calculator provider, selected-year notifier, computed `almanacYearProvider`.          |
| `lib/screens/almanac_screen.dart`            | New — the tab UI (no math in widgets).                                                      |
| `lib/core/router.dart`                       | Fifth `StatefulShellBranch` at `/almanac`.                                                  |
| `lib/screens/home_shell.dart`                | Fifth destination (menu-book icon); bar height 64.                                          |
| `test/services/almanac_calculator_test.dart` | New — 10 tests.                                                                             |

## Checks

- `dart format .` — applied.
- `flutter analyze` — no issues.
- `flutter test` — all 132 tests pass. New tests check the 2026
  equinox/solstice instants against reference values (±2 h), the saṅkrānti
  dates (mid-Jan / mid-Jul), event ordering, the London 21 Jun sunrise/sunset
  row (±3 min), and a polar date yielding null sunrise/sunset/day length.
