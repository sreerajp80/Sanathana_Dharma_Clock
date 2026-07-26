# Removed the Muhūrta line from the bottom readout

**Plan:** plans/20260721_214142_remove-muhurta-readout-line.md

## What changed

1. `lib/screens/clock_screen.dart`
   - Deleted the "Muhūrta X / 30 — <name>" `Text` and its spacing from the
     `_Readout` widget. The same information is already painted in the dial's
     center, so the bottom copy was redundant.
   - Removed the now-unused `muhurtaName` local. The `app_constants.dart` and
     `muhurta_names.dart` imports stay — the screen-reader label and the dial
     still use them.
   - The screen-reader semantic label is unchanged. It still speaks the
     Muhūrta, because painted dial text is not readable by screen readers.

2. `test/screens/clock_screen_test.dart`
   - The two tests that used 'Muhūrta' text to detect the readout now use the
     ': Vināḍī' formatting instead, which only the readout line has (the
     legend says 'Vināḍī · 24 seconds', so plain 'Vināḍī' would match both).

## Checks

- `flutter analyze`: no issues.
- `flutter test`: all 78 tests pass.
