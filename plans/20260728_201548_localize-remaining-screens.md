# Finish Malayalam for every remaining screen

**Status:** completed

## The issue

The Clock, Muhurta, Hora, Almanac, Help and Home tab bar are already localized
(plans `20260726_205400` and `20260728_200701`). But when the app language is
Malayalam, four screens still show English, and one screen is only half done.

I read every file under `lib/screens/` and `lib/widgets/` to make this list.

### 1. Settings screen — card subtitles are hard-coded English

[lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart) uses
`l10n` for the five card titles, but the five subtitles are typed in:

- `'Live or saved location for sunrise.'` (line 101)
- `'Permissions used by this app.'` (line 107)
- `'What the dharma time units mean.'` (line 113)
- `'About this app.'` (line 120)
- the dialog button `'OK'` (line 60)

### 2. Location settings screen — fully English

[lib/screens/location_settings_screen.dart](../lib/screens/location_settings_screen.dart)
uses `l10n` for the app bar title only. Everything else is English: the live
location switch and its helper line, "Getting current location…", "Open
Settings", "Save current location", "Clear", the saved-place tile ("No saved
location", "Save one below…", "Unnamed place", the edit tooltip), the whole
name dialog (title, hint, label, Cancel, Save), the five `LocationStatus`
messages, and the four snack-bar messages.

### 3. Permissions screen — fully English

[lib/screens/permissions_screen.dart](../lib/screens/permissions_screen.dart)
uses `l10n` for the app bar title only. The two cards ("Location Access",
"Internet Access: Disabled"), both body paragraphs, the "Status: " label, the
six status values, and the two buttons are all English.

### 4. About screen — English label and English config text

[lib/screens/about_screen.dart](../lib/screens/about_screen.dart) shows
`'Version 2.8.5 (build 19)'` as a typed-in English string. The app name,
description and the detail rows come from `assets/config/app_config.json`,
which only holds English. Hard rule 5 says About text must stay data-driven, so
the Malayalam text belongs in the JSON, not in the code.

### 5. Panchang screen — the Sanskrit names stay in Latin script

The Panchang screen was localized for the Kerala-style names, the card headings
and the meaning lines. But a Malayalam reader still sees a lot of Latin text,
because the North Indian name tables in
[lib/core/constants/panchang_names.dart](../lib/core/constants/panchang_names.dart)
exist in one script only:

- tithi (`Pratipadā`, `Pūrṇimā`, `Amāvāsyā`), pakṣa, the 27 nakṣatras,
  the 7 vāras, the 12 māsas, `Adhika`.
- the 27 yogas and the karaṇas — these are shown with **no** Kerala counterpart
  at all, so in Malayalam mode the yoga and karaṇa cards are pure Latin text.
- the 6 ṛtus (`Varṣā (monsoon)` — the season note is even in English) and the
  two ayanas.

Both styles show a bracketed counterpart (`kerala (north)`), so in Malayalam
mode roughly half of every name line is still Latin.

There is also a leftover date helper at the bottom of
[lib/screens/panchang_screen.dart](../lib/screens/panchang_screen.dart):
`_dayDate` and `_moonTime` use private English `Mon…Sun` and `Jan…Dec` lists
(lines 551–584), even though `AppLocalizations` already has
`shortWeekdayName()` and `shortMonthName()` in both languages.

### Why some of this is not just a screen fix

Like the earlier plans found, some names are built in the service layer and
stored in the model as finished strings (`PanchangLimb.name`, `CalendarInfo.rtu`,
`CalendarInfo.ayana`). By the time the screen draws them the language is gone.

Good news: **no model change is needed this time.** Every one of them already
has a key next to it:

- `PanchangLimb.index` — the screen can look the yoga/karaṇa name up itself.
- `CalendarInfo.amantaMasaIndex` — the ṛtu is `(index % 12) ~/ 2`.
- The ayana is already compared as `calendar.ayana == PanchangNames.uttarayana`
  in the screen, so the screen already knows which of the two it is.

So the services and the models stay untouched.

## Files to change

