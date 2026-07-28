# Change log — Malayalam on the Clock, Muhurta, Hora and Almanac screens

Implements [plans/20260726_205400_localize-clock-muhurta-hora-almanac.md](../plans/20260726_205400_localize-clock-muhurta-hora-almanac.md).

## What was wrong

Four screens showed English even when the app language was Malayalam. Only the app bar title
used `AppLocalizations`; every other line was English typed straight into the widget. On top of
that, the muhūrta and horā names were built in the service layer and stored inside the models, so
by the time a screen drew them the language was already lost.

## What changed

### Models — a language-free key next to the name

- `lib/models/muhurta_window.dart` — new `WindowLabel` enum
  (`muhurta`, `abhijit`, `rahuKala`, `yamagandaKala`, `gulikaKala`) and two new fields, `label`
  and `index`. The old `name` field stays as the canonical wording, so services and existing
  tests are unaffected. Both new fields join `==` and `hashCode`.
- `lib/models/hora_window.dart` — new `lordIndex` field (0–6, the slot in `HoraNames.order`).

### Services — fill in the keys

- `lib/services/muhurta_kala_calculator.dart` — passes `label` and `index` for the 30 muhūrtas
  and for Abhijit and the three kālas.
- `lib/services/hora_calculator.dart` — passes `lordIndex`.

No math changed in either file.

### Constants — Malayalam name tables

- `lib/core/constants/muhurta_names.dart` — added `namesMl` (30 names) and
  `at(index, {isMalayalam})`. The default is still English.
- `lib/core/constants/hora_names.dart` — added `orderMl` (7 rulers), `nameAt(index, ...)` and
  `indexAt(weekday, k)`; `lordAt` now takes the same optional flag and is built on the two.
- `lib/core/constants/dharma_units.dart` — each unit gained `nameMl` and `civilMl`, plus the
  helpers `nameFor(isMalayalam)` and `civilFor(isMalayalam)`.

### Strings

- `lib/core/config/app_localizations.dart` — about 60 new entries: the clock's location lines and
  readout labels, the elapsed-time and dial count lines, the screen-reader sentence, the whole
  location-permission banner, the Muhurta section headers and kāla names, the Hora headers and
  "time left" line, and the Almanac's events, notes, months, short weekdays and column labels.

### Screens and widgets

- `lib/screens/clock_screen.dart`, `lib/screens/muhurta_screen.dart`,
  `lib/screens/hora_screen.dart`, `lib/screens/almanac_screen.dart` — every typed-in English
  string now comes from `AppLocalizations`.
- `lib/widgets/location_permission_banner.dart` — same.
- `lib/widgets/dharma_dial_painter.dart` — new `countLabel` parameter. The painter no longer
  builds the `Muhūrta n / 30` wording itself; the caller passes it in the right language. It is
  part of `shouldRepaint`.
- `lib/widgets/window_labels.dart` (new) — `windowName(window, l10n)` and
  `horaLordName(hora, l10n)`: the key → name lookup, shared by the clock's arc legend and the
  Muhurta and Hora screens.
- `lib/widgets/window_colors.dart` — now switches on the language-free `label` instead of the
  English name, so the kāla colours cannot break in another language.

### Tests

- New: `test/screens/muhurta_screen_test.dart`, `test/screens/hora_screen_test.dart`,
  `test/screens/almanac_screen_test.dart` — each pumps the screen in English and again in
  Malayalam, and checks the Malayalam text is there and the English text is gone.
- New: `test/core/constants/name_tables_test.dart` — both name tables have the right length, the
  flag picks the language, the default stays English, and a bad index is clamped or wrapped
  instead of throwing.
- Updated: `test/screens/clock_screen_test.dart` — the pump helper now takes a locale, and two
  Malayalam cases were added.

## Result

- `flutter analyze` — no issues.
- `flutter test` — 158 tests, all passing.
- `dart format .` — run.

## Not included

Help, Settings, About, Permissions and Location screens were not part of this change; they were
not reported. Sanskrit terms are written in Malayalam script for the Malayalam interface; digits,
clock times and years stay in Western digits, matching the Panchang screen.
