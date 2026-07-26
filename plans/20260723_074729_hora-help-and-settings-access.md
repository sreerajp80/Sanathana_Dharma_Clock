# Plan: Horā in Help + Settings from every tab

**Status:** completed

## What the user asked for

1. Add **Horā** to the Help section (Settings → Help), so users can learn what
   a horā is.
2. Make **Settings reachable from all tabs**, not just the Clock tab.

## The issue

- The Help page lists only the dial units (Ghaṭikā, Vināḍī, Prāṇa, Muhūrta)
  from the shared `DharmaUnits` table. There is no Horā topic.
- The Settings gear button exists only in the Clock screen's app bar. On the
  Muhurta, Hora, and Panchang tabs there is no way to open Settings.

## The fix

### 1. Horā Help topic

Add a `hora` entry to `DharmaUnits` in
`lib/core/constants/dharma_units.dart`:

- name: `Horā`, like: `''` (not a dial hand — same as Muhūrta),
  approx: `about 60 minutes`, civil: `60 minutes`,
  count: `24 in a day (12 day + 12 night)`.
- description (a short plain-English paragraph): a horā is an elastic hour —
  the daytime splits into 12 and the night into 12, so day horās are longer in
  summer and shorter in winter. Each horā is ruled by one of the 7 classical
  planets; the first horā after sunrise is ruled by that weekday's lord
  (Sunday → Sūrya, Monday → Chandra, …), then the fixed order
  Sūrya → Śukra → Budha → Chandra → Śani → Guru → Maṅgala repeats. The Hora
  tab shows today's 24 horās.

Append it to `DharmaUnits.all` (NOT to `DharmaUnits.hands`, so the dial legend
is untouched). The Help list and topic page are already data-driven from
`DharmaUnits.all`, so both pick it up with no screen change. Update the doc
comment on `all`.

### 2. Settings gear on every tab

Add the same app-bar action the Clock screen already has —
`IconButton(Icons.settings_outlined)` → `context.push('/settings')` — to:

- `lib/screens/muhurta_screen.dart`
- `lib/screens/hora_screen.dart`
- `lib/screens/panchang_screen.dart`

`/settings` sits outside the tab shell, so it opens full-screen and the back
button returns to whichever tab you came from. No router change needed.

## Files to change

| File | Change |
|------|--------|
| `lib/core/constants/dharma_units.dart` | Add the `hora` unit and append it to `all`; update the `all` doc comment. |
| `lib/screens/muhurta_screen.dart` | Add the Settings app-bar button (+ go_router import). |
| `lib/screens/hora_screen.dart` | Add the Settings app-bar button (+ go_router import). |
| `lib/screens/panchang_screen.dart` | Add the Settings app-bar button (+ go_router import). |
| `test/screens/help_screen_test.dart` | Confirm it still passes — it iterates `DharmaUnits.all`, so the new card is covered automatically. Adjust only if it hard-codes a count. |
| `docs/architecture.md` | Only if it lists the help topics or the settings entry point (quick check; likely no change). |

## Order of work

1. `DharmaUnits` entry.
2. The three app-bar buttons.
3. `flutter analyze` + `flutter test`; `dart format`; change log.

## Out of scope

- No new Help screens — the existing data-driven list and topic page are reused.
- No change to the Clock screen, dial legend, router, or the Hora tab itself.
