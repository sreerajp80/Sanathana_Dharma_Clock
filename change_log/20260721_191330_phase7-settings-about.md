# Change log — Phase 7: settings and about

**Date:** 2026-07-21
**Plan:** [../plans/20260721_191330_phase7-settings-about.md](../plans/20260721_191330_phase7-settings-about.md)
**Phase:** 7 of [../docs/implementation_plan.md](../docs/implementation_plan.md)

## What changed

Replaced the two Phase 6 placeholder screens with their real, working versions.
No new files, no new dependencies, no state/service/model changes — the UI is
built on top of the providers that already existed.

### `lib/screens/settings_screen.dart` (rewritten)

Now a `ConsumerWidget` showing a scrolling list of three cards, each a small
private `_SectionCard`:

- **Location** (`_LocationCard`, watches `locationProvider`):
  - "Use live location" `SwitchListTile` → `locationProvider.notifier.setUseLive`.
  - "Save current location" `FilledButton` → `refreshLive()`, and on success
    `saveLocation(...)` with the fetched coordinates. The outcome is reported in a
    `SnackBar` using the status **category only** — never the coordinates.
  - The saved place (`_SavedLocationTile`) shows the label (or "Unnamed place")
    and the coordinates **on screen** (allowed; only logging/sending is
    forbidden), or "No saved location". A "Clear" button calls `clear()`.
  - A spinner while `isFetching`; a plain-English error line mapped from
    `LocationStatus` when a fetch fails.
- **Display** (`_DisplayCard`, watches `displayModeProvider`): a `RadioGroup` of
  the three `DisplayMode`s (both / analog / digital) → `setMode`.
- **About** (`_AboutCard`): a `ListTile` that `context.push('/about')` so Back
  returns to Settings.

### `lib/screens/about_screen.dart` (rewritten)

Now a `ConsumerWidget` that reads `appConfigProvider` and renders every value from
`AppConfig`: app name, description, "Version x (build y)", and each entry of
`config.details` as a label/value row. Nothing is hard-coded (CLAUDE.md hard rule
5). The version/build come from the config, so `package_info_plus` is not needed
(Phase 1 deviation).

### `docs/implementation_progress.md` (updated)

Ticked the Phase 7 items, flipped the status row to Done, updated the overall
status, and added a dated note.

## Deviations

- `RadioListTile`'s `groupValue`/`onChanged` are deprecated in Flutter 3.41.9, so
  the display options use a `RadioGroup` ancestor instead. Same behaviour, current
  API, no analyzer warning.

## Verification

- `dart format .` applied to both changed files.
- `flutter analyze` — **No issues found**.
- `flutter test` — **all 48 tests pass** (widget tests are Phase 9).
- Accessibility: all rows use `ListTile`/`SwitchListTile`/`RadioListTile`/buttons
  (already ≥ 48 dp); both screens scroll, so they hold up at 1.5×/2.0× text scale.

## Not done here (later phases)

- Panchang tab content — Phase 8.
- Widget tests for the Settings cards and About screen — Phase 9.
- A manual on-device run of the save/live-location flow was not performed in this
  environment; the logic is wired through the existing, tested notifiers.
