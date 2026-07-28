# Change log — Help section in Malayalam

**Plan:** [plans/20260728_200701_localize-help-section.md](../plans/20260728_200701_localize-help-section.md)
**Date:** 2026-07-28

## What was wrong

The Help pages stayed in English even when the app language was Malayalam. The
intro and closing text were hard-coded English, the `DharmaUnits` table had
Malayalam only for the unit name and the short civil length, and the unit detail
page never read `AppLocalizations`.

## What changed

### `lib/core/constants/dharma_units.dart`

- `DharmaUnit` gained three fields: `approxMl`, `countMl`, `descriptionMl`.
- Added three helpers next to the existing `nameFor` / `civilFor`:
  `approxFor()`, `countFor()`, `descriptionFor()`.
- Filled in the Malayalam text for all five units — Ghaṭikā, Vināḍī, Prāṇa,
  Muhūrta and Horā. The long Horā text was translated in full and uses the same
  planet names as `HoraNames.orderMl`, so the Help page and the Hora tab match.

### `lib/core/config/app_localizations.dart`

- New `--- Help screen ---` section with two strings: `helpIntro` (the paragraph
  above the cards) and `helpApproxNote` (the note below them).

### `lib/screens/help_screen.dart`

- Uses `l10n.helpIntro` and `l10n.helpApproxNote` instead of the hard-coded
  English text.
- Card title and subtitle now come from `nameFor` / `approxFor` / `countFor`.

### `lib/screens/help_topic_screen.dart`

- Reads `AppLocalizations.of(context)`.
- App bar title, heading, the "approx, count" line and the description all use
  the `…For(l10n.isMl)` helpers.

## Tests

- `test/core/constants/name_tables_test.dart` — new `DharmaUnits` group: every
  unit has all its Malayalam text filled in, the flag picks the right language,
  and the two languages really differ.
- `test/screens/help_screen_test.dart` — the pump helper now takes a locale and
  installs the localization delegates. Two new cases: the Malayalam list shows
  Malayalam names, intro and note (and no English names), and tapping a card
  opens a Malayalam detail page.
- `test/screens/help_topic_screen_test.dart` — same locale support, plus a case
  that checks the Horā page in Malayalam (name, length line and full
  description).

## Checks run

- `dart format .` — no files changed.
- `flutter analyze` — no issues.
- `flutter test` — all 164 tests passed.

## Not included

- The `like` field on `DharmaUnit` is not shown anywhere in the UI, so it was
  left in English.
- The About screen stays data-driven from `assets/config/app_config.json`.
