# Remove the Muhūrta line from the bottom readout

**Status:** completed

## Issue

The clock screen shows "Muhūrta 20 / 30 — Aśvinī" twice:
- in the dial's center (added recently), and
- in the digital readout below the dial.

The bottom copy is now redundant. The user asked to remove it.

## Files to change

1. `lib/screens/clock_screen.dart`
   - In `_Readout.build`, delete the `Text` that shows
     `'Muhūrta ${d.muhurta + 1} / ${AppConstants.muhurtaPerDay} — $muhurtaName'`
     and the `SizedBox(height: 8)` above it.
   - Remove the now-unused `muhurtaName` local in `_Readout.build`.
   - Remove imports that become unused (`app_constants.dart`, `muhurta_names.dart`)
     only if nothing else in the file still uses them. Note: the semantic label
     and the dial still use them, so they likely stay.
   - Keep the screen-reader semantic label unchanged — it still speaks the
     Muhūrta, which is useful because the dial's painted text is not readable
     by screen readers.

2. `test/screens/clock_screen_test.dart`
   - "both mode" test: 'Muhūrta' text no longer proves the readout shows.
     Use the exact readout line instead, e.g.
     `find.textContaining('Vināḍī')` (readout-only text) or the full
     `'Ghaṭikā X : Vināḍī Y : Prāṇa Z'` string.
   - "analog mode" test: same change — prove the readout is hidden by
     checking the readout-only text is absent, not 'Muhūrta'.

## Plan for the fix

1. Edit the readout widget to drop the Muhūrta line and spacing.
2. Update the two widget tests to use a readout-only marker string.
3. Run `flutter analyze` and `flutter test`; both must be clean.
4. Write the change log.

## Not changing

- The dial center text (stays as-is).
- The semantic (screen reader) label — Muhūrta info stays there.
