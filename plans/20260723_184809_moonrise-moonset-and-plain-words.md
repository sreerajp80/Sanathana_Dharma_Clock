# Moonrise / moonset on the Panchang tab + plain-language explanations

**Status:** completed

## The issue

1. The Panchang tab has no moonrise / moonset times. Every printed panchang
   carries them.
2. The one-line explanations under each limb are written for astronomers
   ("each 12° the Moon gains on the Sun", "27 arcs of 13°20′"). A common
   reader cannot understand them.

## Files to change

| File | Change |
|------|--------|
| `lib/services/lunar_calculator.dart` | Add the Moon's ecliptic **latitude** (truncated Meeus table 47.B), the obliquity of the ecliptic, and a method giving the Moon's declination + right ascension at an instant. (Rise/set needs where the Moon is in the *sky*, not just along the ecliptic.) |
| `lib/services/moon_rise_set_calculator.dart` (**new**) | Pure service: given lat/lon and the day window (sunrise → next sunrise, UTC), find the moonrise and moonset instants. Method: compute the Moon's altitude at coarse steps (10 min) across the window, spot the sign changes through the standard rise/set altitude (+0.125° for the Moon — its closeness makes this different from the Sun's −0.833°), then bisect each crossing to the second. Either event may be absent on a given day (happens about once a month) — return `null` for the missing one, never invent a time. |
| `lib/models/panchang_day.dart` | Add `moonriseUtc` and `moonsetUtc` (both nullable) to `PanchangDay`. Model stays immutable. |
| `lib/services/panchang_calculator.dart` | Take the new `MoonRiseSetCalculator` in the constructor; `panchangFor` gains `latitudeDeg` / `longitudeDeg` parameters and fills the two new fields. |
| `lib/providers/service_providers.dart` | Register the new service; wire it into `panchangCalculatorProvider`. |
| `lib/providers/panchang_providers.dart` | Pass the effective location's lat/lon into `panchangFor`. (The provider already returns `null` with no location, so lat/lon are always available here.) |
| `lib/screens/panchang_screen.dart` | (a) Show "Moonrise HH:mm · Moonset HH:mm" — as a new card after the header, with "—" for an absent event. (b) Rewrite every `meaning` string and the header line in plain words (below). |
| `test/services/moon_rise_set_calculator_test.dart` (**new**) | Known-value tests: a known city + date → moonrise/moonset within a few minutes of almanac values; a day where one event is absent; polar guard. |
| `test/services/panchang_calculator_test.dart` | Update for the new constructor/params. |

## New plain-language wording (screen)

- Header: "From sunrise HH:mm — each value below is the one at sunrise, and
  the time it changes to the next."
- Vāra: "The day of the week. In the Hindu calendar the day starts at
  sunrise, not midnight."
- Tithi: "The lunar day, which follows the Moon's phase. 30 tithis make one
  full-moon-to-full-moon month."
- Nakṣatra: "The star group the Moon is passing through. The sky path is
  divided into 27 such star groups."
- Yoga: "A period from the combined movement of the Sun and Moon. There are
  27 yogas in a cycle; tradition treats some as good, some as bad."
- Karaṇa: "Half of a tithi. The karaṇa names repeat through the month."
- Moonrise card meaning: "When the Moon comes up and goes down at your
  location, during this dharma day."

## Notes / limits

- Fully offline — the Moon math is more truncated series from Meeus, no
  package, no network (hard rule 1).
- Accuracy target: within ~2–3 minutes of published moonrise/moonset. Fine
  for a panchang display.
- Out of scope (possible later additions to make it a fuller almanac):
  lunar month (māsa) name, samvatsara, ṛtu/ayana, Sun/Moon rāśi, festivals.

## Steps

1. Extend `LunarCalculator` (latitude terms, obliquity, declination/RA).
2. Write `MoonRiseSetCalculator` + its tests.
3. Extend `PanchangDay`, `PanchangCalculator`, providers.
4. Update `panchang_screen.dart` (moon card + new wording).
5. `dart format .`, `flutter analyze`, `flutter test`.
6. Write the change log; set this plan `completed`.
