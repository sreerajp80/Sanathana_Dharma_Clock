/// One limb of the day's Panchang: the value in force at sunrise and when it
/// ends (plan 20260723_075550).
///
/// Immutable, like every model in this app. [endUtc] is a **UTC** instant;
/// callers convert with `.toLocal()` for display. It is `null` when the limb
/// runs past the next sunrise (the screen words that case instead of showing a
/// time on the wrong day).
class PanchangLimb {
  /// 0-based index in the limb's own cycle (tithi 0–29, nakṣatra/yoga 0–26,
  /// karaṇa slot 0–59).
  final int index;

  /// Display name, from [PanchangNames].
  final String name;

  /// A short detail line (e.g. the tithi's pakṣa). Empty when none.
  final String detail;

  /// UTC end of this limb, or `null` when it ends after the next sunrise.
  final DateTime? endUtc;

  const PanchangLimb({
    required this.index,
    required this.name,
    this.detail = '',
    this.endUtc,
  });
}

/// The day's place in the wider Hindu calendar, taken at the day's sunrise
/// (plan 20260723_175810 & 20260726_192500).
///
/// Immutable. Contains both North Indian lunar calendar data and Kerala
/// Kollavarsham solar calendar data for dual-style Panchang presentation.
class CalendarInfo {
  /// 0-based Amānta lunar month index (0 = Chaitra ... 11 = Phālguna).
  final int amantaMasaIndex;

  /// 0-based Pūrṇimānta lunar month index.
  final int purnimantaMasaIndex;

  /// 0-based Kerala solar month index (0 = Meḍam ... 11 = Mīnam).
  final int solarMasaIndex;

  /// Amānta lunar month name (e.g. 'Śrāvaṇa'), without the Adhika prefix.
  final String amantaMasa;

  /// Pūrṇimānta lunar month name, without the Adhika prefix.
  final String purnimantaMasa;

  /// Whether the (amānta) month is a leap month — no saṅkrānti inside it.
  final bool isAdhika;

  /// 'Śukla Pakṣa' or 'Kṛṣṇa Pakṣa'.
  final String paksha;

  /// Season name (e.g. 'Varṣā (monsoon)'), from the amānta month.
  final String rtu;

  /// 'Uttarāyaṇa' or 'Dakṣiṇāyana' (nirayana rule).
  final String ayana;

  /// Kollavarsham (Kerala solar calendar) year number (e.g. 1201).
  final int kollavarshamYear;

  /// Vikram Samvat year number (e.g. 2083).
  final int vikramSamvatYear;

  /// 0-based Ñāṟṟuvēla index (Sun's transit through Nakshatra, 0 = Aśvinī/Aswathi).
  final int njattuvelaIndex;

  /// Day of week (1 = Monday ... 7 = Sunday).
  final int weekday;

  const CalendarInfo({
    required this.amantaMasaIndex,
    required this.purnimantaMasaIndex,
    required this.solarMasaIndex,
    required this.amantaMasa,
    required this.purnimantaMasa,
    required this.isAdhika,
    required this.paksha,
    required this.rtu,
    required this.ayana,
    required this.kollavarshamYear,
    required this.vikramSamvatYear,
    required this.njattuvelaIndex,
    required this.weekday,
  });
}

/// The five limbs of one dharma day's Panchang, all taken **at the day's
/// sunrise** like a printed Panchang.
///
/// Immutable. [sunriseUtc] is the anchor sunrise the limbs were evaluated at.
/// Vāra has no end time of its own — it simply runs sunrise → next sunrise —
/// so it is a plain name.
class PanchangDay {
  final DateTime sunriseUtc;
  final String vara;
  final int weekday;
  final PanchangLimb tithi;
  final PanchangLimb nakshatra;
  final PanchangLimb yoga;
  final PanchangLimb karana;

  /// UTC moonrise within this dharma day, or `null` when the Moon does not
  /// rise between the two sunrises (happens about once a month, and on polar
  /// days when it never crosses the horizon).
  final DateTime? moonriseUtc;

  /// UTC moonset within this dharma day, or `null` when it does not occur —
  /// same reasons as [moonriseUtc].
  final DateTime? moonsetUtc;

  /// The day's māsa/pakṣa/ṛtu/ayana, or `null` when the new-moon search could
  /// not bracket a crossing (never invented — CLAUDE.md hard rule 4).
  final CalendarInfo? calendar;

  const PanchangDay({
    required this.sunriseUtc,
    required this.vara,
    required this.weekday,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    this.moonriseUtc,
    this.moonsetUtc,
    this.calendar,
  });
}
