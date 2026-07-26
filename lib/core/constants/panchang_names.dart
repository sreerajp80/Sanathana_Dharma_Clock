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

  static const String purnima = 'Pūrṇimā';
  static const String amavasya = 'Amāvāsyā';

  static const String shuklaPaksha = 'Śukla Pakṣa';
  static const String krishnaPaksha = 'Kṛṣṇa Pakṣa';

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

  /// North Indian name of tithi [index].
  static String tithi(int index) {
    final i = index % 30;
    final inPaksha = i % 15;
    if (inPaksha == 14) return i < 15 ? purnima : amavasya;
    return _tithiBase[inPaksha];
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
    final north = tithi(index);
    final kerala = keralaTithi(index, isMalayalam: isMalayalam);
    if (keralaStyle) {
      return '$kerala ($north)';
    } else {
      return isMalayalam ? '$north ($kerala)' : '$north ($kerala)';
    }
  }

  /// North Indian Paksha name.
  static String paksha(int index) =>
      (index % 30) < 15 ? shuklaPaksha : krishnaPaksha;

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
    final north = paksha(index);
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
    final north = nakshatras[i];
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

  static const String kimstughna = 'Kiṁstughna';
  static const List<String> endFixedKaranas = <String>[
    'Śakuni',
    'Chatuṣpāda',
    'Nāga',
  ];

  static String karana(int index) {
    final i = index % 60;
    if (i == 0) return kimstughna;
    if (i >= 57) return endFixedKaranas[i - 57];
    return movableKaranas[(i - 1) % 7];
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

  static String vara(int weekday) => varas[weekday] ?? varas[DateTime.sunday]!;

  static String keralaVara(int weekday, {required bool isMalayalam}) {
    final map = isMalayalam ? keralaVarasMl : keralaVarasEn;
    return map[weekday] ?? map[DateTime.sunday]!;
  }

  static String varaFormatted(
    int weekday, {
    required bool keralaStyle,
    required bool isMalayalam,
  }) {
    final north = vara(weekday);
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

  static const String adhika = 'Adhika';

  static String masa(int index) => masas[index % 12];

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
    final northMasa = (isAdhika ? '$adhika ' : '') + masa(masaIndex);
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

  static String rtuOfMasa(int masaIndex) => rtus[(masaIndex % 12) ~/ 2];

  static const String uttarayana = 'Uttarāyaṇa';
  static const String dakshinayana = 'Dakṣiṇāyana';
}
