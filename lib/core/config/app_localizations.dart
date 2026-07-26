import 'package:flutter/material.dart';
import 'app_language.dart';

/// App localization strings provider for English and Malayalam.
class AppLocalizations {
  final Locale locale;
  final AppLanguage appLanguage;

  AppLocalizations(this.locale)
    : appLanguage = locale.languageCode == 'ml'
          ? AppLanguage.malayalam
          : AppLanguage.english;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isMl => appLanguage.isMalayalam;

  // Screen & Navigation Titles
  String get appTitle =>
      isMl ? 'സനാതന ധർമ്മ ഘടികാരം' : 'Sanathana Dharma Clock';
  String get clockTab => isMl ? 'ഘടികാരം' : 'Clock';
  String get panchangTab => isMl ? 'പഞ്ചാംഗം' : 'Panchang';
  String get almanacTab => isMl ? 'ആൽമനാക്ക്' : 'Almanac';
  String get horaTab => isMl ? 'ഹോര' : 'Hora';
  String get muhurtaTab => isMl ? 'മുഹൂർത്തം' : 'Muhurta';
  String get settingsTitle => isMl ? 'ക്രമീകരണങ്ങൾ' : 'Settings';
  String get locationTitle => isMl ? 'സ്ഥലം' : 'Location';
  String get permissionsTitle => isMl ? 'അനുമതികൾ' : 'Permissions';
  String get helpTitle => isMl ? 'സഹായം' : 'Help';
  String get aboutTitle => isMl ? 'കുറിപ്പ്' : 'About';
  String get languageTitle => isMl ? 'ഭാഷ (Language)' : 'Language';

  // Language settings strings
  String get systemDefault =>
      isMl ? 'സിസ്റ്റം ഭാഷ (System Default)' : 'System Default';
  String get english => 'English';
  String get malayalam => 'മലയാളം (Malayalam)';
  String get selectLanguage => isMl ? 'ഭാഷ തിരഞ്ഞെടുക്കുക' : 'Select Language';

  // Panchang Screen strings
  String get keralaStyleTab => isMl ? 'കേരള രീതി' : 'Kerala Style';
  String get northIndianStyleTab =>
      isMl ? 'ഉത്തരേന്ത്യൻ രീതി' : 'North Indian Style';
  String get panchangHeader =>
      isMl ? 'ധർമ്മ ദിനത്തിലെ പഞ്ചാംഗം' : 'Panchang of the dharma day';
  String get panchangSubheader => isMl
      ? 'സൂര്യോദയം മുതൽ - താഴെ കാണിച്ചിരിക്കുന്ന ഓരോ മൂല്യവും സൂര്യോദയ സമയത്തുള്ളതാണ്.'
      : 'From sunrise — each value below is the one at sunrise, and the time it changes to the next.';
  String get calendarCardTitle => isMl ? 'കലണ്ടർ' : 'Calendar';
  String get moonCardTitle => isMl ? 'ചന്ദ്രൻ' : 'Moon';
  String get moonrise => isMl ? 'ചന്ദ്രോദയം' : 'Moonrise';
  String get moonset => isMl ? 'ചന്ദ്രാസ്തമയം' : 'Moonset';
  String get noMoonriseToday =>
      isMl ? 'ഇന്ന് ചന്ദ്രോദയമില്ല' : 'No moonrise today';
  String get noMoonsetToday =>
      isMl ? 'ഇന്ന് ചന്ദ്രാസ്തമയമില്ല' : 'No moonset today';

  // Panchang Labels
  String get varaLabel => isMl ? 'വാരം / ആഴ്ച' : 'Vāra';
  String get tithiLabel => isMl ? 'തിഥി' : 'Tithi';
  String get nakshatraLabel => isMl ? 'നക്ഷത്രം' : 'Nakṣatra';
  String get yogaLabel => isMl ? 'യോഗം' : 'Yoga';
  String get karanaLabel => isMl ? 'കരണം' : 'Karaṇa';
  String get njattuvelaLabel =>
      isMl ? 'ഞാറ്റുവേല' : 'Ñāṟṟuvēla (Solar Nakshatra)';
  String get masaLabel => isMl ? 'മാസം' : 'Māsa (Month)';
  String get yearLabel => isMl ? 'വർഷം' : 'Year';
  String get pakshaLabel => isMl ? 'പക്ഷം' : 'Pakṣa';
  String get rtuLabel => isMl ? 'ഋതു' : 'Ṛtu (Season)';
  String get ayanaLabel => isMl ? 'അയനം' : 'Ayana';

  // Clock Screen strings
  String get ghazikaLabel => isMl ? 'ഘടിക' : 'Ghaṭikā';
  String get vinadiLabel => isMl ? 'വിനാഡി' : 'Vināḍī';
  String get pranaLabel => isMl ? 'പ്രാണൻ' : 'Prāṇa';
  String get sunriseLabel => isMl ? 'സൂര്യോദയം' : 'Sunrise';
  String get sunsetLabel => isMl ? 'സൂര്യ അസ്തമയം' : 'Sunset';
  String get civilTimeLabel => isMl ? 'ഇഷ്ട സമയം (Civil Time)' : 'Civil Time';
  String get liveLocation => isMl ? 'തത്സമയ സ്ഥലം' : 'Live location';
  String get savedLocation => isMl ? 'സംരക്ഷിച്ച സ്ഥലം' : 'Saved location';

  // General & Banner
  String get setLocationBanner => isMl
      ? 'കൃത്യമായ സൂര്യോദയവും പഞ്ചാംഗവും കാണുന്നതിന് സ്ഥലം തിരഞ്ഞെടുക്കുക.'
      : 'Please set a location to calculate sunrise and Panchang.';
  String get openSettings => isMl ? 'ക്രമീകരണങ്ങൾ തുറക്കുക' : 'Open Settings';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ml'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
