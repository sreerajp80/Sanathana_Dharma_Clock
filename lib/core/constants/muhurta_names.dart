/// The 30 traditional names of the day's Muhūrta, indexed 0–29 from sunrise.
///
/// A Muhūrta is 1/30 of the *ahorātra* (sunrise-to-sunrise day). Classical texts
/// name each one; the first day-Muhūrta after sunrise is *Rudra*, and the
/// well-known *Brahma Muhūrta* is the pre-dawn one — in a sunrise-anchored day it
/// falls at the very end (index 29), just before the next sunrise. The readout
/// and the dial's outer ring show the current name (idea doc §5).
///
/// This is a pure constant table with no logic, so it lives in `core/constants`
/// rather than a service.
abstract final class MuhurtaNames {
  MuhurtaNames._();

  /// The 30 day-Muhūrta names in order from sunrise (index 0) to the last one
  /// before the next sunrise (index 29).
  static const List<String> names = <String>[
    'Rudra',
    'Āhi',
    'Mitra',
    'Pitṛ',
    'Vasu',
    'Vārāha',
    'Viśvedevā',
    'Vidhi',
    'Sutamukhī',
    'Puruhūta',
    'Vāhinī',
    'Naktanakarā',
    'Varuṇa',
    'Aryaman',
    'Bhaga',
    'Girīśa',
    'Ajapāda',
    'Ahir Budhnya',
    'Puṣya',
    'Aśvinī',
    'Yama',
    'Agni',
    'Vidhātṛ',
    'Kaṇḍa',
    'Aditi',
    'Jīva/Amṛta',
    'Viṣṇu',
    'Dyumadgadyuti',
    'Brahma',
    'Samudram',
  ];

  /// The Muhūrta name for [index], clamped to the valid range so a bad index can
  /// never crash the readout (CLAUDE.md hard rule 4).
  static String at(int index) {
    if (names.isEmpty) return '';
    final i = index.clamp(0, names.length - 1);
    return names[i];
  }
}
