# Change log: Horā in Help + Settings from every tab

**Implements:** [plans/20260723_074729_hora-help-and-settings-access.md](../plans/20260723_074729_hora-help-and-settings-access.md)

## What was changed

### 1. Horā Help topic

Added a `hora` entry to the shared `DharmaUnits` table in
[lib/core/constants/dharma_units.dart](../lib/core/constants/dharma_units.dart):

- "about 60 minutes, 24 in a day (12 day + 12 night)".
- A plain-English description: elastic hours (day and night each split into
  12), the 7 planetary rulers, the weekday-lord rule, the fixed horā order,
  and a note on the activities tradition links to each planet.

It was appended to `DharmaUnits.all` only — **not** to `DharmaUnits.hands` —
so the Help list and its detail page pick it up automatically (both are
data-driven) and the clock dial legend is untouched.

### 2. Settings gear on every tab

The Clock tab already had a Settings button in its app bar. The same button
(`Icons.settings_outlined` → `context.push('/settings')`) was added to:

- [lib/screens/muhurta_screen.dart](../lib/screens/muhurta_screen.dart)
- [lib/screens/hora_screen.dart](../lib/screens/hora_screen.dart)
- [lib/screens/panchang_screen.dart](../lib/screens/panchang_screen.dart)

`/settings` sits outside the tab shell, so it opens full-screen and back
returns to the tab you came from. No router change was needed.

## Tests

- `test/screens/help_screen_test.dart` iterates `DharmaUnits.all`, so the new
  Horā card is covered with no test change.
- `flutter analyze` — no issues.
- `flutter test` — all 92 tests pass.
- `dart format` — no changes needed.

## Not changed

- `docs/architecture.md` — it does not list the individual help topics or the
  settings entry points, so no update was needed.
