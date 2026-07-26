# Plan: Fill in the Panchang tab (tithi, nakṣatra, yoga, karaṇa, vāra)

**Status:** completed

## The issue

The Panchang tab ([lib/screens/panchang_screen.dart](../lib/screens/panchang_screen.dart))
is still a placeholder. It should show the five limbs of the daily Panchang:

1. **Vāra** — the weekday (runs sunrise → next sunrise).
2. **Tithi** — the lunar day. One tithi = 12° of separation between the Moon's and
   the Sun's ecliptic longitude. 30 tithis per lunar month, in two pakṣas.
3. **Nakṣatra** — the lunar mansion. The Moon's *sidereal* longitude divided into
   27 arcs of 13°20′ each.
4. **Yoga** — the *sum* of the Sun's and Moon's sidereal longitudes divided into
   27 arcs of 13°20′ each.
5. **Karaṇa** — a half-tithi (6° of separation). 60 per month: 7 movable names
   repeating 8 times plus 4 fixed ones at the month's ends.

The missing piece is the **Moon's ecliptic longitude**. The Sun's apparent
longitude is already computed inside `SolarCalculator` but not exposed. Both will
be computed on the device, fully offline (hard rule 1), using well-documented
truncated Meeus series (Astronomical Algorithms, ch. 25 for the Sun, ch. 47 for
the Moon).

## Approach (the math, in plain words)

- **Sun longitude**: same terms `SolarCalculator` already uses (geometric mean
  longitude + equation of centre + apparent correction). We will expose it as a
  method instead of duplicating the constants.
- **Moon longitude**: Meeus ch. 47 truncated series — the mean longitude L′ plus
  the largest periodic terms (the ~25 biggest longitude terms). This gives
  roughly arc-minute accuracy, which moves a tithi/nakṣatra end time by only a
  minute or two — fine for a Panchang display.
- **Sidereal (nirayana) longitudes**: nakṣatra and yoga need sidereal values, so
  we subtract the **Lahiri ayanāṁśa**, computed with the standard linear
  approximation (≈ 23.85° at J2000 + ~50.29″/year of precession). Tithi and
  karaṇa use the Moon−Sun *difference*, so the ayanāṁśa cancels there.
- **Which values to show**: like a printed Panchang, each limb is the one in
  force **at the day's sunrise**, plus the time it ends. End times are found by
  stepping forward from sunrise and bisecting the boundary crossing (the
  Moon−Sun difference moves ~12°/day, so this converges fast).
- If a limb's end falls after the next sunrise, we show "runs past next sunrise"
  style wording instead of a time on the wrong day.

## Files to change

New files:

1. `lib/core/constants/panchang_names.dart` — pure name tables (like
   `HoraNames`): 30 tithi names with pakṣa, 27 nakṣatras, 27 yogas, 11 karaṇa
   names + the fixed 60-slot karaṇa ordering, 7 vāra names.
2. `lib/services/lunar_calculator.dart` — pure math service: Moon geocentric
   ecliptic longitude (truncated Meeus ch. 47), Sun apparent longitude
   (shared terms), Lahiri ayanāṁśa. No plugins, no UI, all UTC.
3. `lib/services/panchang_calculator.dart` — pure service that turns
   (sunrise instant, next sunrise) into a `PanchangDay`: computes each limb at
   sunrise and bisects its end time. Uses `LunarCalculator`.
4. `lib/models/panchang_day.dart` — immutable model: for each limb its index,
   name, and end time (nullable when past next sunrise), plus vāra.
5. `lib/providers/panchang_providers.dart` — `panchangDayProvider`, mirroring
   `horaDayProvider`: watches only the clock's anchor sunrise/span via
   `select`, so it recomputes once per day roll or location change, never per
   tick. Empty/`null` result on a polar/no-location day (hard rule 4) — the
   screen shows a friendly message.
6. `test/services/lunar_calculator_test.dart` — Moon longitude against Meeus's
   worked example (1992 Apr 12: λ ≈ 133.16°) within tolerance; ayanāṁśa sanity
   check (~24.2° in 2026).
7. `test/services/panchang_calculator_test.dart` — a few known dates checked
   against published Panchang values (tithi/nakṣatra/yoga/karaṇa names at
   sunrise for a known city), plus edge cases (end past next sunrise).

Changed files:

8. `lib/screens/panchang_screen.dart` — replace the placeholder with a card
   list: date + location header, then one card per limb (name, meaning line,
   "until HH:MM" end time). Friendly message when no location / polar day.
9. `lib/providers/service_providers.dart` — add `lunarCalculatorProvider` and
   `panchangCalculatorProvider`.
10. `docs/architecture.md` — remove the "Panchang calculation is left
    untouched" line; note the new services in the layout section.
11. `docs/implementation_progress.md` — mark the Panchang work done.

Not changed: `SolarCalculator` stays as it is (the Sun-longitude terms are
small; `LunarCalculator` carries its own copy of the few shared constants to
keep the services independent). The clock, muhūrta, and hora features are not
touched.

## Layer statement

- `PanchangNames` → `core/constants` (pure tables, like `HoraNames`).
- `LunarCalculator`, `PanchangCalculator` → `services/` (pure math, no
  `BuildContext`, no plugins, no prefs).
- `PanchangDay` → `models/` (immutable).
- `panchangDayProvider` → `providers/`.
- Screen only reads the provider — no math in the widget.

## Checks after implementing

- `flutter analyze` clean, `dart format .`, `flutter test` all green.
- Cross-check one real date's output against a published Panchang
  (e.g. drikpanchang) for a known city.
- Write the change log.

## Out of scope

- Sunrise-anchored *display* only — no month/pakṣa calendar view, no festival
  names, no muhūrta cross-links.
- No Moon latitude/distance, no eclipse or moon-phase imagery work.
