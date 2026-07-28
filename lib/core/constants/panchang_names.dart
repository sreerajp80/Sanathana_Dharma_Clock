/// The name tables of the five Panchang limbs (plan 20260723_075550 & 20260726_192500).
///
/// Pure constant tables with no logic beyond an index lookup. Supports both
/// North Indian (Sanskrit) and Kerala regional naming conventions, with
/// cross-reference bracket formatting.
abstract final class PanchangNames {
  PanchangNames._();

  /// The 15 tithi names of one pakṣa (half month). Index 0 = Pratipadā.
  /// The 15th slot is replaced by [purnima] / [amavasya] per pakṣa.
  static const List<String> _tithiBase = <String>[
    'Pratipadā',
    'Dvitīyā',
    'Tṛtīyā',
    'Chaturthī',
    'Pañchamī',
    'Ṣaṣṭhī',
    'Saptamī',
    'Aṣṭamī',
    'Navamī',
    'Daśamī',
    'Ekādaśī',
    'Dvādaśī',
    'Trayodaśī',
    'Chaturdaśī',
  ];

  /// The same 15 tithi names in Malayalam script.
  static const List<String> _tithiBaseMl = <String>[
    'പ്രതിപദ',
    'ദ്വിതീയ',
    'തൃതീയ',
    'ചതുർത്ഥി',
    'പഞ്ചമി',
    'ഷഷ്ഠി',
    'സപ്തമി',
    'അഷ്ടമി',
    'നവമി',
    'ദശമി',
    'ഏകാദശി',
    'ദ്വാദശി',
    'ത്രയോദശി',
    'ചതുർദശി',
  ];

  static const String purnima = 'Pūrṇimā';
  static const String purnimaMl = 'പൂർണ്ണിമ';
  static const String amavasya = 'Amāvāsyā';
  static const String amavasyaMl = 'അമാവാസ്യ';

  static const String shuklaPaksha = 'Śukla Pakṣa';
  static const String shuklaPakshaMl = 'ശുക്ല പക്ഷം';
  static const String krishnaPaksha = 'Kṛṣṇa Pakṣa';
  static const String krishnaPakshaMl = 'കൃഷ്ണ പക്ഷം';

  // Kerala Tithi Tables
  static const List<String> _keralaTithiBaseEn = <String>[
    'Prathipadam',
    'Dvithiya',
    'Thrithiya',
    'Chathurthi',
    'Panchami',
    'Shashti',
    'Saptami',
    'Ashtami',
    'Navami',
    'Dasami',
    'Ekadasi',
    'Dvadasi',
    'Thrayodasi',
    'Chathurdasi',
  ];

  static const List<String> _keralaTithiBaseMl = <String>[
    'പ്രതിപദം',
    'ദ്വിതീയ',
    'തൃതീയ',
    'ചതുർത്ഥി',
    'പഞ്ചമി',
    'ഷഷ്ടി',
    'സപ്തമി',
    'അഷ്ടമി',
    'നവമി',
    'ദശമി',
    'ഏകാദശി',
    'ദ്വാദശി',
    'ത്രയോദശി',
    'ചതുർദ്ദശി',
  ];

  static const String keralaPurnimaEn = 'Pournami (Velutha Vavu)';
  static const String keralaPurnimaMl = 'പൗർണ്ണമി (വെളുത്ത വാവ്)';
  static const String keralaAmavasyaEn = 'Amavasi (Karutha Vavu)';
  static const String keralaAmavasyaMl = 'അമാവാസി (കറുത്ത വാവ്)';

  static const String keralaShuklaPakshaEn = 'Velutha Paksham (Shukla)';
  static const String keralaShuklaPakshaMl = 'വെളുത്ത പക്ഷം (ശുക്ല പക്ഷം)';
  static const String keralaKrishnaPakshaEn = 'Karutha Paksham (Krishna)';
  static const String keralaKrishnaPakshaMl = 'കറുത്ത പക്ഷം (കൃഷ്ണ പക്ഷം)';

  /// North Indian name of tithi [index], in Latin or Malayalam script.
  static String tithi(int index, {bool isMalayalam = false}) {
    final i = index % 30;
    final inPaksha = i % 15;
    if (inPaksha == 14) {
      if (i < 15) return isMalayalam ? purnimaMl : purnima;
      return isMalayalam ? amavasyaMl : amavasya;
    }
    return isMalayalam ? _tithiBaseMl[inPaksha] : _tithiBase[inPaksha];
  }

