# Always show dial + readout; removed the Display setting

**Plan:** plans/20260721_215302_remove-display-mode-setting.md

## What changed

The clock now always shows both the dial and the readout, so the Display
setting (dial only / readout only / both) was removed completely.

1. `lib/screens/clock_screen.dart` — always builds the dial, legend, and
   readout. Removed the `displayModeProvider` watch, the `showDial` /
   `showReadout` flags, and the two now-unused imports.
2. `lib/screens/settings_screen.dart` — removed the **Display** card.
   Settings now has Location, Help, and About.
3. `lib/core/router.dart` — removed the `/settings/display` route and its
   import.
4. Deleted dead files:
   - `lib/screens/display_settings_screen.dart`
   - `lib/providers/settings_providers.dart`
   - `lib/models/display_settings.dart`
5. `lib/core/constants/app_constants.dart` — removed `prefDisplayMode`.
   Any old stored `display_mode` value is simply ignored; no migration.
6. Tests:
   - Deleted `test/models/display_settings_test.dart`,
     `test/providers/settings_providers_test.dart`, and
     `test/screens/display_settings_screen_test.dart`.
   - `test/screens/clock_screen_test.dart` — dropped the `mode` parameter
     and the analog/digital mode tests; one test now checks both the dial
     and the readout always show.
   - `test/screens/settings_screen_test.dart` — expects three cards and
     no Display card.

## Checks

- `dart format .`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 66 tests pass.
