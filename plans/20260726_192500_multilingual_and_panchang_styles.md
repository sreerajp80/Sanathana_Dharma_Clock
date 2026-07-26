# Multilingual Support (Malayalam & English) and Dual-Style Panchang (Kerala & North Indian)

**Status:** Proposed / Pending Approval

## Overview

This plan addresses two core requirements:
1. **Multilingual Facility**: Support Malayalam (`ml`) and English (`en`) in App Settings (System Default / Device Language, English, Malayalam) and across all screens of the app.
2. **Dual-Style Panchang**: Restructure the Panchang tab into two tabs — **Kerala Style** (കേരള രീതി) and **North Indian Style** (ഉത്തരേന്ത്യൻ രീതി). Each style uses its traditional month/calendar system (Kollavarsham Solar Month & Njattuvela for Kerala; Vikram Samvat & Amanta/Purnimanta Lunar Month for North India) with counterpart names presented in brackets.

---

## 1. User Review Required

> [!IMPORTANT]
> - **Language persistence**: Preference is saved in `shared_preferences` (`app_language`) with options `'system'`, `'en'`, `'ml'`. When `'system'` is chosen, it automatically resolves to Malayalam if the device locale starts with `ml`, otherwise English.
> - **Panchang Tabs**: The Panchang screen will feature a 2-tab view ("Kerala Style" and "North Indian Style").
> - **Bracketed Names**: In Kerala Style tab, primary terms use Kerala Malayalam/transliterated names with North Indian/Sanskrit terms in brackets. In North Indian Style tab, primary terms use North Indian/Sanskrit names with Kerala terms in brackets.

---

## 2. Proposed Changes

### Core & Configuration

#### [MODIFY] [pubspec.yaml](file:///l:/Android/Sanathana_Dharma_Clock/pubspec.yaml)
- Add `flutter_localizations` dependency from Flutter SDK.

#### [NEW] [app_language.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/core/config/app_language.dart)
- Define `AppLanguageMode` (`system`, `english`, `malayalam`) and `AppLanguage` (`english`, `malayalam`).
- Helper functions to resolve effective `Locale` from mode and platform dispatcher locale.

#### [NEW] [app_localizations.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/core/config/app_localizations.dart)
- Centralized localization delegate and string lookup class covering all UI text for both English and Malayalam.

#### [MODIFY] [panchang_names.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/core/constants/panchang_names.dart)
- Add Kerala style Malayalam and English transliterated tables for Nakshatras, Tithis, Varas, Solar Months (Kollavarsham), and Pakshas.
- Add helper methods to format bracketed names (e.g., `nakshatraWithBracket(index, style, isMalayalam)`).

---

### Models & Services

#### [MODIFY] [panchang_day.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/models/panchang_day.dart)
- Add Kollavarsham Solar Month, Kollavarsham Year, and Njattuvela fields to `CalendarInfo` / `PanchangDay`.

#### [MODIFY] [panchang_calculator.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/services/panchang_calculator.dart)
- Compute Sun's sidereal Rashi (Kollavarsham Solar Month), Kollavarsham Year, and Njattuvela (Sun's Nakshatra transit) during `_calendarFor`.

---

### State Providers

#### [NEW] [language_provider.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/providers/language_provider.dart)
- `StateNotifier` / `Notifier` for reading and saving language mode (`'system'`, `'en'`, `'ml'`) to `SharedPreferences`.
- Exposes `localeProvider` for `MaterialApp` and `appLanguageProvider` for UI string lookups.

---

### UI & Screens

#### [MODIFY] [main.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/main.dart)
- Register `flutter_localizations` delegates (`GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`, `AppLocalizations`).
- Bind `MaterialApp` `locale` to `ref.watch(localeProvider)`.

#### [MODIFY] [panchang_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/panchang_screen.dart)
- Replace static single card layout with `DefaultTabController` and `TabBar` ("Kerala Style" / "North Indian Style").
- Render Kerala style card (Kollavarsham year/month, Njattuvela, Kerala Vara/Tithi/Nakshatra/Yoga/Karana with North Indian names in brackets).
- Render North Indian style card (Vikram Samvat year/Masa, Purnimanta/Amanta, North Indian Vara/Tithi/Nakshatra/Yoga/Karana with Kerala names in brackets).

#### [MODIFY] [settings_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/settings_screen.dart)
- Add a Language selection card/option opening a modal or inline radio selection for:
  - System Default (ഉപകരണ ഭാഷ)
  - English
  - Malayalam (മലയാളം)

#### [MODIFY] [clock_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/clock_screen.dart)
#### [MODIFY] [almanac_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/almanac_screen.dart)
#### [MODIFY] [hora_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/hora_screen.dart)
#### [MODIFY] [muhurta_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/muhurta_screen.dart)
#### [MODIFY] [location_settings_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/location_settings_screen.dart)
#### [MODIFY] [about_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/about_screen.dart)
#### [MODIFY] [help_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/help_screen.dart)
- Update headers, labels, and text to use `AppLocalizations.of(context)`.

---

## 3. Verification Plan

### Automated Tests
- Run `flutter test` to ensure all existing unit tests pass.
- Add unit tests in `test/core/constants/panchang_names_test.dart` and `test/services/panchang_calculator_test.dart` for Kerala style names, Kollavarsham year/month, Njattuvela, and bracketed formatting.
- Add unit tests for `language_provider.dart` testing system locale resolution and mode switching.

### Manual Verification
- Verify language switching between System Default, English, and Malayalam in Settings.
- Verify Panchang tab renders two tabs (Kerala Style and North Indian Style).
- Confirm bracketed names match expected traditional equivalences on both tabs.
