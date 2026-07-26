# Change log — Phase 3: Solar and time services

**Date:** 2026-07-21
**Implements plan:** [../plans/20260721_052227_phase3-solar-time-services.md](../plans/20260721_052227_phase3-solar-time-services.md)
**Phase:** 3 of 10 (see [../docs/implementation_plan.md](../docs/implementation_plan.md))

## What changed

Added the pure clock math — sunrise calculation and the civil ↔ dharma-time mapping —
plus the first unit tests. No UI, no plugins, no `shared_preferences`. All math is in UTC.

### New source files

- `lib/core/utils/date_utils.dart` — `DateUtils` (non-instantiable) with pure date/UTC
  helpers: `startOfDayUtc` (UTC midnight of a date), `addDays` (UTC date arithmetic that
  crosses month boundaries), and `julianDay` (Fliegel–Van Flandern JDN for the solar
  formula; 2000-01-01 → 2451545.0).
- `lib/services/solar_calculator.dart`
  - `SolarDay` — small immutable result type (`sunrise` in UTC, `span`, `isPolar`).
  - `SolarCalculator.sunriseUtc(dateUtc, lat, lon)` — the standard NOAA solar-position
    formula written directly (no package, offline). Returns the UTC sunrise instant, or
    `null` when the sun does not rise/set that date (polar day/night). Latitude north +,
    longitude east +; zenith 90.833°.
  - `SolarCalculator.resolveDay(now, lat, lon)` — picks the anchoring sunrise and the day
    span. Before today's sunrise it anchors to yesterday's; otherwise today → tomorrow.
    Falls back to a midnight anchor and a fixed 86,400 s span when a sunrise is missing
    (polar) or the span is not positive, so the clock never crashes on a missing anchor.
- `lib/services/time_calculator.dart` — `TimeCalculator`
  - `toDharmaTime(now, sunrise, span)` — the elastic-span mapping to
    Ghaṭikā : Vināḍī : Prāṇa : Muhūrta (idea doc §4). `s` is clamped to `[0, span)`;
    a non-positive span falls back to 86,400 s. Returns a `DharmaTime`.
  - `toCivilTime(ghatika, vinadi, prana, sunrise, span)` — the exact reverse, returning the
    start of the cell. The cell start is snapped **up** (`ceil`) to the next whole
    microsecond so it stays inside the requested cell; this makes
    `reading → civil → reading` round-trip exactly, even for an elastic span whose cell
    widths are not whole microseconds.

### New test files (Phase 9 items pulled forward, as Phase 3 requires)

- `test/core/utils/date_utils_test.dart` — `startOfDayUtc`, `addDays` (month boundaries),
  `julianDay` (J2000.0 reference).
- `test/services/solar_calculator_test.dart` — sunrise vs reference (London summer
  solstice ≈ 03:43 UTC within ±3 min; equator/equinox near 06:00 UTC), polar `null`,
  and `resolveDay` polar / normal-day / before-sunrise-anchor cases.
- `test/services/time_calculator_test.dart` — mapping (24 h and elastic spans), reverse and
  reversibility (both spans), and day-boundary behaviour (sunrise, end-of-day saturation,
  before-sunrise clamp).

### Docs

- `docs/implementation_progress.md` — Phase 3 boxes ticked; status overview and notes
  updated to "Phases 1–3 done".

## One deviation from the plan

The reverse (`toCivilTime`) was planned to round the cell start to the nearest microsecond.
Rounding **down** could land just inside the previous cell for an elastic span (the Prāṇa
cell width is not a whole number of microseconds), which broke the reversibility test. It now
snaps **up** with `ceil`, which is guaranteed to stay within the requested cell. Semantics are
unchanged for a whole-second span (the 24 h case is still exact).

## Verification

- `dart format .` applied.
- `flutter analyze` — clean, no issues.
- `flutter test` — all 21 tests pass.

## Not in this phase

Location access, Riverpod wiring, and the UI come in Phases 4–6. `resolveDay` returns UTC
`sunrise` values; converting to local time for display is the caller's job.
