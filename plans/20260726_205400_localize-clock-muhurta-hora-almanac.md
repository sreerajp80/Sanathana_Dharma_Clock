# Localize the Clock, Muhurta, Hora and Almanac screens

**Status:** completed

## The issue

The device language is Malayalam, but four screens still show English text:
Clock, Muhurta, Hora and Almanac.

The app already has a working language system:

- [lib/core/config/app_localizations.dart](../lib/core/config/app_localizations.dart) holds the
  strings for English and Malayalam.
- [lib/providers/language_provider.dart](../lib/providers/language_provider.dart) picks the
  language (system / English / Malayalam) and [lib/main.dart](../lib/main.dart) gives it to
  `MaterialApp`.
- The Panchang screen and the tab bar already use it, and
  [lib/core/constants/panchang_names.dart](../lib/core/constants/panchang_names.dart) already keeps
  English and Malayalam name lists side by side.

The problem is only that the four screens were written with English text typed directly into the
widgets. They call `AppLocalizations` for the app bar title only. Everything else — section
headers, helper lines, column labels, "Now", "Auspicious", month names, event names and notes,
the muhūrta names, the horā planet names — is hard-coded English.

There is also a second, smaller cause. Some names are built in the service layer and stored inside
the models (`MuhurtaWindow.name`, `HoraWindow.lord`). By the time a screen draws them the language
is already lost, so the screen cannot translate them. Those models need a small key (an index or a
label) so the screen can look up the name in the right language.

## Plan for the fix

Follow the pattern already used by Panchang: keep the two languages in constants files with an
`isMalayalam` flag, keep plain screen text in `AppLocalizations`, and let the screen do the
lookup. No new package, no change to any math, no change to layer rules.

### 1. Models — carry a key, not only a finished name

- `lib/models/muhurta_window.dart`
  - Add `enum WindowLabel { muhurta, abhijit, rahuKala, yamagandaKala, gulikaKala }`.
  - Add two fields: `WindowLabel label` (default `WindowLabel.muhurta`) and `int index`
    (the 0–29 muhūrta number; `0` for the kālas).
  - Keep the existing `name` field as the canonical English/Sanskrit name, so the services and
    the existing tests keep working. Include the new fields in `==`/`hashCode`.
- `lib/models/hora_window.dart`
  - Add `int lordIndex` (0–6, the position in `HoraNames.order`), default `0`.
  - Keep `lord` as it is.

### 2. Services — fill in the new keys

- `lib/services/muhurta_kala_calculator.dart` — pass `label:` and `index:` when it builds the 30
  muhūrtas and the 4 kāla/Abhijit windows.
- `lib/services/hora_calculator.dart` — pass `lordIndex:`.

No math changes.

### 3. Constants — add the Malayalam lists

- `lib/core/constants/muhurta_names.dart` — add `namesMl` (30 Malayalam names) and change
  `at(int index, {bool isMalayalam = false})`. The default stays English, so old callers and
  tests are unaffected.
- `lib/core/constants/hora_names.dart` — add `orderMl` (7 Malayalam planet names), add
  `nameAt(int index, {bool isMalayalam = false})`, and add the same optional flag to `lordAt`.
- `lib/core/constants/dharma_units.dart` — add `nameMl` and `civilMl` to `DharmaUnit` (used by the
  clock legend), with small helpers `nameFor(bool isMl)` and `civilFor(bool isMl)`.

### 4. `AppLocalizations` — add the missing plain strings

Add to [lib/core/config/app_localizations.dart](../lib/core/config/app_localizations.dart):

- **Clock:** "Getting location…", "No location — midnight-anchored day", the four live-fix failure
  lines, the "Civil … Sunrise …" line labels, `sinceSunrise(h, m, s)`, the dial centre line
  `muhurtaCount(n, total)`, and the screen-reader sentence.
- **Location banner** (drawn on the Clock screen): its title, the two explaining lines, "Getting
  location…", "Open App Settings", "Grant Permission", "Location Settings".
- **Muhurta:** "Kālas & special windows" + its helper line, the no-sunset message, "The 30
  Muhūrtas" + its two helper lines, "Auspicious", "Inauspicious", "Now", the kāla names
  (Abhijit Muhūrta, Rāhu Kālam, Yamagaṇḍa, Gulika Kālam).
