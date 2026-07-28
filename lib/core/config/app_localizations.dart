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
  String get pranaLabel => isMl ? 'പ്രാണ' : 'Prāṇa';
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

  /// The small "Now" pill used on the Muhurta and Hora rows.
  String get now => isMl ? 'ഇപ്പോൾ' : 'Now';

  // --- Clock screen ---

  String get gettingLocation =>
      isMl ? 'സ്ഥലം കണ്ടെത്തുന്നു…' : 'Getting location…';

  String get noLocationMidnight => isMl
      ? 'സ്ഥലമില്ല — അർദ്ധരാത്രി അടിസ്ഥാനമാക്കിയ ദിവസം'
      : 'No location — midnight-anchored day';

  String get locationOffMidnight => isMl
      ? 'ഉപകരണത്തിൽ ലൊക്കേഷൻ ഓഫാണ് — അർദ്ധരാത്രി അടിസ്ഥാനമാക്കിയ ദിവസം'
      : 'Location is off on the device — using midnight-anchored day';

  String get locationDeniedMidnight => isMl
      ? 'ലൊക്കേഷൻ അനുമതി നിരസിച്ചു — അർദ്ധരാത്രി അടിസ്ഥാനമാക്കിയ ദിവസം'
      : 'Location permission denied — using midnight-anchored day';

  String get locationBlockedMidnight => isMl
      ? 'ലൊക്കേഷൻ അനുമതി തടഞ്ഞിരിക്കുന്നു — അർദ്ധരാത്രി അടിസ്ഥാനമാക്കിയ ദിവസം'
      : 'Location permission blocked — using midnight-anchored day';

  String get noFixMidnight => isMl
      ? 'ഇതുവരെ സ്ഥലം ലഭിച്ചില്ല — അർദ്ധരാത്രി അടിസ്ഥാനമാക്കിയ ദിവസം'
      : 'No location fix yet — using midnight-anchored day';

  /// The short word before the civil clock time in the readout.
  String get civilShort => isMl ? 'സാധാരണ സമയം' : 'Civil';

  /// The elapsed line under the readout, e.g. `3h 12m 40s after sunrise`.
  String sinceSunrise(int hours, int minutes, int seconds) => isMl
      ? 'സൂര്യോദയം കഴിഞ്ഞ് $hours മണിക്കൂർ $minutes മിനിറ്റ് $seconds സെക്കൻഡ്'
      : '${hours}h ${minutes}m ${seconds}s after sunrise';

  /// The count line in the middle of the dial, e.g. `Muhūrta 8 / 30`.
  String muhurtaCount(int number, int total) =>
      isMl ? 'മുഹൂർത്തം $number / $total' : 'Muhūrta $number / $total';

  /// The whole clock reading as one sentence, for screen readers.
  String clockSemantics({
    required int ghatika,
    required int vinadi,
    required int prana,
    required int muhurtaNumber,
    required int muhurtaTotal,
    required String muhurtaName,
    required String civilTime,
    required String sunrise,
    required String sinceSunriseText,
  }) {
    if (isMl) {
      return 'ധർമ്മ സമയം: ഘടിക $ghatika, വിനാഡി $vinadi, പ്രാണൻ $prana. '
          'മുഹൂർത്തം $muhurtaTotal-ൽ $muhurtaNumber, $muhurtaName. '
          'സാധാരണ സമയം $civilTime. സൂര്യോദയം $sunrise. $sinceSunriseText.';
    }
    return 'Dharma time: Ghatika $ghatika, Vinadi $vinadi, Prana $prana. '
        'Muhurta $muhurtaNumber of $muhurtaTotal, $muhurtaName. '
        'Civil time $civilTime. Sunrise $sunrise. $sinceSunriseText.';
  }

  // --- Help screen ---

  /// The short intro paragraph at the top of the Help list.
  String get helpIntro => isMl
      ? 'ഘടികാരം ഘടിക : വിനാഡി : പ്രാണൻ എന്ന ക്രമത്തിലാണ് സമയം കാണിക്കുന്നത് — '
            'മണിക്കൂർ : മിനിറ്റ് : സെക്കൻഡ് പോലെ. ദിവസം തുടങ്ങുന്നത് പ്രാദേശിക '
            'സൂര്യോദയത്തിലാണ്. കൂടുതൽ അറിയാൻ താഴെയുള്ള ഒരു യൂണിറ്റിൽ തൊടുക.'
      : 'The clock reads Ghaṭikā : Vināḍī : Prāṇa, like Hour : Minute : '
            'Second. The day starts at local sunrise. Tap a unit below to '
            'learn more.';

  /// The closing note under the Help list.
  String get helpApproxNote => isMl
      ? 'ഈ ദൈർഘ്യങ്ങൾ ഏകദേശമാണ് — ദിവസത്തിന്റെ നീളം ഋതുവിനനുസരിച്ച് അല്പം '
            'മാറും, അതിനൊത്ത് ഓരോ യൂണിറ്റും അല്പം കൂടുകയോ കുറയുകയോ ചെയ്യും.'
      : 'These lengths are approximate — the day flexes a little with the '
            'season, so each unit stretches or shrinks to fit it.';

  // --- Location permission banner (shown on the Clock screen) ---

  String get locationPermissionNeeded => isMl
      ? 'നിലവിലെ സ്ഥലത്തിനനുസരിച്ച് വിവരങ്ങൾ കാണിക്കാൻ ലൊക്കേഷൻ അനുമതി ആവശ്യമാണ്.'
      : 'Location permission is required to show the data with respect to '
            'current location.';

  String get locationPermissionBlockedHelp => isMl
      ? 'സിസ്റ്റം ക്രമീകരണങ്ങളിൽ ലൊക്കേഷൻ അനുമതി തടഞ്ഞിരിക്കുന്നു. ആപ്പ് '
            'ക്രമീകരണങ്ങളിൽ അനുമതി നൽകുക, അല്ലെങ്കിൽ സ്ഥലം സ്വയം തിരഞ്ഞെടുക്കുക.'
      : 'Location permission is blocked in system settings. Grant permission '
            'in App Settings or set a location manually.';

  String get locationPermissionMissingHelp => isMl
      ? 'ലൊക്കേഷൻ അനുമതി ഇല്ലെങ്കിൽ, നിങ്ങളുടെ സൂര്യോദയത്തിന് പകരം അർദ്ധരാത്രി '
            'അടിസ്ഥാനമാക്കിയാണ് സമയം കണക്കാക്കുന്നത്.'
      : 'Without location permission, time calculations use a default midnight '
            'anchor instead of your local sunrise.';

  String get openAppSettings =>
      isMl ? 'ആപ്പ് ക്രമീകരണങ്ങൾ തുറക്കുക' : 'Open App Settings';

  String get grantPermission => isMl ? 'അനുമതി നൽകുക' : 'Grant Permission';

  String get locationSettings =>
      isMl ? 'സ്ഥല ക്രമീകരണങ്ങൾ' : 'Location Settings';

  // --- Muhurta screen ---

  String get kalasTitle =>
      isMl ? 'കാലങ്ങളും പ്രത്യേക സമയങ്ങളും' : 'Kālas & special windows';

  String get kalasSubtitle => isMl
      ? 'ഇന്നത്തെ പകൽ (സൂര്യോദയം → അസ്തമയം) വിഭജിച്ചത്'
      : 'Split from today\'s daytime (sunrise → sunset)';

  String get kalasEmpty => isMl
      ? 'ഈ സമയങ്ങൾ കാണാൻ സൂര്യോദയവും അസ്തമയവും വേണം. ക്രമീകരണങ്ങളിൽ സ്ഥലം '
            'തിരഞ്ഞെടുക്കുക (അല്ലെങ്കിൽ തത്സമയ സ്ഥലം ലഭിക്കുന്നത് വരെ കാത്തിരിക്കുക).'
      : 'These windows need a sunrise and sunset. Set a location in Settings '
            '(or wait for a live fix) to see them.';

  String get muhurtaListTitle => isMl ? '30 മുഹൂർത്തങ്ങൾ' : 'The 30 Muhūrtas';

  String get muhurtaListSubtitle => isMl
      ? 'സൂര്യോദയം മുതൽ അടുത്ത സൂര്യോദയം വരെ 30 ആയി വിഭജിച്ചത്'
      : 'The sunrise-to-sunrise day split into 30';

  String get muhurtaListSubtitleApprox => isMl
      ? 'ഏകദേശം — സൂര്യോദയ അടിസ്ഥാനമില്ല (അർദ്ധരാത്രി ദിവസം)'
      : 'Approximate — no sunrise anchor (midnight day)';

  String get auspicious => isMl ? 'ശുഭം' : 'Auspicious';

  String get inauspicious => isMl ? 'അശുഭം' : 'Inauspicious';

  String get abhijitMuhurta => isMl ? 'അഭിജിത് മുഹൂർത്തം' : 'Abhijit Muhūrta';

  String get rahuKala => isMl ? 'രാഹു കാലം' : 'Rāhu Kālam';

  String get yamagandaKala => isMl ? 'യമഗണ്ഡം' : 'Yamagaṇḍa';

  String get gulikaKala => isMl ? 'ഗുളിക കാലം' : 'Gulika Kālam';

  // --- Hora screen ---

  String get horaEmpty => isMl
      ? 'ഹോരകൾ കാണാൻ സൂര്യോദയവും അസ്തമയവും വേണം. ക്രമീകരണങ്ങളിൽ സ്ഥലം '
            'തിരഞ്ഞെടുക്കുക (അല്ലെങ്കിൽ തത്സമയ സ്ഥലം ലഭിക്കുന്നത് വരെ കാത്തിരിക്കുക).'
      : 'Horās need a sunrise and sunset. Set a location in Settings (or wait '
            'for a live fix) to see them.';

  String get currentHora => isMl ? 'ഇപ്പോഴത്തെ ഹോര' : 'Current horā';

  String get dayHorasTitle => isMl ? 'പകൽ ഹോരകൾ' : 'Day horās';

  String get dayHorasSubtitle => isMl
      ? 'സൂര്യോദയം → അസ്തമയം 12 ആയി വിഭജിച്ചത്'
      : 'Sunrise → sunset split into 12';

  String get nightHorasTitle => isMl ? 'രാത്രി ഹോരകൾ' : 'Night horās';

  String get nightHorasSubtitle => isMl
      ? 'അസ്തമയം → അടുത്ത സൂര്യോദയം 12 ആയി വിഭജിച്ചത്'
      : 'Sunset → next sunrise split into 12';

  String get dayHora => isMl ? 'പകൽ ഹോര' : 'Day horā';

  String get nightHora => isMl ? 'രാത്രി ഹോര' : 'Night horā';

  /// How much of the current horā is left, e.g. `48 min left`.
  String timeLeft(int hours, int minutes) {
    if (isMl) {
      return hours > 0
          ? '$hours മണിക്കൂർ $minutes മിനിറ്റ് ബാക്കി'
          : '$minutes മിനിറ്റ് ബാക്കി';
    }
    return hours > 0 ? '$hours h $minutes min left' : '$minutes min left';
  }

  // --- Almanac screen ---

  String get almanacEmpty => isMl
      ? 'പഞ്ചാംഗ പട്ടികയ്ക്ക് ഒരു സ്ഥലം വേണം. വർഷം കാണാൻ ക്രമീകരണങ്ങളിൽ സ്ഥലം '
            'തിരഞ്ഞെടുക്കുക (അല്ലെങ്കിൽ തത്സമയ സ്ഥലം ലഭിക്കുന്നത് വരെ കാത്തിരിക്കുക).'
      : 'The almanac needs a location. Set one in Settings (or wait for a live '
            'fix) to see the year.';

  String get previousYear => isMl ? 'മുൻ വർഷം' : 'Previous year';

  String get nextYear => isMl ? 'അടുത്ത വർഷം' : 'Next year';

  String get sunEventsTitle =>
      isMl ? 'വർഷത്തിലെ സൂര്യ സംഭവങ്ങൾ' : 'Sun events of the year';

  String get marchEquinox => isMl ? 'മാർച്ച് വിഷുവം' : 'March equinox';

  String get juneSolstice => isMl ? 'ജൂൺ അയനാന്തം' : 'June solstice';

  String get septemberEquinox =>
      isMl ? 'സെപ്റ്റംബർ വിഷുവം' : 'September equinox';

  String get decemberSolstice => isMl ? 'ഡിസംബർ അയനാന്തം' : 'December solstice';

  String get uttarayanaStart => isMl
      ? 'ഉത്തരായനം ആരംഭം (മകര സംക്രാന്തി)'
      : 'Uttarāyaṇa begins (Makara Saṅkrānti)';

  String get dakshinayanaStart => isMl
      ? 'ദക്ഷിണായനം ആരംഭം (കർക്കിടക സംക്രാന്തി)'
      : 'Dakṣiṇāyana begins (Karka Saṅkrānti)';

  String get marchEquinoxNote => isMl
      ? 'പകലും രാത്രിയും ഏകദേശം തുല്യം. സൂര്യൻ ഭൂമധ്യരേഖ കടന്ന് വടക്കോട്ട് നീങ്ങുന്നു.'
      : 'Day and night are nearly equal. The Sun crosses the equator heading '
            'north.';

  String get juneSolsticeNote => isMl
      ? 'ഭൂമിയുടെ വടക്കൻ പകുതിയിലെ ഏറ്റവും നീളമുള്ള പകൽ.'
      : 'The longest day of the year in the northern half of the world.';

  String get septemberEquinoxNote => isMl
      ? 'പകലും രാത്രിയും ഏകദേശം തുല്യം. സൂര്യൻ ഭൂമധ്യരേഖ കടന്ന് തെക്കോട്ട് നീങ്ങുന്നു.'
      : 'Day and night are nearly equal. The Sun crosses the equator heading '
            'south.';

  String get decemberSolsticeNote => isMl
      ? 'ഭൂമിയുടെ വടക്കൻ പകുതിയിലെ ഏറ്റവും ചെറിയ പകൽ.'
      : 'The shortest day of the year in the northern half of the world.';

  String get uttarayanaStartNote => isMl
      ? 'സൂര്യൻ നിരയന മകരത്തിൽ പ്രവേശിക്കുന്നു — വടക്കോട്ടുള്ള അർദ്ധവർഷം തുടങ്ങുന്നു.'
      : 'The Sun enters sidereal Makara — the northward half-year begins.';

  String get dakshinayanaStartNote => isMl
      ? 'സൂര്യൻ നിരയന കർക്കിടകത്തിൽ പ്രവേശിക്കുന്നു — തെക്കോട്ടുള്ള അർദ്ധവർഷം '
            'തുടങ്ങുന്നു.'
      : 'The Sun enters sidereal Karka — the southward half-year begins.';

  /// Column labels of a month's day table.
  String get dayColumn => isMl ? 'ദിവസം' : 'Day';
  String get lengthColumn => isMl ? 'ദൈർഘ്യം' : 'Length';

  /// A day's length in the table, e.g. `12h 33m`. [minutes] comes in already
  /// padded to two digits.
  String dayLength(int hours, String minutes) =>
      isMl ? '$hours മ $minutes മി' : '${hours}h ${minutes}m';

  static const List<String> _monthsEn = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _monthsMl = <String>[
    'ജനുവരി',
    'ഫെബ്രുവരി',
    'മാർച്ച്',
    'ഏപ്രിൽ',
    'മേയ്',
    'ജൂൺ',
    'ജൂലൈ',
    'ഓഗസ്റ്റ്',
    'സെപ്റ്റംബർ',
    'ഒക്ടോബർ',
    'നവംബർ',
    'ഡിസംബർ',
  ];

  static const List<String> _shortMonthsEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _shortMonthsMl = <String>[
    'ജനു',
    'ഫെബ്രു',
    'മാർ',
    'ഏപ്രി',
    'മേയ്',
    'ജൂൺ',
    'ജൂലൈ',
    'ഓഗ',
    'സെപ്',
    'ഒക്ടോ',
    'നവം',
    'ഡിസം',
  ];

  /// Weekday short names, Monday first (`DateTime.weekday` order).
  static const List<String> _shortWeekdaysEn = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _shortWeekdaysMl = <String>[
    'തിങ്കൾ',
    'ചൊവ്വ',
    'ബുധൻ',
    'വ്യാഴം',
    'വെള്ളി',
    'ശനി',
    'ഞായർ',
  ];

  // --- Settings screen (card subtitles) ---

  String get locationCardSubtitle => isMl
      ? 'സൂര്യോദയത്തിനായി തത്സമയ അല്ലെങ്കിൽ സംരക്ഷിച്ച സ്ഥലം.'
      : 'Live or saved location for sunrise.';

  String get permissionsCardSubtitle => isMl
      ? 'ഈ ആപ്പ് ഉപയോഗിക്കുന്ന അനുമതികൾ.'
      : 'Permissions used by this app.';

  String get helpCardSubtitle => isMl
      ? 'ധർമ്മ സമയ യൂണിറ്റുകളുടെ അർത്ഥം.'
      : 'What the dharma time units mean.';

  String get aboutCardSubtitle =>
      isMl ? 'ഈ ആപ്പിനെക്കുറിച്ച്.' : 'About this app.';

  String get ok => isMl ? 'ശരി' : 'OK';

  // --- Location settings screen ---

  String get useLiveLocation =>
      isMl ? 'തത്സമയ സ്ഥലം ഉപയോഗിക്കുക' : 'Use live location';

  String get useLiveLocationHelp => isMl
      ? 'GPS പിന്തുടരുന്നു. ഓഫാക്കിയാൽ സംരക്ഷിച്ച സ്ഥലം ഉപയോഗിക്കും.'
      : 'Follow GPS. When off, the saved location is used.';

  String get gettingCurrentLocation =>
      isMl ? 'നിലവിലെ സ്ഥലം കണ്ടെത്തുന്നു…' : 'Getting current location…';

  String get saveCurrentLocation =>
      isMl ? 'നിലവിലെ സ്ഥലം സംരക്ഷിക്കുക' : 'Save current location';

  String get clear => isMl ? 'മായ്ക്കുക' : 'Clear';

  String get noSavedLocation =>
      isMl ? 'സംരക്ഷിച്ച സ്ഥലമില്ല' : 'No saved location';

  String get noSavedLocationHelp => isMl
      ? 'താഴെ ഒന്ന് സംരക്ഷിക്കുക, അല്ലെങ്കിൽ തത്സമയ സ്ഥലം ഉപയോഗിക്കുക.'
      : 'Save one below, or use live location.';

  String get unnamedPlace => isMl ? 'പേരില്ലാത്ത സ്ഥലം' : 'Unnamed place';

  String get editLocationName =>
      isMl ? 'സ്ഥലത്തിന്റെ പേര് മാറ്റുക' : 'Edit location name';

  String get nameThisLocation =>
      isMl ? 'ഈ സ്ഥലത്തിന് പേര് നൽകുക' : 'Name this location';

  String get locationNameLabel => isMl ? 'സ്ഥലത്തിന്റെ പേര്' : 'Location Name';

  String get locationNameHint =>
      isMl ? 'ഉദാ. വീട്, ഓഫീസ്, വാരാണസി' : 'e.g. Home, Office, Varanasi';

  String get cancel => isMl ? 'റദ്ദാക്കുക' : 'Cancel';

  String get save => isMl ? 'സംരക്ഷിക്കുക' : 'Save';

  // Live-fix status messages. Never include coordinates (security.md §9).

  String get statusGotLocation =>
      isMl ? 'നിങ്ങളുടെ സ്ഥലം ലഭിച്ചു.' : 'Got your location.';

  String get statusServiceDisabled => isMl
      ? 'ഉപകരണത്തിൽ ലൊക്കേഷൻ ഓഫാണ്.'
      : 'Location is turned off on the device.';

  String get statusPermissionDenied =>
      isMl ? 'ലൊക്കേഷൻ അനുമതി നിരസിച്ചു.' : 'Location permission was denied.';

  String get statusPermissionBlocked => isMl
      ? 'ലൊക്കേഷൻ അനുമതി തടഞ്ഞിരിക്കുന്നു. ആപ്പ് ക്രമീകരണങ്ങളിൽ അനുവദിക്കുക.'
      : 'Location permission is blocked. Allow it in app settings.';

  String get statusError => isMl
      ? 'സ്ഥലം ലഭിച്ചില്ല. വീണ്ടും ശ്രമിക്കുക.'
      : 'Could not get the location. Please try again.';

  String get savedCurrentLocation =>
      isMl ? 'നിലവിലെ സ്ഥലം സംരക്ഷിച്ചു.' : 'Saved your current location.';

  String savedNamedLocation(String name) =>
      isMl ? '"$name" എന്ന സ്ഥലം സംരക്ഷിച്ചു.' : 'Saved location "$name".';

  String get updatedLocation => isMl ? 'സ്ഥലം പുതുക്കി.' : 'Updated location.';

  String updatedLocationName(String name) => isMl
      ? 'സ്ഥലത്തിന്റെ പേര് "$name" എന്നാക്കി.'
      : 'Updated location name to "$name".';

  // --- Permissions screen ---

  String get locationAccessTitle =>
      isMl ? 'ലൊക്കേഷൻ ഉപയോഗം' : 'Location Access';

  String get locationAccessBody => isMl
      ? 'പ്രാദേശിക സൂര്യോദയം കണ്ടെത്താനും സനാതന ധർമ്മ സമയ യൂണിറ്റുകൾ (വൈദിക '
            'മണിക്കൂറുകൾ, മുഹൂർത്തം, ഹോര, പഞ്ചാംഗം) കൃത്യമായി കണക്കാക്കാനും '
            'ഉപകരണത്തിൽ മാത്രമായി ഉപയോഗിക്കുന്നു.'
      : 'Used strictly on-device to determine local sunrise and compute '
            'accurate Sanātana Dharma time units (Vedic hours, Muhurtas, Hora, '
            'and Panchang).';

  String get statusLabel => isMl ? 'നില: ' : 'Status: ';

  String get internetDisabledTitle =>
      isMl ? 'ഇന്റർനെറ്റ് ഉപയോഗം: ഇല്ല' : 'Internet Access: Disabled';

  String get internetDisabledBody => isMl
      ? 'ഈ ആപ്പ് മനഃപൂർവ്വം INTERNET അനുമതി ഒഴിവാക്കുന്നു. ഇത് പൂർണ്ണമായും '
            'ഓഫ്‌ലൈനിൽ പ്രവർത്തിക്കുന്നു — വ്യക്തിഗത വിവരങ്ങളോ സ്ഥല വിവരങ്ങളോ '
            'ഒരിക്കലും നെറ്റ്‌വർക്കിലേക്ക് അയയ്ക്കുന്നില്ല.'
      : 'This app deliberately omits the INTERNET permission. It runs 100% '
            'offline — no personal data or location coordinates are ever sent '
            'to network servers.';

  String get appSettings => isMl ? 'ആപ്പ് ക്രമീകരണങ്ങൾ' : 'App Settings';

  String get checkOrRequest =>
      isMl ? 'പരിശോധിക്കുക / ചോദിക്കുക' : 'Check / Request';

  String get liveModeActive => isMl ? 'തത്സമയ രീതി സജീവം' : 'Live mode active';

  String get usingSavedLocation =>
      isMl ? 'സംരക്ഷിച്ച സ്ഥലം ഉപയോഗിക്കുന്നു' : 'Using saved location';

  String get grantedAndActive =>
      isMl ? 'അനുമതി ലഭിച്ചു, സജീവം' : 'Granted & active';

  String get gpsDisabled =>
      isMl ? 'ഉപകരണത്തിൽ GPS ഓഫാണ്' : 'GPS service disabled on device';

  String get permissionDenied =>
      isMl ? 'അനുമതി നിരസിച്ചു' : 'Permission denied';

  String get permissionBlocked => isMl
      ? 'അനുമതി തടഞ്ഞിരിക്കുന്നു (ക്രമീകരണങ്ങളിൽ അനുവദിക്കുക)'
      : 'Permission blocked (allow in settings)';

  String get errorFetchingLocation =>
      isMl ? 'സ്ഥലം കണ്ടെത്തുന്നതിൽ പിഴവ്' : 'Error fetching location';

  // --- About screen ---

  /// The version line, e.g. `Version 2.8.5 (build 19)`. Numbers stay in
  /// Western digits, like every other number in the app.
  String versionLine(String version, String build) => isMl
      ? 'പതിപ്പ് $version (ബിൽഡ് $build)'
      : 'Version $version (build $build)';

  // --- Panchang screen (calendar card notes) ---

  String get rtuNote => isMl
      ? 'ഋതു (കാലാവസ്ഥാ കാലം). ഓരോ ഋതുവും രണ്ട് ചാന്ദ്ര മാസങ്ങൾ ഉൾക്കൊള്ളുന്നു.'
      : 'The season. Each season spans two lunar months.';

  String get uttarayanaNote => isMl
      ? 'സൂര്യന്റെ ഉത്തരായണ ഗതി (മകര സംക്രാന്തി മുതൽ).'
      : 'The Sun’s northward half-year, from Makara Saṅkrānti.';

  String get dakshinayanaNote => isMl
      ? 'സൂര്യന്റെ ദക്ഷിണായന ഗതി (കർക്കടക സംക്രാന്തി മുതൽ).'
      : 'The Sun’s southward half-year, from Karka Saṅkrānti.';

  /// Full month name for [month] (1 = January).
  String monthName(int month) =>
      (isMl ? _monthsMl : _monthsEn)[(month - 1) % 12];

  /// Short month name for [month] (1 = January).
  String shortMonthName(int month) =>
      (isMl ? _shortMonthsMl : _shortMonthsEn)[(month - 1) % 12];

  /// Short weekday name for [weekday] (`DateTime.weekday`, 1 = Monday).
  String shortWeekdayName(int weekday) =>
      (isMl ? _shortWeekdaysMl : _shortWeekdaysEn)[(weekday - 1) % 7];
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
