/// Plain-English facts about the dharma time units, shared by the Settings
/// **Help** card and the clock-screen legend so the two never drift apart.
///
/// A pure constant table with no logic, so it lives in `core/constants` next to
/// [MuhurtaNames] rather than in a service. The lengths are approximate because
/// the day flexes with the season (sunrise to next sunrise).
library;

/// One dharma time unit and how to describe it to a new user.
class DharmaUnit {
  /// The unit name, e.g. `'Ghaṭikā'`.
  final String name;

  /// The unit name in Malayalam script, e.g. `'ഘടിക'`.
  final String nameMl;

  /// The everyday clock hand it behaves like, e.g. `'hour hand'`. Empty when
  /// the unit is not shown as a hand (Muhūrta).
  final String like;

  /// The approximate length in civil time, e.g. `'about 24 minutes'`.
  final String approx;

  /// [approx] in Malayalam, e.g. `'ഏകദേശം 24 മിനിറ്റ്'`.
  final String approxMl;

  /// A short civil-time length for the dial legend, e.g. `'24 minutes'`. Same
  /// size as [approx] without the leading "about".
  final String civil;

  /// [civil] in Malayalam, e.g. `'24 മിനിറ്റ്'`.
  final String civilMl;

  /// How many of this unit make up its parent, e.g. `'60 in a day'`.
  final String count;

  /// [count] in Malayalam, e.g. `'ഒരു ദിവസത്തിൽ 60'`.
  final String countMl;

  /// A one-line plain-English explanation for the Help card.
  final String description;

  /// [description] in Malayalam.
  final String descriptionMl;

  const DharmaUnit({
    required this.name,
    required this.nameMl,
    required this.like,
    required this.approx,
    required this.approxMl,
    required this.civil,
    required this.civilMl,
    required this.count,
    required this.countMl,
    required this.description,
    required this.descriptionMl,
  });

  /// The unit name in the active language.
  String nameFor(bool isMalayalam) => isMalayalam ? nameMl : name;

  /// The short civil-time length in the active language.
  String civilFor(bool isMalayalam) => isMalayalam ? civilMl : civil;

  /// The approximate length in the active language.
  String approxFor(bool isMalayalam) => isMalayalam ? approxMl : approx;

  /// The "how many" line in the active language.
  String countFor(bool isMalayalam) => isMalayalam ? countMl : count;

  /// The full explanation in the active language.
  String descriptionFor(bool isMalayalam) =>
      isMalayalam ? descriptionMl : description;
}

/// The dharma units and their descriptions.
abstract final class DharmaUnits {
  DharmaUnits._();

  static const DharmaUnit ghatika = DharmaUnit(
    name: 'Ghaṭikā',
    nameMl: 'ഘടിക',
    like: 'hour',
    approx: 'about 24 minutes',
    approxMl: 'ഏകദേശം 24 മിനിറ്റ്',
    civil: '24 minutes',
    civilMl: '24 മിനിറ്റ്',
    count: '60 in a day',
    countMl: 'ഒരു ദിവസത്തിൽ 60',
    description:
        'The biggest hand. One Ghaṭikā is 1/60 of the day, so it works '
        'like the hour hand on a normal clock.',
    descriptionMl:
        'ഏറ്റവും വലിയ സൂചി. ഒരു ഘടിക ദിവസത്തിന്റെ 1/60 ആണ്. അതിനാൽ ഇത് '
        'സാധാരണ ഘടികാരത്തിലെ മണിക്കൂർ സൂചി പോലെ പ്രവർത്തിക്കുന്നു.',
  );

  static const DharmaUnit vinadi = DharmaUnit(
    name: 'Vināḍī',
    nameMl: 'വിനാഡി',
    like: 'minute',
    approx: 'about 24 seconds',
    approxMl: 'ഏകദേശം 24 സെക്കൻഡ്',
    civil: '24 seconds',
    civilMl: '24 സെക്കൻഡ്',
    count: '60 in a Ghaṭikā',
    countMl: 'ഒരു ഘടികയിൽ 60',
    description:
        'The middle hand. One Vināḍī is 1/60 of a Ghaṭikā, like the '
        'minute hand — it sweeps once through each Ghaṭikā.',
    descriptionMl:
        'നടുവിലെ സൂചി. ഒരു വിനാഡി ഒരു ഘടികയുടെ 1/60 ആണ്, മിനിറ്റ് സൂചി '
        'പോലെ — ഓരോ ഘടികയിലും ഇത് ഒരു തവണ ചുറ്റുന്നു.',
  );

