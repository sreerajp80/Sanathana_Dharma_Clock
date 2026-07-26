# Multilingual Support and Dual-Style Panchang

**Plan reference:** `plans/20260726_192500_multilingual_and_panchang_styles.md`

## Summary of Changes

1. **Multilingual Support (Malayalam & English)**:
   - Added `flutter_localizations` dependency in `pubspec.yaml`.
   - Created `AppLanguageMode` (`system`, `english`, `malayalam`) and `AppLanguage` in `lib/core/config/app_language.dart`.
   - Built `AppLocalizations` in `lib/core/config/app_localizations.dart` providing English and Malayalam strings across the app.
   - Built `language_provider.dart` with `languageModeProvider`, `appLanguageProvider`, and `localeProvider` reading/writing preference to `SharedPreferences` (`app_language`).
   - Configured `MaterialApp` in `main.dart` with `localeProvider` and `AppLocalizations.delegate`.
   - Added a Language selection setting in `SettingsScreen` allowing the user to select System Default, English, or Malayalam.
   - Localized titles and labels across app screens.

2. **Dual-Style Panchang (Kerala Style & North Indian Style)**:
   - Enhanced `panchang_names.dart` with Kerala style Malayalam & transliterated tables for Nakshatras, Tithis, Varas, Kollavarsham Solar Months, Paksham, and cross-reference bracket formatting (`nakshatraFormatted`, `tithiFormatted`, `varaFormatted`, `pakshaFormatted`, `masaFormatted`).
   - Updated `CalendarInfo` in `panchang_day.dart` and `PanchangCalculator` in `panchang_calculator.dart` to compute Kollavarsham Year, Solar Month, Vikram Samvat Year, and Njattuvela (Sun in Nakshatra).
   - Redesigned `PanchangScreen` with a `TabBar` containing two tabs: **Kerala Style** (കേരള രീതി) and **North Indian Style** (ഉത്തരേന്ത്യൻ രീതി).
   - On the Kerala Style tab, displayed Kollavarsham Year/Solar Month & Njattuvela with North Indian names in brackets.
   - On the North Indian Style tab, displayed Vikram Samvat Year/Lunar Month with Kerala names in brackets.

3. **Testing & Verification**:
   - Added unit tests for Kerala style names, bracket formatting, Kollavarsham calculation, and `language_provider.dart`.
   - Verified that `flutter analyze` passes with zero warnings.
   - Verified all 143 unit tests pass cleanly via `flutter test`.
