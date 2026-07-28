# Localize the Help section to Malayalam

**Status:** completed

## The issue

The Help pages are still English only. When the app language is Malayalam, the
Help list and each unit detail page still show English text:

- The Help list intro paragraph and the closing note are hard-coded English
  strings inside `help_screen.dart`.
- Each card shows `unit.name`, `unit.approx` and `unit.count` from the
  `DharmaUnits` table. Only `name` and `civil` have Malayalam versions today;
  `approx`, `count` and `description` do not.
- `help_topic_screen.dart` does not read `AppLocalizations` at all, so the
  detail page is fully English.

Everything else on these pages (the app bar title `helpTitle`) is already
localized, so only the body text is left.

## Files to change

| File | What changes |
|------|--------------|
| `lib/core/constants/dharma_units.dart` | Add `approxMl`, `countMl`, `descriptionMl` to `DharmaUnit`, fill them in for all five units, and add `approxFor()`, `countFor()`, `descriptionFor()` helpers next to the existing `nameFor()` / `civilFor()`. |
| `lib/core/config/app_localizations.dart` | Add two new strings for the Help list: `helpIntro` and `helpApproxNote`. |
| `lib/screens/help_screen.dart` | Use `l10n.helpIntro` / `l10n.helpApproxNote` instead of the hard-coded English text, and use `nameFor` / `approxFor` / `countFor` for the cards. |
| `lib/screens/help_topic_screen.dart` | Read `AppLocalizations.of(context)` and use `nameFor` / `approxFor` / `countFor` / `descriptionFor`. |
| `test/screens/help_screen_test.dart` | Add a Malayalam pump case that checks the Malayalam unit names and intro show up. |
| `test/screens/help_topic_screen_test.dart` | Add a Malayalam case that checks the Malayalam description shows up. |
| `test/core/constants/name_tables_test.dart` | Add checks that every `DharmaUnit` has non-empty Malayalam fields. |

## The plan

1. **`DharmaUnit` gets three more Malayalam fields.**
   Same pattern already used for `nameMl` and `civilMl`, so nothing new is
   invented:

   ```dart
   final String approxMl;      // e.g. 'ഏകദേശം 24 മിനിറ്റ്'
   final String countMl;       // e.g. 'ഒരു ദിവസത്തിൽ 60'
   final String descriptionMl; // the full Malayalam explanation

   String approxFor(bool isMalayalam) => isMalayalam ? approxMl : approx;
   String countFor(bool isMalayalam) => isMalayalam ? countMl : count;
   String descriptionFor(bool isMalayalam) =>
       isMalayalam ? descriptionMl : description;
   ```

   All five units (Ghaṭikā, Vināḍī, Prāṇa, Muhūrta, Horā) get the three new
   values. The Horā description is the long one and is translated in full,
   using the same planet names as `HoraNames.orderMl` so the wording matches
   the Hora tab.

2. **Two new strings in `AppLocalizations`** under a `--- Help screen ---`
   heading:
   - `helpIntro` — "The clock reads Ghaṭikā : Vināḍī : Prāṇa … Tap a unit below
     to learn more."
   - `helpApproxNote` — "These lengths are approximate — the day flexes a
     little with the season …"

3. **`help_screen.dart`** already has `l10n`; swap the two `Text` bodies for the
   new getters and pass `l10n.isMl` into the unit helpers for the card title and
   subtitle.

4. **`help_topic_screen.dart`** adds
   `final l10n = AppLocalizations.of(context);` and uses the `…For(l10n.isMl)`
   helpers for the app bar title, the heading, the `approx, count` line and the
   description.

5. **Tests.** The existing English tests keep working because
   `AppLocalizations.of` falls back to English when no delegate is installed.
   New Malayalam tests wrap the screen in a `MaterialApp` with
   `AppLocalizations.delegate` and `locale: Locale('ml')`.

6. Run `dart format .`, `flutter analyze` (must be clean) and `flutter test`.

## Layer note

No layer boundary moves. The text stays in `core/constants` (unit facts) and
`core/config` (UI sentences); the screens only pick a language. No service or
model is touched.

## Out of scope

- The `like` field is not shown anywhere in the UI today, so it is left as is.
- The About screen is data-driven from `app_config.json` and is not part of this
  change.
