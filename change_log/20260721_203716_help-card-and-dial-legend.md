# Change log — Help card, dial legend, back navigation, live-location fix

Implements plan
[plans/20260721_202626_help-card-and-dial-legend.md](../plans/20260721_202626_help-card-and-dial-legend.md).

## Why

Four things were addressed:
1. New users had no explanation of what Ghaṭikā / Vināḍī / Prāṇa mean.
2. The dial gave no key for which hand is which.
3. There was no way back to the clock from the Settings screen.
4. With live location left on, the clock wrongly showed "No location" on startup.

## What changed

**New: [lib/core/constants/dharma_units.dart](../lib/core/constants/dharma_units.dart)**
- A shared constant table (`DharmaUnits`) with a `DharmaUnit` entry for Ghaṭikā, Vināḍī,
  Prāṇa, and Muhūrta — each with its name, the everyday hand it acts like, its approximate
  length, its count, and a one-line description. Used by both the Help card and the legend
  so the wording stays in one place.

**[lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart)**
- Added a `_HelpCard`, placed between the Display and About cards. It shows a short intro
  ("Ghaṭikā : Vināḍī : Prāṇa, like Hour : Minute : Second… starts at local sunrise"), one
  block per unit from `DharmaUnits.all`, and a closing note that the lengths flex with the
  season.

**[lib/screens/clock_screen.dart](../lib/screens/clock_screen.dart)**
- Added a small `_Legend` under the dial (shown only when the dial shows). Each row draws a
  short line in the same colour and thickness as that hand, then the unit name and its
  analogy, e.g. "Ghaṭikā · hour".
- Changed the Settings button from `context.go('/settings')` to `context.push('/settings')`,
  so the Settings AppBar now shows a back arrow and the system back returns to the clock
  (issue 3).
- Made `_AnchorFooter` a `ConsumerWidget` that reads `locationProvider` for the no-anchor
  case: it shows "Getting location…" while fetching, a plain-English failure reason when
  live is on but the last fetch failed, and the old "No location — midnight-anchored day"
  only when live is off and nothing is saved (issue 4, UX). No coordinates are shown.

**[lib/providers/location_providers.dart](../lib/providers/location_providers.dart)**
- `LocationNotifier.build()` now schedules a live fetch (`Future.microtask(refreshLive)`)
  when the persisted `useLive` flag is `true`, so a fresh fix is obtained on startup
  instead of the clock showing "No location" until the switch is re-toggled (issue 4).

## Tests

- [test/screens/settings_screen_test.dart](../test/screens/settings_screen_test.dart) —
  new test that the Help card renders with the unit names.
- [test/screens/clock_screen_test.dart](../test/screens/clock_screen_test.dart) —
  retargeted the two readout checks to the Muhūrta line (unique to the readout), since the
  legend now also contains "Ghaṭikā".
- [test/providers/location_providers_test.dart](../test/providers/location_providers_test.dart)
  — new test that a persisted `useLive: true` fetches a live fix on startup, resolving the
  effective location to the live fix without a manual toggle.

## Checks

- `dart format .` — clean.
- `flutter analyze` — no issues.
- `flutter test` — all 75 tests pass.

## Not done (out of scope)

- No change to the dial hands, the solar/dharma math, colours, or the About screen.
- No change to `LocationService` itself (no last-known-position fallback added).
- No on-device run in this environment; behaviour was verified through the code and the
  unit/widget tests.