  /// Kerala name of tithi [index] (English or Malayalam).
  static String keralaTithi(int index, {required bool isMalayalam}) {
    final i = index % 30;
    final inPaksha = i % 15;
    if (inPaksha == 14) {
      return i < 15
          ? (isMalayalam ? keralaPurnimaMl : keralaPurnimaEn)
          : (isMalayalam ? keralaAmavasyaMl : keralaAmavasyaEn);
    }
    return isMalayalam
        ? _keralaTithiBaseMl[inPaksha]
        : _keralaTithiBaseEn[inPaksha];
  }

  /// Tithi with bracketed counterpart name.
  static String tithiFormatted(
    int index, {
    required bool keralaStyle,
    required bool isMalayalam,
  }) {
    final north = tithi(index, isMalayalam: isMalayalam);
    final kerala = keralaTithi(index, isMalayalam: isMalayalam);
    return keralaStyle ? '$kerala ($north)' : '$north ($kerala)';
  }

  /// North Indian Paksha name, in Latin or Malayalam script.
  static String paksha(int index, {bool isMalayalam = false}) =>
      (index % 30) < 15
      ? (isMalayalam ? shuklaPakshaMl : shuklaPaksha)
      : (isMalayalam ? krishnaPakshaMl : krishnaPaksha);

  /// Kerala Paksha name.
  static String keralaPaksha(int index, {required bool isMalayalam}) =>
      (index % 30) < 15
      ? (isMalayalam ? keralaShuklaPakshaMl : keralaShuklaPakshaEn)
      : (isMalayalam ? keralaKrishnaPakshaMl : keralaKrishnaPakshaEn);

  /// Paksha with bracketed counterpart name.
  static String pakshaFormatted(
    int index, {
    required bool keralaStyle,
    required bool isMalayalam,
  }) {
    final north = paksha(index, isMalayalam: isMalayalam);
    final kerala = keralaPaksha(index, isMalayalam: isMalayalam);
    return keralaStyle ? '$kerala ($north)' : '$north ($kerala)';
  }

  /// North Indian Nakshatras (index 0 = Aśvinī).
  static const List<String> nakshatras = <String>[
    'Aśvinī',
    'Bharaṇī',
    'Kṛttikā',
    'Rohiṇī',
    'Mṛgaśirā',
    'Ārdrā',
    'Punarvasu',
    'Puṣya',
    'Āśleṣā',
    'Maghā',
    'Pūrva Phalgunī',
    'Uttara Phalgunī',
    'Hasta',
    'Chitrā',
    'Svātī',
    'Viśākhā',
    'Anurādhā',
    'Jyeṣṭhā',
    'Mūla',
    'Pūrva Āṣāḍhā',
    'Uttara Āṣāḍhā',
    'Śravaṇa',
    'Dhaniṣṭhā',
    'Śatabhiṣā',
    'Pūrva Bhādrapadā',
    'Uttara Bhādrapadā',
    'Revatī',
  ];

  /// The same 27 North Indian nakṣatra names in Malayalam script.
  static const List<String> nakshatrasMl = <String>[
    'അശ്വിനി',
    'ഭരണി',
    'കൃത്തിക',
    'രോഹിണി',
    'മൃഗശിര',
    'ആർദ്ര',
    'പുനർവസു',
    'പുഷ്യ',
    'ആശ്ലേഷ',
    'മഘ',
    'പൂർവ ഫൽഗുനി',
    'ഉത്തര ഫൽഗുനി',
    'ഹസ്ത',
    'ചിത്ര',
    'സ്വാതി',
    'വിശാഖ',
    'അനുരാധ',
    'ജ്യേഷ്ഠ',
    'മൂല',
    'പൂർവാഷാഢ',
    'ഉത്തരാഷാഢ',
    'ശ്രവണ',
    'ധനിഷ്ഠ',
    'ശതഭിഷ',
    'പൂർവ ഭാദ്രപദ',
    'ഉത്തര ഭാദ്രപദ',
    'രേവതി',
  ];

