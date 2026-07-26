# Plan — Help card + dial legend + back navigation + live-location fix

**Status:** completed

## The issues

The clock shows Ghaṭikā : Vināḍī : Prāṇa, but nothing on screen tells a new user
what those words mean, or which hand is which. Two more problems were reported. In full:

1. A **Help card** on the Settings screen that explains the units in simple English.
2. A **small legend** under the dial on the clock screen that maps each hand to its unit.
3. **No way back to the clock from Settings.** The clock opens Settings with
   `context.go('/settings')` ([clock_screen.dart:37](../lib/screens/clock_screen.dart)).
   `go` *replaces* the current route, so there is no back entry and the Settings AppBar
   shows no back arrow. (The About card uses `context.push`, which is why About *does*
   have a back arrow.)
4. **Live location enabled, but the clock still shows "No location".** A real bug in
   `LocationNotifier.build()`
   ([location_providers.dart:58](../lib/providers/location_providers.dart)): on startup it
   reads the saved `useLive` flag (which can be `true` from a previous run) but never
   fetches a fix, so `liveResult` stays `null`. With live on and no saved location the
   effective location resolves to `null`, and the clock shows "No location — midnight-
   anchored day". A fix is only ever fetched when the user manually toggles the switch
   again.

## The definitions (from the idea doc §1)

The day runs from local sunrise to the next local sunrise, split into these nested units:

| Unit | Size | Like | Count |
|------|------|------|-------|
| Ghaṭikā | ~24 minutes (1/60 of the day) | the hour hand | 60 per day |
| Vināḍī | ~24 seconds (1/60 of a Ghaṭikā) | the minute hand | 60 per Ghaṭikā |
| Prāṇa | ~4 seconds (1/6 of a Vināḍī) | the second hand | 6 per Vināḍī |
| Muhūrta | ~48 minutes (2 Ghaṭikā) | — | 30 per day |

Because the day flexes with the season, these lengths are approximate (a little longer
in one season, shorter in another).

## The plan

Keep the unit facts in **one** place and read them from both the Help card and the legend,
so the two never drift apart. This is pure UI/constants work — no service, model, or
solar-math change.

### New file — `lib/core/constants/dharma_units.dart`
A small constant table (same style as `muhurta_names.dart`):
- An immutable `DharmaUnit` class: `name` (e.g. `'Ghaṭikā'`), `like` (e.g. `'hour hand'`,
  empty for Muhūrta), `approx` (e.g. `'about 24 minutes'`), `count` (e.g.
  `'60 in a day'`), and `description` (a one-line plain-English explanation).
- `DharmaUnits.hands` — the three units shown as hands (Ghaṭikā, Vināḍī, Prāṇa), in the
  order they appear in the reading.
- `DharmaUnits.all` — the same three plus Muhūrta, for the Help card.

### `lib/screens/settings_screen.dart`
- Add a `_HelpCard` (built with the existing `_SectionCard`), titled **Help**, inserted
  between the Display card and the About card.