- **Hora:** the no-sunrise message, "Current horā", "Day horās" / "Night horās" with their helper
  lines, "Day horā" / "Night horā", `timeLeft(h, m)`, "Now".
- **Almanac:** the no-location message, "Previous year" / "Next year", "Sun events of the year",
  the 6 event names and the 6 notes, the 12 month names, the short weekday and short month names
  used in the date line, and the column labels Day / Sunrise / Sunset / Length.

### 5. Screens — use the strings

- `lib/screens/clock_screen.dart` — replace every typed-in English string; pass the localized
  muhūrta name and the localized count line to the dial painter; localize the legend through
  `DharmaUnit.nameFor` / `civilFor`.
- `lib/widgets/dharma_dial_painter.dart` — add a `countLabel` parameter so the painter no longer
  builds the `Muhūrta n / 30` text itself (it stays a dumb renderer), and include it in
  `shouldRepaint`.
- `lib/widgets/location_permission_banner.dart` — use `AppLocalizations`.
- `lib/screens/muhurta_screen.dart` — use `AppLocalizations`; resolve each window's name from
  `label` + `index` in the active language.
- `lib/screens/hora_screen.dart` — use `AppLocalizations`; resolve the planet from `lordIndex`.
- `lib/screens/almanac_screen.dart` — use `AppLocalizations` for events, months, weekdays and
  column labels. Numbers (year, day, times) stay in Western digits.

### 6. Tests

- Add `test/screens/muhurta_screen_test.dart`, `test/screens/hora_screen_test.dart`,
  `test/screens/almanac_screen_test.dart` — each pumps the screen with `Locale('ml')` and checks a
  known Malayalam word is on screen and a known English word is not.
- Extend `test/screens/clock_screen_test.dart` the same way.
- Add a small constants test for `MuhurtaNames.at(..., isMalayalam: true)` and
  `HoraNames.nameAt(..., isMalayalam: true)` (list length and one known value).
- Run `flutter analyze` and `flutter test`; both must be clean.

## Files to be changed

| File | Change |
|------|--------|
| `lib/models/muhurta_window.dart` | add `WindowLabel` enum, `label` and `index` fields |
| `lib/models/hora_window.dart` | add `lordIndex` field |
| `lib/services/muhurta_kala_calculator.dart` | pass the new keys |
| `lib/services/hora_calculator.dart` | pass `lordIndex` |
| `lib/core/constants/muhurta_names.dart` | Malayalam names + `isMalayalam` flag |
| `lib/core/constants/hora_names.dart` | Malayalam names + `isMalayalam` flag |
| `lib/core/constants/dharma_units.dart` | Malayalam name/length fields |
| `lib/core/config/app_localizations.dart` | all new strings for the four screens |
| `lib/screens/clock_screen.dart` | use the strings |
| `lib/screens/muhurta_screen.dart` | use the strings |
| `lib/screens/hora_screen.dart` | use the strings |
| `lib/screens/almanac_screen.dart` | use the strings |
| `lib/widgets/dharma_dial_painter.dart` | take `countLabel` from the caller |
| `lib/widgets/location_permission_banner.dart` | use the strings |
| `test/screens/clock_screen_test.dart` | add a Malayalam case |
| `test/screens/muhurta_screen_test.dart` (new) | Malayalam case |
| `test/screens/hora_screen_test.dart` (new) | Malayalam case |
| `test/screens/almanac_screen_test.dart` (new) | Malayalam case |
| `test/core/constants/name_tables_test.dart` (new) | Malayalam name tables |

## Notes and limits

- The Help, Settings, About, Permissions and Location screens are **not** in this change. They were
  not reported. If you want them too, say so and I will add them.
- Sanskrit terms are written in Malayalam script for the Malayalam interface (for example
  ഘടിക, രാഹു കാലം). Digits and clock times stay in Western digits, as the Panchang screen already
  does.
- No rule in CLAUDE.md is touched: no network, no new package, no math in widgets, no
  `shared_preferences` in widgets.
