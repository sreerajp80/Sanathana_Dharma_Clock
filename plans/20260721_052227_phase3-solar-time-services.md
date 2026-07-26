# Phase 3 — Solar and time services

**Status:** completed

Build the pure math at the heart of the clock: the sunrise calculation and the mapping
from civil time to Ghaṭikā : Vināḍī : Prāṇa : Muhūrta and back. No UI, no plugins, no
`shared_preferences`. This follows Phase 2 (core models) in
[../docs/implementation_plan.md](../docs/implementation_plan.md) §Phase 3.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · the time-unit math and core mapping in
[../docs/Sanathana_Dharma_Clock-Idea.md](../docs/Sanathana_Dharma_Clock-Idea.md) §1, §4, §6 ·
the service and testing rules in [../docs/architecture.md](../docs/architecture.md) §7, §17, §18.

---

## What is the issue

Phase 2 left the immutable models (`DharmaTime`, `SavedLocation`, `AppConstants`) but no
logic. The clock cannot compute anything yet. Before any UI or state layer can be built,
the app needs three pieces of pure, testable math:

1. **Where does the day start?** — the sunrise for a date at a latitude/longitude, from the
   NOAA solar-position formula, computed entirely on the device (offline rule).
2. **What is the dharma time now?** — the mapping of a civil instant, the anchoring
   sunrise, and the day span onto Ghaṭikā : Vināḍī : Prāṇa : Muhūrta, and the exact reverse.
