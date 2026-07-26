# Clock screen: civil legend, elapsed-since-sunrise, and top location header

**Status:** completed

## What the user asked

1. In the dial legend, show the civil-time size of each hand instead of the
   "hour / minute / second" analogy. For example show **Ghaṭikā · 24 minutes**.
   Keep the small colour bar in front of each row.
2. Show how many **hours, minutes, and seconds after sunrise** it is right now.
3. Show the **live location in the upper part of the clock** screen. The user
   chose: show the **status label plus the coordinates** at the top, and
   **remove the old bottom footer**.

## The issue

- The legend today reads `Ghaṭikā · hour`, `Vināḍī · minute`, `Prāṇa · second`
  (from `DharmaUnit.like`). The user wants the civil-time length instead.
- There is no reading of the time elapsed since today's sunrise.
- The location indicator (`_AnchorFooter`) sits at the **bottom** and never
  shows coordinates.

## Files to change

1. `lib/core/constants/dharma_units.dart`
   - Add a new short field `civil` to `DharmaUnit` (e.g. `'24 minutes'`).
   - Fill it for all four units: Ghaṭikā `'24 minutes'`, Vināḍī `'24 seconds'`,
     Prāṇa `'4 seconds'`, Muhūrta `'48 minutes'`. These are the same approximate
     lengths already in `approx`, just without the word "about".

2. `lib/screens/clock_screen.dart`
   - **Legend:** change the `_LegendItem` text from `'${unit.name} · ${unit.like}'`
     to `'${unit.name} · ${unit.civil}'`. Keep the colour bar exactly as is.
   - **Elapsed since sunrise:** in `_Readout`, add a line under the Civil/Sunrise
     line showing the time since sunrise, computed as
     `snapshot.civilTime.difference(snapshot.dharma.sunrise)`, formatted as
     `Xh Ym Zs after sunrise`. Add a small `_sinceSunrise` helper for the
     `Duration → "Xh Ym Zs"` text.
   - **Location header at top:** add a new `_LocationHeader` (a `ConsumerWidget`)
     as the **first** child of the main `Column`, before the dial. It reads
     `effectiveLocationProvider` (for source + coordinates) and, for the
     no-location / fetching / failed states, `locationProvider` — reusing the
     exact wording that `_AnchorFooter` uses today. When there is an effective
     location it also shows the coordinates on a second line, formatted to 4
     decimals as `lat, lon`.
   - **Remove** the `_AnchorFooter` widget and its use at the bottom of the
     `Column` (its live-failure message logic moves into `_LocationHeader`).
   - **Semantic label:** add the "… hours … minutes … seconds after sunrise"
     phrase to `_semanticLabel` so screen readers get the new reading too.

3. `test/screens/clock_screen_test.dart`
   - Update the two footer tests: the label now appears at the **top**, and for
     the saved case the coordinates line is also shown. Adjust the expected text
     (still expect `find.text('Saved location')` and the no-location message,
     which stay the same strings, just relocated). Add a check that the
     coordinates line (e.g. `9.9300, 76.2600`) shows for the saved case.

## Notes / rules honoured

- **Privacy:** coordinates are only *displayed* on the user's own screen. We
  never *log* or *send* them. The `toString` overrides that omit coordinates stay
  untouched, and no logging is added. A short code comment will note this.
- **Layering:** the header reads providers only (never `shared_preferences` or
  the plugin), matching the current `_AnchorFooter` pattern.
- `dharma_units.dart` stays a pure constant table; the Settings Help card is
  unaffected (it uses `approx`/`count`/`description`, not `civil`).
- Legend and Help card still share the one `DharmaUnits` table, so they cannot
  drift.

## After implementing

- Run `flutter analyze` (must be clean) and `flutter test`.
- Write a change log in `change_log/`.
