# Settings page as navigation cards

**Status:** completed

## The issue

The Settings page today shows the real content of each section inline: the
**Location** controls, the **Display** radio choices, and the whole **Help**
text all sit open on the Settings page inside titled cards. Only **About** works
as a tappable card that opens its own page.

The user wants every section to look and work like the About card: a short
tappable card on the Settings page that, when tapped, opens a full page with
that section's content. So Help must move out of the Settings page into its own
Help page, and Location and Display must do the same.

## The plan

Turn the Settings page into a simple menu of four tappable cards — **Location**,
**Display**, **Help**, **About** — each opening its own full-screen page.

### New screens (extract existing content, no logic change)

1. `lib/screens/location_settings_screen.dart` — a new `LocationSettingsScreen`.
   Move the current `_LocationCard` body (live/saved switch, status tile, saved
   place tile, save/clear buttons) and its helpers (`_saveCurrent`,
   `_statusMessage`, `_SavedLocationTile`) here. Wrap it in a `Scaffold` with an
   AppBar titled "Location". Keep all provider use exactly as-is (no
   `shared_preferences` or plugin calls from the widget — architecture rule).

2. `lib/screens/display_settings_screen.dart` — a new `DisplaySettingsScreen`.
   Move the current `_DisplayCard` body (the `RadioGroup` of display modes) here,
   in a `Scaffold` with an AppBar titled "Display".

3. `lib/screens/help_screen.dart` — a new `HelpScreen`. This becomes a menu of
   its own, matching the Settings card pattern:
   - Keep the intro line ("The clock reads Ghaṭikā : Vināḍī : Prāṇa…") at the
     top and the closing "these lengths are approximate…" note at the bottom.
   - In between, show one tappable `_NavCard` per topic from `DharmaUnits.all`
     (Ghaṭikā, Vināḍī, Prāṇa, Muhūrta). Each card shows the unit name as title
     and its `approx, count` as subtitle. Tapping opens that topic's detail page.
   - `Scaffold` with an AppBar titled "Help".

4. `lib/screens/help_topic_screen.dart` — a new `HelpTopicScreen` that shows one
   topic's full detail. One reusable screen for all four topics, chosen by its
   position in `DharmaUnits.all` (passed as a path index). It shows the unit
   name as the AppBar title and heading, the `approx, count` line, and the full
   `description`. Reads only from the shared `DharmaUnits` table — no new data.
   If the index is out of range, fall back safely to the first unit.

### A shared navigation-card widget

5. `lib/widgets/nav_card.dart` — a new reusable `NavCard` (icon + title +
   subtitle + chevron inside a `Card`, with an `onTap`), modelled on the current
   `_AboutCard`. Used by both the Settings page and the Help page so the cards
   look identical.

### Settings page becomes a card menu

6. `lib/screens/settings_screen.dart` — replace the inline cards with four
   `NavCard`s. The four cards:
   - Location → `context.push('/settings/location')`
   - Display → `context.push('/settings/display')`
   - Help → `context.push('/settings/help')`
   - About → `context.push('/about')` (unchanged)

   Remove the now-unused `_SectionCard`, `_LocationCard`, `_DisplayCard`,
   `_HelpCard`, `_AboutCard` and any imports that move with them (dharma_units,
   display_settings, saved_location, location_providers, settings_providers,
   location_service).

### Routes

7. `lib/core/router.dart` — add four `GoRoute`s outside the shell, next to
   `/settings` and `/about`, so they open full-screen with no tab bar:
   - `/settings/location` → `LocationSettingsScreen`
   - `/settings/display` → `DisplaySettingsScreen`
   - `/settings/help` → `HelpScreen`
   - `/settings/help/:index` → `HelpTopicScreen` (index into `DharmaUnits.all`)

   Add the matching imports.

## Files to change

- `lib/screens/settings_screen.dart` — rewrite as a card menu.
- `lib/screens/location_settings_screen.dart` — new.
- `lib/screens/display_settings_screen.dart` — new.
- `lib/screens/help_screen.dart` — new (menu of topic cards).
- `lib/screens/help_topic_screen.dart` — new (one topic's detail).
- `lib/widgets/nav_card.dart` — new (shared card widget).
- `lib/core/router.dart` — add four routes + imports.

## After the change

- Run `dart format .`, `flutter analyze` (must be clean), and `flutter test`.
- Write a change log under `change_log/`.

## Notes

- Pure UI/navigation refactor. No provider, service, model, or clock-math
  changes. No new packages. No manifest or permission change.