3. **Which sunrise anchors the current moment, and how long is the day?** — resolving
   today's and tomorrow's sunrise, picking the anchor, and measuring the span, with the
   safe fallbacks (before-sunrise → yesterday's sunrise; polar no-sunrise → 86,400 s).

All of this is pure math. It must be provable by unit tests before the UI is built, as the
plan requires ("Write the first unit tests now so the math is proven before UI is built").

---

## Files to change

| File | Change | Purpose |
|------|--------|---------|
| `lib/core/utils/date_utils.dart` | create | Small pure date/UTC helpers (day start in UTC, add days, Julian day). |
| `lib/services/solar_calculator.dart` | create | `SolarCalculator` — NOAA sunrise formula (UTC) + day resolution (anchor sunrise + span, with fallbacks). |
| `lib/services/time_calculator.dart` | create | `TimeCalculator` — civil ↔ Ghaṭikā:Vināḍī:Prāṇa:Muhūrta (elastic span), reversible. |
| `test/core/utils/date_utils_test.dart` | create | Tests for the date helpers. |
| `test/services/solar_calculator_test.dart` | create | Sunrise-vs-NOAA test + polar and before-sunrise edge cases. |
| `test/services/time_calculator_test.dart` | create | Mapping test + reverse (reversible) + day-boundary behaviour. |
| `docs/implementation_progress.md` | edit (in the change-log step) | Tick Phase 3 boxes; update status. |

No existing `lib/` file is edited. New folders `test/core/utils/` and `test/services/` are
created to mirror `lib/` (architecture §17).

---

## The plan for each file

### 1. `lib/core/utils/date_utils.dart`

Pure, dependency-free date/UTC helpers. No Flutter import, no service dependency, so they
stay trivially testable. A single `abstract final class DateUtils` (not instantiable) with
static methods:

- `DateTime startOfDayUtc(DateTime instant)` — the UTC midnight of the instant's **UTC**
  calendar date. Used as the midnight fallback anchor and as the base date for sunrise math.
- `DateTime addDays(DateTime date, int days)` — a date `days` before/after another, kept in
  UTC. Used to get yesterday / tomorrow.
- `double julianDay(DateTime dateUtc)` — the Julian Day Number for the NOAA formula
  (standard Fliegel–Van Flandern / NOAA expression), computed from the UTC date at 00:00.

Rationale for a separate file: the solar formula's date arithmetic is easy to get wrong and
is worth testing on its own; keeping it here matches architecture §4 ("`utils/` — small
helpers (date/UTC math helpers)").

> Naming note: this class is `DateUtils` but the file imports **no** Flutter material, so it
> does not collide with Flutter's `DateUtils`. Callers use `package:` imports and reference
> our class directly. If a later phase mixes material in the same file scope, we rename then;
> for a pure services/test context there is no clash.

### 2. `lib/services/solar_calculator.dart`

Two responsibilities, both pure (no `BuildContext`, no plugins, no UI — architecture §7):

**(a) The NOAA sunrise formula.**

```
DateTime? sunriseUtc(DateTime dateUtc, double latitude, double longitude)
```

- Interprets `dateUtc` as a calendar date (its UTC Y/M/D).
- Implements the standard NOAA solar-position algorithm entirely in UTC:
  Julian day → Julian century → geometric mean longitude & anomaly of the Sun →
  Sun's true longitude → apparent longitude → obliquity (corrected) →
  solar declination → equation of time → **hour angle for sunrise** using the standard
  zenith of **90.833°** (includes refraction + solar radius) →
  sunrise time in minutes from UTC midnight → a UTC `DateTime`.
- **Returns `null`** when the sun does not rise/set on that date at that latitude
  (the `cos(hourAngle)` term falls outside [-1, 1] — polar day / polar night). This is the
  signal the caller uses for the fixed-span fallback (idea doc §6).
- All math in UTC; **no** local-time conversion here — callers convert to local only for
  display, honouring "do all math in UTC" (idea doc §6).

**(b) Resolving the dharma day (anchor sunrise + span), with the safe fallbacks.**

```
SolarDay resolveDay(DateTime now, double latitude, double longitude)
```

- Computes the sunrise (UTC) for **yesterday, today, and tomorrow** (local calendar dates,
  derived from `now`).
- Picks the anchor:
  - if `now` is **before** today's sunrise → anchor = **yesterday's** sunrise,
    span = today's − yesterday's sunrise (idea doc §4: "if s < 0, use yesterday's sunrise");
  - else → anchor = **today's** sunrise, span = tomorrow's − today's sunrise.
- **Fallbacks (never crash on a missing anchor — CLAUDE.md hard rule 4):**
  - if any needed sunrise is `null` (polar) → anchor = the UTC midnight of `now`'s date and
    span = a fixed `AppConstants.secondsPerDay` (86,400 s);
  - the span is clamped to a sane positive value so a bad pair can never yield a zero or
    negative span (which would divide-by-zero downstream).
- Returns a small immutable `SolarDay { DateTime sunrise; Duration span; bool isPolar; }`
  value defined in this file (kept private to the service layer; the UI reads `DharmaTime`,
  not `SolarDay`). `sunrise` is stored in UTC; callers convert with `.toLocal()` for the
  readout.

> Why `resolveDay` lives in the service, not in `utils`: it needs the `SolarCalculator`
> itself (it calls the formula three times). Utils stays pure date arithmetic with no service
> dependency, keeping the dependency direction clean (architecture §8).

The `TimeCalculator` still takes plain `sunrise` + `span` values (not a `SolarDay`), so its
mapping stays independently testable and reversible.

### 3. `lib/services/time_calculator.dart`

The elastic-span mapping from idea doc §4, and its exact reverse. Pure — takes only values,
returns a `DharmaTime`. A class `TimeCalculator` with:

```
DharmaTime toDharmaTime({
  required DateTime now,
  required DateTime sunrise,
  required Duration span,
})
```

- `s = now - sunrise` in seconds (double, via microseconds for precision).
- Guards: if `s < 0` it is clamped to 0 (the caller — `resolveDay` — is responsible for
  choosing an anchor that keeps `s ≥ 0`; this clamp is just a safety net). `span` is assumed
  positive (guaranteed by `resolveDay`).
- `ghatikaLen = span / 60`; `fraction = (s / span)` clamped to `[0, 1)`.
- `G = floor(s / ghatikaLenSec)` → 0–59 (clamped to 59 at the very end of the day);
  `V = floor(remainder / (ghatikaLenSec / 60))` → 0–59;
  `P = floor(remainder / (ghatikaLenSec / 360))` → 0–5;
  `M = G ~/ 2` → 0–29.
  This is exactly the idea-doc §4 pseudo-code, using
  `AppConstants.ghatikaPerDay / vinadiPerGhatika / pranaPerVinadi`.
- Returns `DharmaTime(ghatika:G, vinadi:V, prana:P, muhurta:M, fraction:frac, span:span,
  ghatikaLen: ghatikaLen as Duration, sunrise: sunrise)`.

```
DateTime toCivilTime({
  required int ghatika,
  required int vinadi,
  required int prana,
  required DateTime sunrise,
  required Duration span,
})
```

- The exact reverse: `seconds = ghatika*ghatikaLenSec + vinadi*(ghatikaLenSec/60)
  + prana*(ghatikaLenSec/360)`, then `sunrise + seconds`. This returns the civil instant at
  the **start** of that Ghaṭikā:Vināḍī:Prāṇa cell, so `reading → civil → reading` round-trips
  to the same reading (the "reversible" requirement).

No Muhūrta argument in the reverse (Muhūrta is derived from Ghaṭikā, so it carries no extra
information). Both methods use `microseconds` internally to avoid float drift.

### 4–6. Tests (Phase 9 items pulled forward, as Phase 3 requires)

- `test/core/utils/date_utils_test.dart` — `startOfDayUtc` strips the time and stays UTC;
  `addDays` crosses a month boundary correctly; `julianDay` matches a known reference
  (e.g. 2000-01-01 12:00 UT → JD 2451545.0, checked at the date's noon convention used).
- `test/services/solar_calculator_test.dart`
  - **Sunrise vs NOAA reference** — a known lat/lon/date compared to a published NOAA
    sunrise value within a small tolerance (≈ ±2 min; the simple NOAA formula is good to
    about a minute). The exact reference location, date, and expected UTC time are fixed in
    the test at implementation time from the NOAA solar calculator.
  - **Polar no-sunrise** — a high latitude on a solstice returns `null` from `sunriseUtc`,
    and `resolveDay` there yields `isPolar == true`, `span == 86,400 s`, and a midnight
    anchor.
  - **Before-sunrise anchor** — with `now` set a little before today's sunrise, `resolveDay`
    anchors to **yesterday's** sunrise and the resulting `s` is non-negative.
- `test/services/time_calculator_test.dart`
  - **Mapping** — a civil time + sunrise + a chosen span maps to the exact expected
    Ghaṭikā:Vināḍī:Prāṇa:Muhūrta (worked by hand for an elastic span, e.g. span = 90,000 s).
  - **Reverse / reversible** — feeding a reading through `toCivilTime` then back through
    `toDharmaTime` returns the same reading, for both a 24 h span and an elastic span.
  - **Day-boundary** — at `s = 0` the reading is `0:0:0 (M0)`; just before the span end it is
    `59:59:5 (M29)` with `fraction < 1`.

---

## How this respects the hard rules

- **Offline only / open source only** — no packages are added. The NOAA formula is written
  directly in Dart (architecture §14 decision: "hand-written NOAA formula, no package, no
  network"). No `INTERNET`, no networking dependency.
- **Never crash on a missing anchor** — `resolveDay` handles `null` sunrise (polar) with the
  fixed 86,400 s span and a midnight anchor, and clamps the span positive, so downstream
  division is always safe (CLAUDE.md hard rule 4; idea doc §6).
- **UTC math, local only for display** — every calculation is in UTC; no local conversion in
  the services. The stored `sunrise` is UTC and callers convert for the readout.
- **Layer boundaries** — services hold the solar/mapping math and know nothing about
  `BuildContext`, routes, UI strings, or `shared_preferences` (architecture §7, §8).
- **Immutable models** — `DharmaTime` and the new `SolarDay` are immutable value types;
  a reading is computed fresh, never mutated.

## Style

- `package:sanathana_dharma_clock/...` imports only; single quotes; `final` locals; `const`
  where possible; `abstract final class` for the non-instantiable helper — matching
  `app_constants.dart` and `config_service.dart`.
- Files `snake_case.dart`, classes `PascalCase`, methods `camelCase`.
- Doc comments on every public member, in the same voice as the existing files.

## Verification

- `dart format .` applied.
- `flutter analyze` — must stay clean (zero warnings).
- `flutter test` — the new tests must pass (this is the first phase with tests, per the
  plan: "from Phase 3 on, its tests passing").

---

## After implementation

- Write a change log to `change_log/` referencing this plan.
- Tick the Phase 3 boxes in
  [../docs/implementation_progress.md](../docs/implementation_progress.md) and update the
  overall-status line (Phases 1–3 done).
