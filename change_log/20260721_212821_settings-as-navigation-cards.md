# Settings page as navigation cards

Implements plan `plans/20260721_212246_settings-as-navigation-cards.md`.

## What changed

The Settings page used to show each section's content inline (Location controls,
Display choices, and the whole Help text), with only About working as a tappable
card. Now every section is a tappable card that opens its own full page, and the
Help page is itself a menu of one card per time unit.

### New files

- `lib/widgets/nav_card.dart` — `NavCard`, a reusable tappable menu card (icon,
  title, subtitle, chevron). Shared by the Settings page and the Help page so
  every card looks the same. It holds no navigation logic; the caller passes the
  `onTap`.
- `lib/screens/location_settings_screen.dart` — `LocationSettingsScreen`. The
  live/saved toggle, status tile, saved-place tile, and save/clear buttons moved
  here unchanged from the old `_LocationCard`. Still goes through
  `locationProvider` only.
- `lib/screens/display_settings_screen.dart` — `DisplaySettingsScreen`. The
  analog/digital/both radio choices moved here from the old `_DisplayCard`.
- `lib/screens/help_screen.dart` — `HelpScreen`. Now a menu: a short intro, one
  `NavCard` per unit from `DharmaUnits.all` (Ghaṭikā, Vināḍī, Prāṇa, Muhūrta),
  and the closing "approximate lengths" note. Tapping a unit opens its detail.
- `lib/screens/help_topic_screen.dart` — `HelpTopicScreen`. One reusable detail
  page for all four units, chosen by index into `DharmaUnits.all`. Shows the
  unit name, its length line, and full description. Falls back to the first unit
  for an out-of-range index.

### Changed files

- `lib/screens/settings_screen.dart` — rewritten as a plain menu of four
  `NavCard`s (Location, Display, Help, About). Now a `StatelessWidget`; all the
  old inline section widgets and their provider/model imports were removed.
- `lib/core/router.dart` — added four full-screen routes outside the shell:
  `/settings/location`, `/settings/display`, `/settings/help`, and
  `/settings/help/:index` (the index is parsed for `HelpTopicScreen`).

### Tests

- `test/screens/settings_screen_test.dart` — rewritten to check the four
  navigation cards and their chevrons render.
- Added `test/screens/location_settings_screen_test.dart`,
  `display_settings_screen_test.dart`, `help_screen_test.dart` (including that
  tapping a topic opens its detail), and `help_topic_screen_test.dart`
  (including the out-of-range fallback).

## Scope

Pure UI/navigation refactor. No provider, service, model, or clock-math change;
no new packages; no manifest or permission change. All Help text still comes
from the shared `DharmaUnits` table.

## Verification

- `dart format .` — clean.
- `flutter analyze` — "No issues found!".
- `flutter test` — all 78 tests passed.
