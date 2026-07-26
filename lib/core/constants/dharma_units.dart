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

  /// The everyday clock hand it behaves like, e.g. `'hour hand'`. Empty when
  /// the unit is not shown as a hand (Muhūrta).
  final String like;

  /// The approximate length in civil time, e.g. `'about 24 minutes'`.
  final String approx;

  /// A short civil-time length for the dial legend, e.g. `'24 minutes'`. Same
  /// size as [approx] without the leading "about".
  final String civil;

  /// How many of this unit make up its parent, e.g. `'60 in a day'`.
  final String count;

  /// A one-line plain-English explanation for the Help card.
  final String description;

  const DharmaUnit({
    required this.name,
    required this.like,
    required this.approx,
    required this.civil,
    required this.count,
    required this.description,
  });
}

/// The dharma units and their descriptions.
abstract final class DharmaUnits {
  DharmaUnits._();

  static const DharmaUnit ghatika = DharmaUnit(
    name: 'Ghaṭikā',
    like: 'hour',
    approx: 'about 24 minutes',
    civil: '24 minutes',
    count: '60 in a day',
    description:
        'The biggest hand. One Ghaṭikā is 1/60 of the day, so it works '
        'like the hour hand on a normal clock.',
  );

  static const DharmaUnit vinadi = DharmaUnit(
    name: 'Vināḍī',
    like: 'minute',
    approx: 'about 24 seconds',
    civil: '24 seconds',
    count: '60 in a Ghaṭikā',
    description:
        'The middle hand. One Vināḍī is 1/60 of a Ghaṭikā, like the '
        'minute hand — it sweeps once through each Ghaṭikā.',
  );

  static const DharmaUnit prana = DharmaUnit(
    name: 'Prāṇa',
    like: 'second',
    approx: 'about 4 seconds',
    civil: '4 seconds',
    count: '6 in a Vināḍī',
    description:
        'The fast hand. One Prāṇa is 1/6 of a Vināḍī, like the second '
        'hand — it is the one you can watch move.',
  );

  static const DharmaUnit muhurta = DharmaUnit(
    name: 'Muhūrta',
    like: '',
    approx: 'about 48 minutes',
    civil: '48 minutes',
    count: '30 in a day',
    description:
        'A larger block of two Ghaṭikā, shown on the outer ring. Each '
        'Muhūrta has its own traditional name.',
  );

  static const DharmaUnit hora = DharmaUnit(
    name: 'Horā',
    like: '',
    approx: 'about 60 minutes',
    civil: '60 minutes',
    count: '24 in a day (12 day + 12 night)',
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
