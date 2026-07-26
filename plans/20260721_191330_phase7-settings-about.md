# Phase 7 — UI: settings and about

**Status:** completed

Implements Phase 7 of [../docs/implementation_plan.md](../docs/implementation_plan.md):
a card-based Settings screen and a data-driven About screen.

## The issue / what is missing

Phases 1–6 built the whole non-UI stack and the main clock screen. The Settings
and About screens are still the Phase 6 **placeholders** — a plain "coming in a
later phase" note. The Riverpod state they need already exists
(`locationProvider`, `displayModeProvider`, `appConfigProvider`); Phase 7 just
builds the two real screens on top of it. No new state, services, or
dependencies.

## Scope (Phase 7 only)

Three things from the plan:

1. `screens/settings_screen.dart` — one card per section: **Location**,
   **Display**, **About**.
2. `screens/about_screen.dart` — every value read from `AppConfig` (nothing
   hard-coded).
3. Touch targets ≥ 48 dp; the screens read well at 1.0×, 1.5×, 2.0× text scale.

Out of scope: Panchang (Phase 8), widget tests (Phase 9). No solar/dharma math or
prefs access from widgets — the screens only call provider methods.

## Design notes

**Settings screen (`settings_screen.dart`).** A `ConsumerWidget` with a scrolling
`ListView` of three `Card`s. All interaction goes through provider notifiers —
the widget never touches `shared_preferences` or the location plugin directly
(CLAUDE.md architecture rule). The whole body scrolls so it stays usable at large
text scales.

- **Location card** — watches `locationProvider`.
  - A `SwitchListTile` "Use live location" → `locationProvider.notifier.setUseLive`.
    When on, the notifier fetches a fix; show a small spinner while
    `state.isFetching` is true.
  - A "Save current location" button → `refreshLive()`, and on
    `LocationStatus.success` call `saveLocation(...)` with the fetched
    coordinates (label left empty — offline app, no reverse geocoding). Report the
    outcome with a `SnackBar` using the status category only (never the
    coordinates).
  - Show the current saved location: its label (or "Unnamed place") and its
    coordinates **on screen** (showing to the user is allowed; only logging/sending
    is forbidden — security.md §9). If none saved, show "No saved location".
    A "Clear" action → `locationProvider.notifier.clear()`.
  - If a live fetch failed, show a short plain-English reason (service off /
    permission denied / denied forever / error) mapped from `LocationStatus`.

- **Display card** — watches `displayModeProvider`.
  - Three `RadioListTile<DisplayMode>` (analog / digital / both) →
    `displayModeProvider.notifier.setMode`. `RadioListTile` rows are ≥ 48 dp.

- **About card** — a single `ListTile` (trailing chevron) that opens the About
  screen with `context.push('/about')` so the back button returns to Settings.

**About screen (`about_screen.dart`).** A `ConsumerWidget` that reads
`appConfigProvider` (CLAUDE.md hard rule 5 — About is data-driven; nothing is
hard-coded). It shows:
- `config.appName` as the title/header,
- `config.description`,
- version line built from `config.version` + `config.build`
  (e.g. "Version 1.0.0 (build 1)"),
- every entry of `config.details` as a label/value row (in map order).

No `package_info_plus` — per the Phase 1 deviation the version/build come from
`app_config.json` via `AppConfig`, which is exactly what `appConfigProvider`
carries. The screen renders whatever keys the config has, so editing About is a
config edit, not a code change.

**Accessibility.** Use `ListTile` / `SwitchListTile` / `RadioListTile` / buttons,
which are already ≥ 48 dp. Both screens are fully scrollable so nothing clips at
1.5×/2.0× text scale. Colours come from the theme (already WCAG-AA checked in
Phase 6).

## Files to change / add

**Change**
- `lib/screens/settings_screen.dart` — replace the placeholder with the three-card
  `ConsumerWidget`.
- `lib/screens/about_screen.dart` — replace the placeholder with the data-driven
  `ConsumerWidget`.

**No new files, no dependency changes.** (If a card grows large I may extract a
small private `_SectionCard` widget inside the same file, but no new public files.)

## Verification

- `flutter analyze` clean (zero warnings).
- `flutter test` still green (48 tests; widget tests are Phase 9).
- `dart format .` applied.
- Manual `flutter run --flavor dev`: Settings shows the three cards; the display
  toggle changes the clock; save/live location works and reports status; About
  shows the config values. Note it in the change log.

## After implementing

- Update [../docs/implementation_progress.md](../docs/implementation_progress.md):
  tick the Phase 7 items, flip the status row to Done, add a dated note.
- Write the change log in `change_log/`.
