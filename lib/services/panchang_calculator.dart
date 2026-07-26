import 'package:sanathana_dharma_clock/core/constants/panchang_names.dart';
import 'package:sanathana_dharma_clock/models/panchang_day.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';
import 'package:sanathana_dharma_clock/services/moon_rise_set_calculator.dart';

/// Turns one dharma day (sunrise → next sunrise) into its Panchang
/// (plan 20260723_075550 & 20260726_192500).
///
/// Each limb is the one in force **at the day's sunrise**, like a printed
/// Panchang, plus the instant it ends:
///
/// - tithi   = 12° steps of the Moon−Sun elongation,
/// - karaṇa  = 6° steps of the same elongation,
/// - nakṣatra = 13°20′ steps of the Moon's sidereal longitude,
/// - yoga    = 13°20′ steps of the Moon+Sun sidereal sum,
/// - vāra    = the weekday name (runs the whole sunrise → sunrise day).
///
/// End times are found by bisection: each of the three driving angles grows
/// monotonically (the Moon outruns the Sun), gaining at most ~16° over one
/// day, so the crossing inside the day is unique and bisection cannot miss
/// it. A limb ending after the next sunrise gets a `null` end instead of a
/// time on the wrong day.
///
/// Pure values-in/values-out, like the other services: no `BuildContext`, no
/// plugins, no prefs, all instants UTC (architecture §7).
class PanchangCalculator {
  final LunarCalculator _lunar;
  final MoonRiseSetCalculator _moonRiseSet;

  const PanchangCalculator(this._lunar, this._moonRiseSet);

  /// Degrees of elongation per tithi and per karaṇa.
  static const double _tithiStepDeg = 12.0;
  static const double _karanaStepDeg = 6.0;

  /// Bisection stops when the bracket is this small (1 second — far finer
  /// than the math's own accuracy).
  static const Duration _bisectPrecision = Duration(seconds: 1);