| File | What changes |
|------|--------------|
| `lib/core/constants/panchang_names.dart` | Add Malayalam-script lists for the North Indian names (tithi, pakṣa, nakṣatra, yoga, karaṇa, vāra, māsa, ṛtu, ayana, Adhika) and add an optional `isMalayalam` flag to each lookup. |
| `lib/core/config/app_localizations.dart` | Add the new strings for Settings, Location settings, Permissions, About and the Panchang ṛtu/ayana notes. |
| `lib/core/config/app_config.dart` | Add `descriptionMl` and `detailsMl`, plus `descriptionFor(bool)` / `detailsFor(bool)` helpers. |
| `assets/config/app_config.json` | Add `descriptionMl` and `detailsMl` blocks. |
| `lib/screens/settings_screen.dart` | Use `l10n` for the four subtitles and the OK button. |
| `lib/screens/location_settings_screen.dart` | Use `l10n` everywhere. |
| `lib/screens/permissions_screen.dart` | Use `l10n` everywhere. |
| `lib/screens/about_screen.dart` | Use `l10n.versionLine(...)` and the config `…For(l10n.isMl)` helpers. |
| `lib/screens/panchang_screen.dart` | Pass `isMalayalam` into every `PanchangNames` call, resolve yoga/karaṇa/ṛtu by index, and use `l10n.shortWeekdayName` / `shortMonthName` in the date helpers. |
| `test/core/constants/name_tables_test.dart` | Add checks that every Malayalam Panchang list is complete and non-empty. |
| `test/screens/settings_screen_test.dart` | Add a Malayalam case. |
| `test/screens/location_settings_screen_test.dart` (new) | Malayalam case. |
| `test/screens/permissions_screen_test.dart` (new) | Malayalam case. |
| `test/screens/about_screen_test.dart` (new) | Malayalam case. |
| `test/screens/panchang_screen_test.dart` (new) | Malayalam case — checks no Latin yoga name is on screen. |

## The plan

### Step 1 — `panchang_names.dart` gets the Malayalam tables

Same pattern the file already uses for the Kerala names (an `Ml` list plus an
`isMalayalam` flag). New lists:

- `_tithiBaseMl` (14), `purnimaMl`, `amavasyaMl`
- `shuklaPakshaMl`, `krishnaPakshaMl`
- `nakshatrasMl` (27)
- `yogasMl` (27)
- `movableKaranasMl` (7), `kimstughnaMl`, `endFixedKaranasMl` (3)
- `varasMl` (7)
- `masasMl` (12), `adhikaMl`
- `rtusMl` (6)
- `uttarayanaMl`, `dakshinayanaMl`

Each lookup gains an **optional** named flag that defaults to English, so the
services, the existing tests and any caller I miss keep working unchanged:

```dart
static String tithi(int index, {bool isMalayalam = false});
static String paksha(int index, {bool isMalayalam = false});
static String yogaName(int index, {bool isMalayalam = false});   // new
static String karana(int index, {bool isMalayalam = false});
static String vara(int weekday, {bool isMalayalam = false});
static String masa(int index, {bool isMalayalam = false});
static String rtuOfMasa(int masaIndex, {bool isMalayalam = false});
static String ayanaName({required bool isUttarayana, bool isMalayalam = false}); // new
```

The three `…Formatted` helpers already take `isMalayalam`; they simply pass it
down to the North Indian side too, so both halves of `kerala (north)` end up in
the same script.

The ṛtu list keeps its English gloss in English mode (`Varṣā (monsoon)`) and
uses a Malayalam gloss in Malayalam mode (`വർഷം (മഴക്കാലം)`).

### Step 2 — `AppLocalizations` gets the plain screen text

New sections, following the file's existing layout:

- **Settings:** `locationCardSubtitle`, `permissionsCardSubtitle`,
  `helpCardSubtitle`, `aboutCardSubtitle`, `ok`.
- **Location settings:** `useLiveLocation` + its helper line,
  `gettingCurrentLocation`, `saveCurrentLocation`, `clear`, `noSavedLocation`
  + its helper line, `unnamedPlace`, `editLocationName`, `nameThisLocation`,
  `locationNameLabel`, `locationNameHint`, `cancel`, `save`, the five status
  messages, and the four result messages
  (`savedCurrentLocation`, `savedNamedLocation(name)`, `updatedLocation`,
  `updatedLocationName(name)`).
- **Permissions:** `locationAccessTitle`, `locationAccessBody`, `statusLabel`,
  `internetDisabledTitle`, `internetDisabledBody`, `appSettings`,
  `checkOrRequest`, and the six status values (`liveModeActive`,
  `usingSavedLocation`, `grantedAndActive`, `gpsDisabled`, `permissionDenied`,
  `permissionBlocked`, `errorFetchingLocation`).
