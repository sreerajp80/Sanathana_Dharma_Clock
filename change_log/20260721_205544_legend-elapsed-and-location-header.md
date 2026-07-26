# Change log: civil legend, elapsed-since-sunrise, and top location header

**Implements plan:** `plans/20260721_205544_legend-elapsed-and-location-header.md`

## What changed

1. **Dial legend now shows the civil-time size of each hand.**
   The legend rows changed from `Ghaṭikā · hour` to `Ghaṭikā · 24 minutes`
   (`Vināḍī · 24 seconds`, `Prāṇa · 4 seconds`). The colour bar in front of each
   row is unchanged.

2. **New "after sunrise" reading.**
   The digital readout now shows a line like `3h 24m 10s after sunrise`, computed
   from the current civil time minus today's sunrise (clamped at zero). The same
   phrase was added to the screen-reader label.

3. **Location moved to the top of the clock, with coordinates.**
   The old bottom footer (`_AnchorFooter`) was removed. A new `_LocationHeader`
   sits above the dial. When there is a real location it shows the label
   (`Live location` / `Saved location`) and the coordinates on a second line,
   formatted to 4 decimals (for example `9.9300, 76.2600`). The no-location,
   fetching, and live-failure messages are unchanged and still shown here.

## Files changed

- `lib/core/constants/dharma_units.dart`
  - Added a `civil` field to `DharmaUnit` (short civil-time length) and filled it
    for all four units.
- `lib/screens/clock_screen.dart`
  - Legend uses `unit.civil` instead of `unit.like`.
  - Added the `_sinceSunrise` helper and the "after sunrise" line in the readout
    and the semantic label.
  - Replaced `_AnchorFooter` with `_LocationHeader` (reads
    `effectiveLocationProvider` for source + coordinates, `locationProvider` for
    the no-location states) and placed it at the top of the screen.
- `test/screens/clock_screen_test.dart`
  - Updated the location tests: the label now appears at the top, and the saved
    case also checks the coordinates line.

## Rules honoured

- Coordinates are only *shown* on the user's own screen — never logged or sent
  (CLAUDE.md hard rule 3). The `toString` overrides that omit coordinates are
  untouched, and no logging was added.
- The header reads only providers, never `shared_preferences` or the plugin.
- `dharma_units.dart` stays a pure constant table; the Settings Help card is
  unaffected.

## Verification

- `flutter analyze` — no issues found.
- `flutter test` — all 75 tests passed.