  /// The Panchang of the day running [sunrise] → [nextSunrise] (both UTC),
  /// whose local weekday at sunrise is [weekday] (`DateTime.weekday`), as
  /// seen from [latitudeDeg] / [longitudeDeg] (east positive) — the place
  /// only matters for the moonrise/moonset times.
  ///
  /// Returns `null` instead of inventing values when the span is not
  /// positive (bad input or a polar edge), so a caller can never show a fake
  /// Panchang (CLAUDE.md hard rule 4).
  PanchangDay? panchangFor({
    required DateTime sunrise,
    required DateTime nextSunrise,
    required int weekday,
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    final start = sunrise.toUtc();
    final end = nextSunrise.toUtc();
    if (!end.isAfter(start)) return null;

    final tithi = _limbAt(
      start,
      end,
      stepDeg: _tithiStepDeg,
      angleAt: _lunar.elongationDeg,
      nameOf: PanchangNames.tithi,
      detailOf: PanchangNames.paksha,
    );
    final karana = _limbAt(
      start,
      end,
      stepDeg: _karanaStepDeg,
      angleAt: _lunar.elongationDeg,
      nameOf: PanchangNames.karana,
    );
    final nakshatra = _limbAt(
      start,
      end,
      stepDeg: LunarCalculator.arcDeg,
      angleAt: _lunar.moonSiderealLongitudeDeg,
      nameOf: (i) => PanchangNames.nakshatras[i % 27],
    );
    final yoga = _limbAt(
      start,
      end,
      stepDeg: LunarCalculator.arcDeg,
      angleAt: _lunar.yogaSumDeg,
      nameOf: (i) => PanchangNames.yogas[i % 27],
    );

    final moon = _moonRiseSet.riseAndSet(
      start: start,
      end: end,
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
    );

    return PanchangDay(
      sunriseUtc: start,
      vara: PanchangNames.vara(weekday),
      weekday: weekday,
      tithi: tithi,
      nakshatra: nakshatra,
      yoga: yoga,
      karana: karana,
      moonriseUtc: moon.moonriseUtc,
      moonsetUtc: moon.moonsetUtc,
      calendar: _calendarFor(start, tithi.index, weekday),
    );
  }

  /// Days walked when searching for a bounding new moon — comfortably above
  /// one synodic month (~29.5 days).
  static const int _newMoonSearchDays = 35;

  /// The day's māsa/pakṣa/ṛtu/ayana at [sunrise] (plan 20260723_175810 & 20260726_192500), or
  /// `null` when a bounding new moon cannot be found (hard rule 4 — never
  /// invent a value; the screen hides the card's māsa lines instead).
  CalendarInfo? _calendarFor(DateTime sunrise, int tithiIndex, int weekday) {
    final monthStart = _newMoonBefore(sunrise);
    if (monthStart == null) return null;
    final monthEnd = _newMoonAfter(monthStart);
    if (monthEnd == null) return null;

    final startRasi = _sunRasiAt(monthStart);
    final amantaIndex = (startRasi + 1) % 12;
    final purnimantaIndex = (tithiIndex % 30) >= 15
        ? (amantaIndex + 1) % 12
        : amantaIndex;

    // Nirayana ayana: Uttarāyaṇa from Makara (270°) through Mithuna (< 90°).
    final sunSidereal = _lunar.sunSiderealLongitudeDeg(sunrise);
    final ayana = (sunSidereal >= 270.0 || sunSidereal < 90.0)
        ? PanchangNames.uttarayana
        : PanchangNames.dakshinayana;

    // Solar Rasi index (0 = Medam ... 11 = Meenam)
    final solarMasaIndex = (sunSidereal / 30.0).floor() % 12;

    // Njattuvela index (Sun's Nakshatra transit, 0 = Aswathi ... 26 = Revathi)
    final njattuvelaIndex = (sunSidereal / (360.0 / 27.0)).floor() % 27;

    // Kollavarsham year: Chingam (index 4) starts Kollavarsham year.
    final localSunrise = sunrise.toLocal();
    final kollavarshamYear = solarMasaIndex >= 4
        ? localSunrise.year - 824
        : localSunrise.year - 825;

    // Vikram Samvat year: Starts on Chaitra Shukla Pratipada.
    final isAfterChaitraShukla1 = amantaIndex == 0 && (tithiIndex % 30) < 15;
    final vikramSamvatYear = isAfterChaitraShukla1 || amantaIndex > 0
        ? localSunrise.year + 57
        : localSunrise.year + 56;

    return CalendarInfo(
      amantaMasaIndex: amantaIndex,
      purnimantaMasaIndex: purnimantaIndex,
      solarMasaIndex: solarMasaIndex,
      amantaMasa: PanchangNames.masa(amantaIndex),
      purnimantaMasa: PanchangNames.masa(purnimantaIndex),
      isAdhika: startRasi == _sunRasiAt(monthEnd),
      paksha: PanchangNames.paksha(tithiIndex),
      rtu: PanchangNames.rtuOfMasa(amantaIndex),
      ayana: ayana,
      kollavarshamYear: kollavarshamYear,
      vikramSamvatYear: vikramSamvatYear,
      njattuvelaIndex: njattuvelaIndex,
      weekday: weekday,
    );
  }

  /// The Sun's sidereal rāśi (30° sign, 0 = Meṣa) at UTC [instant].
  int _sunRasiAt(DateTime instant) =>
      (_lunar.sunSiderealLongitudeDeg(instant) / 30.0).floor() % 12;

  /// The most recent new moon at or before [at], or `null` when none is found
  /// within [_newMoonSearchDays] (cannot happen for sane dates).
  DateTime? _newMoonBefore(DateTime at) {
    var later = at;
    var laterElong = _lunar.elongationDeg(later);
    for (var k = 1; k <= _newMoonSearchDays; k++) {
      final earlier = at.subtract(Duration(days: k));
      final elong = _lunar.elongationDeg(earlier);
      if (elong > laterElong) return _bisectNewMoon(earlier, later);
      later = earlier;
      laterElong = elong;
    }
    return null;
  }

  /// The first new moon after [at], or `null` when none is found within
  /// [_newMoonSearchDays].
  DateTime? _newMoonAfter(DateTime at) {
    var earlier = at;
    var earlierElong = _lunar.elongationDeg(earlier);
    for (var k = 1; k <= _newMoonSearchDays; k++) {
      final later = at.add(Duration(days: k));
      final elong = _lunar.elongationDeg(later);
      if (elong < earlierElong) return _bisectNewMoon(earlier, later);
      earlier = later;
      earlierElong = elong;
    }
    return null;
  }

  DateTime _bisectNewMoon(DateTime lo, DateTime hi) {
    while (hi.difference(lo) > _bisectPrecision) {
      final mid = lo.add(
        Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
      );
      if (_lunar.elongationDeg(mid) < 180.0) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return hi;
  }

  PanchangLimb _limbAt(
    DateTime start,
    DateTime end, {
    required double stepDeg,
    required double Function(DateTime) angleAt,
    required String Function(int) nameOf,
    String Function(int)? detailOf,
  }) {
    final startAngle = angleAt(start);
    final index = (startAngle / stepDeg).floor();

    final deficit = (index + 1) * stepDeg - startAngle;

    return PanchangLimb(
      index: index,
      name: nameOf(index),
      detail: detailOf?.call(index) ?? '',
      endUtc: _crossingTime(start, end, angleAt, deficit),
    );
  }

  DateTime? _crossingTime(
    DateTime start,
    DateTime end,
    double Function(DateTime) angleAt,
    double deficit,
  ) {
    final startAngle = angleAt(start);
    double advanceAt(DateTime t) => _mod360(angleAt(t) - startAngle);

    if (advanceAt(end) < deficit) return null;

    var lo = start;
    var hi = end;
    while (hi.difference(lo) > _bisectPrecision) {
      final mid = lo.add(
        Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
      );
      if (advanceAt(mid) < deficit) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return hi;
  }

  static double _mod360(double degrees) {
    final r = degrees % 360.0;
    return r < 0 ? r + 360.0 : r;
  }
}
