# Moonrise / moonset on the Panchang tab + plain-language explanations

Implements [plans/20260723_184809_moonrise-moonset-and-plain-words.md](../plans/20260723_184809_moonrise-moonset-and-plain-words.md).

## What changed

### New: moonrise and moonset

- `lib/services/lunar_calculator.dart` — added the Moon's ecliptic latitude
  (truncated Meeus table 47.B with its additive terms), the mean obliquity,
  and `moonEquatorial()` giving the Moon's right ascension + declination.
  Rise/set needs where the Moon stands in the sky, not just along the
  ecliptic.
- `lib/services/moon_rise_set_calculator.dart` (**new**) — pure service.
  Samples the Moon's altitude every 10 minutes across the sunrise →
  next-sunrise window, finds crossings of the Moon's standard rise/set
  altitude (+0.125°), and bisects each one down to the second. Either event
  can be absent on a given day (the Moon's own day is ~24 h 50 min) — that
  returns `null`, never an invented time (hard rule 4). Fully offline; no
  package (hard rule 1).
- `lib/models/panchang_day.dart` — `PanchangDay` gains nullable
  `moonriseUtc` / `moonsetUtc`.
- `lib/services/panchang_calculator.dart` — takes the new calculator;
  `panchangFor` gains `latitudeDeg` / `longitudeDeg` and fills the two new
  fields.
- `lib/providers/service_providers.dart` — new
  `moonRiseSetCalculatorProvider`, wired into `panchangCalculatorProvider`.
- `lib/providers/panchang_providers.dart` — passes the effective location's
  lat/lon.
- `lib/screens/panchang_screen.dart` — new "Moon" card after the header
  showing Moonrise and Moonset side by side ("—" when absent; the date is
  added when the event falls on the next calendar date).

### Rewritten: plain-language wording

All the `meaning` lines and the header line on the Panchang tab now use
plain words, e.g. Tithi: "The lunar day, which follows the Moon's phase.
30 tithis make one full lunar month." Nakṣatra: "The star group the Moon is
passing through…". The degree/arc jargon is gone.

## Tests

- `test/services/moon_rise_set_calculator_test.dart` (**new**) — physical
  checks at Ujjain: events always inside the day window; successive
  moonrises spaced one lunar day apart; full-moon day (2026-07-29) rises
  near sunset; new-moon day (2026-08-12) sets near sunset; safe-fallback
  cases (empty window, short window, polar latitude).
- `test/services/panchang_calculator_test.dart` — updated for the new
  constructor and parameters.

`dart format .` clean, `flutter analyze` zero issues, `flutter test`
115/115 passing.

## Not done (noted as future work in the plan)

Māsa (lunar month) name, samvatsara, ṛtu/ayana, Sun/Moon rāśi, festivals.