  // Kerala Nakshatra English Transliterations
  static const List<String> keralaNakshatrasEn = <String>[
    'Aswathi',
    'Bharani',
    'Karthika',
    'Rohini',
    'Makayiram',
    'Thiruvathira',
    'Punartham',
    'Pooyam',
    'Ayilyam',
    'Makam',
    'Pooram',
    'Uthram',
    'Atham',
    'Chithira',
    'Chothi',
    'Vishakam',
    'Anizham',
    'Thrikketta',
    'Moolam',
    'Pooradam',
    'Uthradam',
    'Thiruvonam',
    'Avittam',
    'Chathayam',
    'Pooruruttathi',
    'Uthrattathi',
    'Revathi',
  ];

  // Kerala Nakshatra Malayalam Names
  static const List<String> keralaNakshatrasMl = <String>[
    'അശ്വതി',
    'ഭരണി',
    'കാർത്തിക',
    'രോഹിണി',
    'മകയിരം',
    'തിരുവാതിര',
    'പുണർതം',
    'പൂയം',
    'ആയില്യം',
    'മകം',
    'പൂരം',
    'ഉത്രം',
    'അത്തം',
    'ചിത്തിര',
    'ചോതി',
    'വിശാഖം',
    'അനിഴം',
    'തൃക്കേട്ട',
    'മൂലം',
    'പൂരാടം',
    'ഉത്രാടം',
    'തിരുവോണം',
    'അവിട്ടം',
    'ചതയം',
    'പൂരുരുട്ടാതി',
    'ഉത്രട്ടാതി',
    'രേവതി',
  ];

  /// Nakshatra with bracketed counterpart name.
  static String nakshatraFormatted(
    int index, {
    required bool keralaStyle,
    required bool isMalayalam,
  }) {
    final i = index % 27;
    final north = isMalayalam ? nakshatrasMl[i] : nakshatras[i];
    final kerala = isMalayalam ? keralaNakshatrasMl[i] : keralaNakshatrasEn[i];
    return keralaStyle ? '$kerala ($north)' : '$north ($kerala)';
  }

  /// The 27 yogas, index 0 = Viṣkambha.
  static const List<String> yogas = <String>[
    'Viṣkambha',
    'Prīti',
    'Āyuṣmān',
    'Saubhāgya',
    'Śobhana',
    'Atigaṇḍa',
    'Sukarma',
    'Dhṛti',
    'Śūla',
    'Gaṇḍa',
    'Vṛddhi',
    'Dhruva',
    'Vyāghāta',
    'Harṣaṇa',
    'Vajra',
    'Siddhi',
    'Vyatīpāta',
    'Varīyān',
    'Parigha',
    'Śiva',
    'Siddha',
    'Sādhya',
    'Śubha',
    'Śukla',
    'Brahma',
    'Indra',
    'Vaidhṛti',
  ];

  /// The same 27 yogas in Malayalam script.
  static const List<String> yogasMl = <String>[
    'വിഷ്കംഭം',
    'പ്രീതി',
    'ആയുഷ്മാൻ',
    'സൗഭാഗ്യം',
    'ശോഭനം',
    'അതിഗണ്ഡം',
    'സുകർമ്മം',
    'ധൃതി',
    'ശൂലം',
    'ഗണ്ഡം',
    'വൃദ്ധി',
    'ധ്രുവം',
    'വ്യാഘാതം',
    'ഹർഷണം',
    'വജ്രം',
    'സിദ്ധി',
    'വ്യതീപാതം',
    'വരീയാൻ',
    'പരിഘം',
    'ശിവം',
    'സിദ്ധം',
    'സാധ്യം',
    'ശുഭം',
    'ശുക്ലം',
    'ബ്രഹ്മം',
    'ഇന്ദ്രം',
    'വൈധൃതി',
  ];

  /// Name of yoga [index] (0–26), in Latin or Malayalam script.
  static String yogaName(int index, {bool isMalayalam = false}) =>
      isMalayalam ? yogasMl[index % 27] : yogas[index % 27];

  /// The 7 movable karaṇas.
  static const List<String> movableKaranas = <String>[
    'Bava',
    'Bālava',
    'Kaulava',
    'Taitila',
    'Gara',
    'Vaṇija',
    'Viṣṭi',
  ];

  /// The same 7 movable karaṇas in Malayalam script.
  static const List<String> movableKaranasMl = <String>[
    'ബവം',
    'ബാലവം',
    'കൗലവം',
    'തൈതിലം',
    'ഗരം',
    'വണിജം',
    'വിഷ്ടി',
  ];