- Content: one short intro line ("The clock reads Ghaṭikā : Vināḍī : Prāṇa, like
  Hour : Minute : Second. The day starts at sunrise."), then one row per unit from
  `DharmaUnits.all` — the unit name in bold with its `approx`/`count`, and the
  `description` underneath. A closing muted line notes the lengths flex with the season.

### `lib/screens/clock_screen.dart`
- Add a small `_Legend` widget shown only when the dial is shown (`showDial`), placed
  just under the dial.
- It shows three compact items (one per `DharmaUnits.hands` entry): a short line sample
  drawn in the **same colour and thickness as that hand** (so the legend is unambiguous —
  Ghaṭikā = thick dark, Vināḍī = medium vermillion, Prāṇa = thin vermillion), then the
  unit name and its `like` label (e.g. "Ghaṭikā · hour"). Uses a `Wrap` so it reflows at
  large text scales. A tiny `CustomPainter` (or a sized `Container`) draws each sample
  stroke.

### `lib/screens/clock_screen.dart` — back navigation (issue 3)
- Change the Settings button from `context.go('/settings')` to
  `context.push('/settings')`. `push` keeps the clock in the back stack, so the Settings
  AppBar automatically shows a back arrow and the system back button returns to the clock.
  This matches how the About card already opens (`context.push('/about')`). No change to
  the router table is needed.

### `lib/providers/location_providers.dart` — live-location fix (issue 4)
- In `LocationNotifier.build()`, when the persisted `useLive` flag is `true`, start a live
  fetch after the initial state is returned (a `Future.microtask(refreshLive)`, since
  `build()` must return synchronously). This means enabling live location once, then
  restarting the app, fetches a fresh fix on startup instead of showing "No location".
- Guard it so it only runs when `useLive` is true; when the flag is false nothing is
  fetched (unchanged behaviour).

### `lib/screens/clock_screen.dart` — clearer footer (issue 4, UX)
- Make `_AnchorFooter` a `ConsumerWidget` that also reads `locationProvider`, so the
  no-anchor case is no longer a single confusing message. When there is no effective
  location it shows:
  - "Getting location…" while a live fetch is running (`isFetching`),
  - the plain-English failure reason when live is on but the last fetch failed (reusing
    the same status wording as Settings, no coordinates),
  - "No location — midnight-anchored day" only when live is off and nothing is saved.
- The live / saved cases are unchanged. The footer still reads only providers — it never
  touches `shared_preferences` or the plugin (architecture rule).

### Tests
- `test/screens/settings_screen_test.dart` — add a test that the Help card renders (find
  the **Help** title and one unit name such as **Ghaṭikā**). Existing card tests are
  unaffected (they check specific titles, not a card count).
- `test/providers/location_providers_test.dart` — add a test that, when `useLive` is
  persisted `true` and the fake service returns a success, the effective location resolves
  to the live fix on startup **without** manually calling `setUseLive` (proving the
  build-time auto-fetch). Existing tests are unaffected — they start from `useLive: false`,
  so the auto-fetch does not fire.
- `test/screens/clock_screen_test.dart` — two existing tests use the word "Ghaṭikā" as a
  stand-in for "the readout is/ isn't shown". The legend also contains "Ghaṭikā", so update
  those two to target the readout uniquely by the **Muhūrta** line (the legend has no
  Muhūrta text):
  - "both mode shows the readout and the dial" — assert the readout via
    `find.textContaining('Muhūrta')` (unchanged) and the dial; the loosened `Ghaṭikā`
    check becomes `findsWidgets` (readout + legend).
  - "analog mode hides the readout and keeps the dial" — change the
    `find.textContaining('Ghaṭikā') findsNothing` check to
    `find.textContaining('Muhūrta') findsNothing`, which still proves the readout is gone
    while allowing the legend's "Ghaṭikā".

## Files to change

| File | Change |
|------|--------|
| `lib/core/constants/dharma_units.dart` (new) | Constant table of unit facts shared by both screens. |
| [lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart) | Add `_HelpCard`; insert it before the About card. |
| [lib/screens/clock_screen.dart](../lib/screens/clock_screen.dart) | Add `_Legend` under the dial (only when the dial shows); switch Settings nav to `push` (issue 3); make `_AnchorFooter` a `ConsumerWidget` with clearer no-anchor messages (issue 4). |
| [lib/providers/location_providers.dart](../lib/providers/location_providers.dart) | Auto-fetch a live fix on startup when `useLive` is `true` (issue 4). |
| [test/screens/settings_screen_test.dart](../test/screens/settings_screen_test.dart) | New test: Help card renders. |
| [test/screens/clock_screen_test.dart](../test/screens/clock_screen_test.dart) | Retarget the two readout checks to the Muhūrta line. |
| [test/providers/location_providers_test.dart](../test/providers/location_providers_test.dart) | New test: startup auto-fetch when `useLive` is persisted true. |

## Checks after the change
- `dart format .`
- `flutter analyze` — must be clean.
- `flutter test` — all pass.

## Out of scope
- No change to the dial hands, the solar/dharma math, colours, or the About screen.
- The legend labels the three hands only, not the Muhūrta ring (kept uncluttered).
- No change to `LocationService` itself (no new last-known-position fallback); issue 4 is
  fixed by fetching on startup and by clearer messaging, not by changing the GPS call.