- **About:** `versionLine(String version, String build)`.
- **Panchang:** `rtuNote`, `uttarayanaNote`, `dakshinayanaNote` — these three
  are currently written inline in the screen; moving them keeps the new ones
  next to the old ones. (The other inline meaning lines already switch on
  `isMalayalam`, so I leave them where they are — moving them all is a bigger
  edit with no user-visible gain.)

### Step 3 — `AppConfig` learns a second language

Keeps hard rule 5 (About stays data-driven):

```dart
final String descriptionMl;
final Map<String, String> detailsMl;

String descriptionFor(bool isMalayalam) =>
    isMalayalam && descriptionMl.isNotEmpty ? descriptionMl : description;
Map<String, String> detailsFor(bool isMalayalam) =>
    isMalayalam && detailsMl.isNotEmpty ? detailsMl : details;
```

Both fall back to English when the Malayalam block is missing, so an old or
broken config file still works. `app_config.json` gets:

```json
"descriptionMl": "സൂര്യോദയം അടിസ്ഥാനമാക്കി സനാതന ധർമ്മ (വൈദിക) സമയം കാണിക്കുന്നു, സാധാരണ സമയത്തിനൊപ്പം.",
"detailsMl": {
  "രചയിതാവ്": "Sreeraj P",
  "ഇമെയിൽ": "sreerajp@zohomail.in",
  "ലൈസൻസ്": "ഉപയോഗിച്ച എല്ലാ ലൈബ്രറികളും ഓപ്പൺ സോഴ്സ് ആണ്.",
  "ഉപയോഗിച്ച AI": "Claude Code",
  "ഉപയോഗിച്ച IDE": "VS Code"
}
```

The app name stays as it is — it is a proper name. The version and build
numbers stay in Western digits, like every other number in the app.

### Step 4 — the four screens use the strings

Straight swaps, no logic change:

- `settings_screen.dart` — four subtitles and the OK button.
- `location_settings_screen.dart` — every string; `_statusMessage` and the
  snack-bar builders take `AppLocalizations` as a parameter so they stay pure
  string helpers.
- `permissions_screen.dart` — every string; `_locationStatusText` takes
  `AppLocalizations` too.
- `about_screen.dart` — `l10n.versionLine(...)` and the two config helpers.

### Step 5 — the Panchang screen finishes the job

- Pass `isMalayalam:` into `PanchangNames.masa`, `keralaSolarMasa` (already
  done), and the new flagged lookups.
- Yoga card: `PanchangNames.yogaName(panchang.yoga.index, isMalayalam: isMl)`
  instead of `panchang.yoga.name`.
- Karaṇa card: `PanchangNames.karana(panchang.karana.index, isMalayalam: isMl)`
  instead of `panchang.karana.name`.
- Ṛtu row: `PanchangNames.rtuOfMasa(calendar.amantaMasaIndex, isMalayalam: isMl)`
  instead of `calendar.rtu`.
- Ayana row: keep the existing `calendar.ayana == PanchangNames.uttarayana`
  test, then draw
  `PanchangNames.ayanaName(isUttarayana: …, isMalayalam: isMl)`.
- `_dayDate` and `_moonTime` take the `AppLocalizations` object and use
  `shortWeekdayName()` / `shortMonthName()`. The two private English lists at
  the bottom of the file are deleted.

Numbers (year, dates, clock times) stay in Western digits, exactly as the
Panchang screen and the Almanac already do.

### Step 6 — tests

- Extend `test/core/constants/name_tables_test.dart`: every new Malayalam list
  has the right length, no empty entry, and no ASCII letter in it (a cheap way
  to catch a forgotten translation).
- New widget tests pump each screen inside a `MaterialApp` with
  `AppLocalizations.delegate` and `locale: Locale('ml')`, then assert a known
  Malayalam word is present and a known English word is absent. The existing
  English tests keep passing because `AppLocalizations.of` falls back to
  English when no delegate is installed.
- Run `dart format .`, then `flutter analyze` (must be clean) and
  `flutter test` (all green).

## Layer note

No layer boundary moves and no rule in CLAUDE.md is touched:

- Name tables stay in `core/constants`, UI sentences in `core/config`, About
  values in the JSON asset.
- No service, no model, and no math is changed.
- No new package, no network, no `shared_preferences` from a widget.

## Out of scope

- The English wording itself is not being reworded — only translated.
- The Kerala/North Indian style toggle behaviour does not change.
- The remaining inline `isMalayalam ? … : …` meaning lines already inside
  `panchang_screen.dart` are left where they are; they already work in both
  languages.
- Western digits are kept everywhere. Malayalam digits are not introduced.