  static const String kimstughna = 'Kiṁstughna';
  static const String kimstughnaMl = 'കിംസ്തുഘ്നം';
  static const List<String> endFixedKaranas = <String>[
    'Śakuni',
    'Chatuṣpāda',
    'Nāga',
  ];

  /// The same 3 closing fixed karaṇas in Malayalam script.
  static const List<String> endFixedKaranasMl = <String>[
    'ശകുനി',
    'ചതുഷ്പാദം',
    'നാഗം',
  ];

  /// Name of the karaṇa in slot [index] (0–59), in Latin or Malayalam script.
  static String karana(int index, {bool isMalayalam = false}) {
    final i = index % 60;
    if (i == 0) return isMalayalam ? kimstughnaMl : kimstughna;
    if (i >= 57) {
      return isMalayalam ? endFixedKaranasMl[i - 57] : endFixedKaranas[i - 57];
    }
    final slot = (i - 1) % 7;
    return isMalayalam ? movableKaranasMl[slot] : movableKaranas[slot];
  }

  /// North Indian Weekdays.
  static const Map<int, String> varas = <int, String>{
    DateTime.sunday: 'Ravivāra (Sunday)',
    DateTime.monday: 'Somavāra (Monday)',
    DateTime.tuesday: 'Maṅgalavāra (Tuesday)',
    DateTime.wednesday: 'Budhavāra (Wednesday)',
    DateTime.thursday: 'Guruvāra (Thursday)',
    DateTime.friday: 'Śukravāra (Friday)',
    DateTime.saturday: 'Śanivāra (Saturday)',
  };

  /// The same North Indian weekday names in Malayalam script.
  ///
  /// Kept plain (no bracketed gloss) because the Kerala name shown beside it
  /// already carries the everyday Malayalam weekday, and a gloss here would
  /// nest one bracket inside another.
  static const Map<int, String> varasMl = <int, String>{
    DateTime.sunday: 'രവിവാരം',
    DateTime.monday: 'സോമവാരം',
    DateTime.tuesday: 'മംഗളവാരം',
    DateTime.wednesday: 'ബുധവാരം',
    DateTime.thursday: 'ഗുരുവാരം',
    DateTime.friday: 'ശുക്രവാരം',
    DateTime.saturday: 'ശനിവാരം',
  };

  // Kerala Weekday Names
  static const Map<int, String> keralaVarasEn = <int, String>{
    DateTime.sunday: 'Njayar (Sunday)',
    DateTime.monday: 'Thingal (Monday)',
    DateTime.tuesday: 'Chovva (Tuesday)',
    DateTime.wednesday: 'Budhan (Wednesday)',
    DateTime.thursday: 'Vyazham (Thursday)',
    DateTime.friday: 'Velli (Friday)',
    DateTime.saturday: 'Sani (Saturday)',
  };

  static const Map<int, String> keralaVarasMl = <int, String>{
    DateTime.sunday: 'ഞായർ (ഞായറാഴ്ച)',
    DateTime.monday: 'തിങ്കൾ (തിങ്കളാഴ്ച)',
    DateTime.tuesday: 'ചൊവ്വ (ചൊവ്വാഴ്ച)',
    DateTime.wednesday: 'ബുധൻ (ബുധനാഴ്ച)',
    DateTime.thursday: 'വ്യാഴം (വ്യാഴാഴ്ച)',
    DateTime.friday: 'വെള്ളി (വെള്ളിയാഴ്ച)',
    DateTime.saturday: 'ശനി (ശനിയാഴ്ച)',
  };

  static String vara(int weekday, {bool isMalayalam = false}) {
    final map = isMalayalam ? varasMl : varas;
    return map[weekday] ?? map[DateTime.sunday]!;
  }

  static String keralaVara(int weekday, {required bool isMalayalam}) {
    final map = isMalayalam ? keralaVarasMl : keralaVarasEn;
    return map[weekday] ?? map[DateTime.sunday]!;
  }

  static String varaFormatted(
    int weekday, {
    required bool keralaStyle,
    required bool isMalayalam,
  }) {
    final north = vara(weekday, isMalayalam: isMalayalam);
    final kerala = keralaVara(weekday, isMalayalam: isMalayalam);
    return keralaStyle ? '$kerala ($north)' : '$north ($kerala)';
  }