  static const DharmaUnit prana = DharmaUnit(
    name: 'Prāṇa',
    nameMl: 'പ്രാണൻ',
    like: 'second',
    approx: 'about 4 seconds',
    approxMl: 'ഏകദേശം 4 സെക്കൻഡ്',
    civil: '4 seconds',
    civilMl: '4 സെക്കൻഡ്',
    count: '6 in a Vināḍī',
    countMl: 'ഒരു വിനാഡിയിൽ 6',
    description:
        'The fast hand. One Prāṇa is 1/6 of a Vināḍī, like the second '
        'hand — it is the one you can watch move.',
    descriptionMl:
        'വേഗതയേറിയ സൂചി. ഒരു പ്രാണൻ ഒരു വിനാഡിയുടെ 1/6 ആണ്, സെക്കൻഡ് സൂചി '
        'പോലെ — നീങ്ങുന്നത് കണ്ണുകൊണ്ട് കാണാവുന്ന സൂചി ഇതാണ്.',
  );

  static const DharmaUnit muhurta = DharmaUnit(
    name: 'Muhūrta',
    nameMl: 'മുഹൂർത്തം',
    like: '',
    approx: 'about 48 minutes',
    approxMl: 'ഏകദേശം 48 മിനിറ്റ്',
    civil: '48 minutes',
    civilMl: '48 മിനിറ്റ്',
    count: '30 in a day',
    countMl: 'ഒരു ദിവസത്തിൽ 30',
    description:
        'A larger block of two Ghaṭikā, shown on the outer ring. Each '
        'Muhūrta has its own traditional name.',
    descriptionMl:
        'രണ്ട് ഘടിക ചേർന്ന വലിയ ഒരു ഭാഗം, പുറത്തെ വളയത്തിൽ കാണിക്കുന്നു. '
        'ഓരോ മുഹൂർത്തത്തിനും അതിന്റേതായ പരമ്പരാഗത പേരുണ്ട്.',
  );

  static const DharmaUnit hora = DharmaUnit(
    name: 'Horā',
    nameMl: 'ഹോര',
    like: '',
    approx: 'about 60 minutes',
    approxMl: 'ഏകദേശം 60 മിനിറ്റ്',
    civil: '60 minutes',
    civilMl: '60 മിനിറ്റ്',
    count: '24 in a day (12 day + 12 night)',
    countMl: 'ഒരു ദിവസത്തിൽ 24 (12 പകൽ + 12 രാത്രി)',
    description:
        'An elastic hour, shown on the Hora tab. The daytime (sunrise to '
        'sunset) splits into 12 horās and the night into 12 more, so day '
        'horās run longer in summer and shorter in winter. Each horā is '
        'ruled by one of the 7 classical planets. The first horā after '
        'sunrise is ruled by that weekday\'s lord — Sunday starts with Sūrya '
        '(Sun), Monday with Chandra (Moon), and so on — then the fixed order '
        'Sūrya → Śukra → Budha → Chandra → Śani → Guru → Maṅgala repeats. '
        'Tradition links each planet\'s horā to activities it favours, such '
        'as Guru (Jupiter) for learning or Śukra (Venus) for art.',
    descriptionMl:
        'ഹോര ടാബിൽ കാണിക്കുന്ന ഇലാസ്തികമായ ഒരു മണിക്കൂർ. പകൽ (സൂര്യോദയം '
        'മുതൽ അസ്തമയം വരെ) 12 ഹോരകളായും രാത്രി 12 ഹോരകളായും വിഭജിക്കുന്നു. '
        'അതിനാൽ വേനലിൽ പകൽ ഹോരകൾ നീളം കൂടുതലും മഞ്ഞുകാലത്ത് കുറവുമാകും. '
        'ഓരോ ഹോരയും 7 പരമ്പരാഗത ഗ്രഹങ്ങളിൽ ഒന്നിന്റെ അധീനതയിലാണ്. '
        'സൂര്യോദയത്തിനു ശേഷമുള്ള ആദ്യ ഹോര ആ ആഴ്ചദിവസത്തിന്റെ അധിപന്റേതാണ് — '
        'ഞായർ സൂര്യനിൽ തുടങ്ങുന്നു, തിങ്കൾ ചന്ദ്രനിൽ, അങ്ങനെ — പിന്നെ '
        'സൂര്യൻ → ശുക്രൻ → ബുധൻ → ചന്ദ്രൻ → ശനി → ഗുരു → ചൊവ്വ എന്ന ക്രമം '
        'ആവർത്തിക്കുന്നു. ഓരോ ഗ്രഹത്തിന്റെയും ഹോര ചില പ്രവൃത്തികൾക്ക് '
        'അനുകൂലമാണെന്ന് പാരമ്പര്യം പറയുന്നു — ഉദാഹരണത്തിന് പഠനത്തിന് ഗുരുവിന്റെ '
        'ഹോരയും കലയ്ക്ക് ശുക്രന്റെ ഹോരയും.',
  );

  /// The three units shown as hands, in reading order (Ghaṭikā : Vināḍī : Prāṇa).
  static const List<DharmaUnit> hands = <DharmaUnit>[ghatika, vinadi, prana];

  /// Every unit, for the Help card (the three hands plus Muhūrta and Horā).
  static const List<DharmaUnit> all = <DharmaUnit>[
    ghatika,
    vinadi,
    prana,
    muhurta,
    hora,
  ];
}
