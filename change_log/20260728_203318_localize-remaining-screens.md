# Finished Malayalam for every remaining screen

Implements [plans/20260728_201548_localize-remaining-screens.md](../plans/20260728_201548_localize-remaining-screens.md).

Every screen in the app now shows fully in Malayalam when the language is
Malayalam. Before this change five places still showed English.

## What changed

### 1. Panchang name tables now exist in both scripts

`lib/core/constants/panchang_names.dart` gained Malayalam-script versions of
all the North Indian names, next to the Kerala ones that were already there:

- the 14 tithi names + Pūrṇimā / Amāvāsyā, both pakṣas
- the 27 nakṣatras
- the 27 yogas
- the 7 movable karaṇas + Kiṁstughna + the 3 closing fixed karaṇas
- the 7 vāras, the 12 māsas, `Adhika`
- the 6 ṛtus (with a Malayalam season gloss) and the two ayanas

Each lookup gained an **optional** `isMalayalam` flag that defaults to English,
so the services and every existing caller kept working without edits. Two new
lookups were added where none existed: `yogaName()` and `ayanaName()`.

The three `…Formatted` helpers now pass the flag to the North Indian half too,
so both sides of `kerala (north)` end up in the same script instead of one of
each.

The Malayalam vāra names are kept plain (`രവിവാരം`, not `രവിവാരം (ഞായർ)`)
because the Kerala name shown beside them already carries the everyday weekday,
and a gloss there would have nested one bracket inside another.

### 2. Panchang screen

- The yoga and karaṇa cards had **no** Kerala counterpart, so they were pure
  Latin text in Malayalam. They now resolve the name from
  `PanchangLimb.index` in the active language.
- The ṛtu now comes from `amantaMasaIndex`, and the ayana from the existing
  Uttarāyaṇa test, both in the active language.
- The tithi's pakṣa detail line is now resolved in the active language.
- `_dayDate`, `_moonTime` and `_endText` used private English `Mon…Sun` /
  `Jan…Dec` lists. Those lists are deleted; the helpers now use the
  `shortWeekdayName()` / `shortMonthName()` that `AppLocalizations` already had
  in both languages.
- The three calendar-card notes (ṛtu, and the two ayana notes) moved into
  `AppLocalizations` beside the other sentences.

**One fix beyond a straight translation.** The screen read the language from
`appLanguageProvider` (preferences + platform locale) while every other screen
reads it from `AppLocalizations.of(context)` (the `MaterialApp` locale). The two
agree in the real app only because `localeProvider` is derived from the same
setting — a second source of truth that a test caught immediately. The screen
now reads `l10n.isMl` like every other screen, and the `language_provider`
import is gone. No behaviour change in the app; one less way to drift.

### 3. Settings, Location settings, Permissions

All hard-coded English replaced with `AppLocalizations`:

- **Settings** — the four card subtitles and the dialog `OK` button.
- **Location settings** — the live switch and its helper line, the fetching
  line, "Save current location", "Clear", the saved-place tile (including
  "Unnamed place" and the edit tooltip), the whole name dialog, the five
  `LocationStatus` messages, and the four snack-bar messages.
- **Permissions** — both card titles, both body paragraphs, the "Status:"
  label, the six status values, and the two buttons.

`_statusMessage` and `_locationStatusText` now take the `AppLocalizations`
object as a parameter, so they stay pure string helpers with no `BuildContext`.

### 4. About screen stays data-driven

Hard rule 5 says About text comes from config, not code. So instead of
hard-coding Malayalam:

- `AppConfig` gained `descriptionMl` and `detailsMl`, plus `descriptionFor()`
  and `detailsFor()` helpers that **fall back to English** when the config file
  carries no Malayalam block. An old or malformed config therefore still shows
  something rather than going blank.
- `assets/config/app_config.json` gained the two Malayalam blocks.
- Only the `Version x (build y)` label itself was localized in code, via
  `l10n.versionLine()`.

The app name stays as it is (a proper name), and version, build, dates and
clock times stay in Western digits, matching the rest of the app.

## Files changed

| File | Change |
|------|--------|
| `lib/core/constants/panchang_names.dart` | Malayalam tables + `isMalayalam` flag on every lookup; new `yogaName()` and `ayanaName()` |
| `lib/core/config/app_localizations.dart` | ~45 new strings for Settings, Location, Permissions, About and the Panchang notes |
| `lib/core/config/app_config.dart` | `descriptionMl`, `detailsMl`, and the two `…For()` helpers with English fallback |
| `assets/config/app_config.json` | `descriptionMl` and `detailsMl` blocks |
| `lib/screens/panchang_screen.dart` | localized names, one language source, English date lists deleted |
| `lib/screens/settings_screen.dart` | four subtitles + OK button |
| `lib/screens/location_settings_screen.dart` | every string |
| `lib/screens/permissions_screen.dart` | every string |
| `lib/screens/about_screen.dart` | version line + config helpers |
| `test/core/constants/name_tables_test.dart` | 5 new tests over the Panchang tables |
| `test/screens/panchang_screen_test.dart` (new) | 4 tests, both tabs |
| `test/screens/about_screen_test.dart` (new) | 6 tests incl. the fallback |
| `test/screens/settings_screen_test.dart` | Malayalam case |
| `test/screens/location_settings_screen_test.dart` | Malayalam cases incl. the dialog |
| `test/screens/permissions_screen_test.dart` | Malayalam cases |
| `test/services/panchang_calculator_test.dart` | two expectations updated (see below) |

## Tests

New checks worth naming:

- A **no-Latin-letter** check over every Malayalam name table, which catches a
  forgotten translation cheaply.
- A **whole-screen sweep** on the Panchang screen: it collects every `Text`
  actually drawn and asserts that no Latin name from any table appears, on both
  the Kerala and the North Indian tab. This is what caught the two-language-
  sources problem described above.
- The About fallback path, so a config with no Malayalam block cannot blank the
  screen.

**Two existing tests were updated, not deleted.** In
`test/services/panchang_calculator_test.dart`, two cases asserted the old mixed
output — `'അശ്വതി (Aśvinī)'` and `'പ്രതിപദം (Pratipadā)'`. That mixed script is
exactly the problem this change fixes, so those expectations now read
`'അശ്വതി (അശ്വിനി)'` and `'പ്രതിപദം (പ്രതിപദ)'`. No assertion was weakened; the
English-mode cases are untouched.

Final state: `dart format .` clean, `flutter analyze` reports **no issues**, and
`flutter test` passes **184 tests**.

## Rules kept

No network, no new package, no math or `shared_preferences` in a widget, no
About text hard-coded, no service or model touched, no layer boundary moved.
Name tables stayed in `core/constants`, UI sentences in `core/config`, About
values in the JSON asset.