  /// North Indian Lunar Month Names (Amanta/Purnimanta).
  static const List<String> masas = <String>[
    'Chaitra',
    'Vaiśākha',
    'Jyeṣṭha',
    'Āṣāḍha',
    'Śrāvaṇa',
    'Bhādrapada',
    'Āśvina',
    'Kārttika',
    'Mārgaśīrṣa',
    'Pauṣa',
    'Māgha',
    'Phālguna',
  ];

  /// The same 12 lunar month names in Malayalam script.
  static const List<String> masasMl = <String>[
    'ചൈത്രം',
    'വൈശാഖം',
    'ജ്യേഷ്ഠം',
    'ആഷാഢം',
    'ശ്രാവണം',
    'ഭാദ്രപദം',
    'ആശ്വിനം',
    'കാർത്തികം',
    'മാർഗശീർഷം',
    'പൗഷം',
    'മാഘം',
    'ഫാൽഗുനം',
  ];

  static const String adhika = 'Adhika';
  static const String adhikaMl = 'അധിക';

  static String masa(int index, {bool isMalayalam = false}) =>
      isMalayalam ? masasMl[index % 12] : masas[index % 12];

  // Kerala Solar Month (Kollavarsham) Names
  static const List<String> keralaSolarMasasEn = <String>[
    'Medam',
    'Edavam',
    'Mithunam',
    'Karkidakam',
    'Chingam',
    'Kanni',
    'Thulam',
    'Vrischikam',
    'Dhanu',
    'Makaram',
    'Kumbham',
    'Meenam',
  ];

  static const List<String> keralaSolarMasasMl = <String>[
    'മേടം',
    'ഇടവം',
    'മിഥുനം',
    'കർക്കിടകം',
    'ചിങ്ങം',
    'കന്നി',
    'തുലാം',
    'വൃശ്ചികം',
    'ധനു',
    'മകരം',
    'കുംഭം',
    'മീനം',
  ];

  static String keralaSolarMasa(int index, {required bool isMalayalam}) =>
      isMalayalam
      ? keralaSolarMasasMl[index % 12]
      : keralaSolarMasasEn[index % 12];

  /// Format Masa with bracketed counterpart.
  static String masaFormatted({
    required int masaIndex,
    required int solarMasaIndex,
    required bool keralaStyle,
    required bool isMalayalam,
    bool isAdhika = false,
  }) {
    final adhikaPrefix = isMalayalam ? adhikaMl : adhika;
    final northMasa =
        (isAdhika ? '$adhikaPrefix ' : '') +
        masa(masaIndex, isMalayalam: isMalayalam);
    final keralaMasa = keralaSolarMasa(
      solarMasaIndex,
      isMalayalam: isMalayalam,
    );
    return keralaStyle
        ? '$keralaMasa ($northMasa)'
        : '$northMasa ($keralaMasa)';
  }

  static const List<String> rtus = <String>[
    'Vasanta (spring)',
    'Grīṣma (summer)',
    'Varṣā (monsoon)',
    'Śarad (autumn)',
    'Hemanta (early winter)',
    'Śiśira (late winter)',
  ];

  /// The same 6 seasons in Malayalam script, each with a Malayalam gloss.
  static const List<String> rtusMl = <String>[
    'വസന്തം (വസന്തകാലം)',
    'ഗ്രീഷ്മം (വേനൽക്കാലം)',
    'വർഷം (മഴക്കാലം)',
    'ശരത്ത് (ശരത്കാലം)',
    'ഹേമന്തം (ഹേമന്തകാലം)',
    'ശിശിരം (ശിശിരകാലം)',
  ];

  static String rtuOfMasa(int masaIndex, {bool isMalayalam = false}) {
    final i = (masaIndex % 12) ~/ 2;
    return isMalayalam ? rtusMl[i] : rtus[i];
  }

  static const String uttarayana = 'Uttarāyaṇa';
  static const String uttarayanaMl = 'ഉത്തരായനം';
  static const String dakshinayana = 'Dakṣiṇāyana';
  static const String dakshinayanaMl = 'ദക്ഷിണായനം';

  /// The ayana name in Latin or Malayalam script.
  static String ayanaName({
    required bool isUttarayana,
    bool isMalayalam = false,
  }) {
    if (isUttarayana) return isMalayalam ? uttarayanaMl : uttarayana;
    return isMalayalam ? dakshinayanaMl : dakshinayana;
  }
}
