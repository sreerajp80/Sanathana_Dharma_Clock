# Always show dial + readout; remove the Display setting

**Status:** completed

## Issue

The Display settings page offers "Dial and readout", "Dial only", and
"Readout only". The user wants the clock to always show both the dial and
the readout. With only one valid choice left, the whole Display setting is
pointless, so the entire feature comes out — the page, the Settings card,
the provider, the model, and the stored preference.

## Files to change

1. `lib/screens/clock_screen.dart`
   - Always show the dial and the readout. Remove the `displayModeProvider`
     watch and the `showDial` / `showReadout` flags.
   - Remove the now-unused imports (`display_settings.dart`,
     `settings_providers.dart`).

2. `lib/screens/settings_screen.dart`
   - Remove the **Display** card. Settings keeps Location, Help, and About.

3. `lib/core/router.dart`
   - Remove the `/settings/display` route and its import.

4. Delete these files (no longer used by anything):
   - `lib/screens/display_settings_screen.dart`
   - `lib/providers/settings_providers.dart`
   - `lib/models/display_settings.dart`

5. `lib/core/constants/app_constants.dart`
   - Remove the `prefDisplayMode` constant. The old stored value (if any)
     is simply ignored from now on — harmless leftover, no migration needed.

6. Tests:
   - Delete `test/models/display_settings_test.dart`,
     `test/providers/settings_providers_test.dart`, and
     `test/screens/display_settings_screen_test.dart`.
   - `test/screens/clock_screen_test.dart`: drop the `mode` parameter and
     the "digital mode" / "analog mode" tests; keep one test that both the
     dial and the readout always show.
   - `test/screens/settings_screen_test.dart`: expect three cards, not four,
     and no Display card.

## Plan for the fix

1. Simplify the clock screen to always build dial + readout.
2. Remove the Display card and route; delete the three dead files.
3. Remove the dead pref constant.
4. Update / delete the tests as listed.
5. Run `flutter analyze` and `flutter test`; both must be clean.
6. Write the change log.

## Not changing

- The dial and readout widgets themselves.
- The saved-location settings and prefs.
