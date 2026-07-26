import 'dart:math' as math;

import 'package:sanathana_dharma_clock/core/utils/date_utils.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';

/// Finds the moonrise and moonset inside one dharma day
/// (plan 20260723_162809).
///
/// Method: sample the Moon's altitude above the horizon at coarse steps
/// across the sunrise → next-sunrise window, spot where it crosses the
/// standard rise/set altitude, then bisect each crossing down to the second.
/// A crossing upward is a moonrise; downward is a moonset.
///
/// Either event can be absent on a given day — the Moon's own day is about
/// 24 h 50 min, so roughly once a month a rise (or a set) simply does not
/// happen between two sunrises. That case returns `null`, never an invented
/// time (CLAUDE.md hard rule 4). The same naturally covers polar latitudes
/// where the Moon stays up or down all day.
///
/// Pure values-in/values-out like the other services: no `BuildContext`, no
/// plugins, no prefs, all instants UTC (architecture §7).
class MoonRiseSetCalculator {
  final LunarCalculator _lunar;

  const MoonRiseSetCalculator(this._lunar);

  /// Standard altitude of the Moon's centre at rise/set, degrees.
  ///
  /// For the Sun this is −0.833° (refraction + half-diameter), but the Moon
  /// is close enough that its parallax pushes the value *above* the horizon:
  /// the conventional mean is +0.125° (Meeus ch. 15).
  static const double _riseSetAltitudeDeg = 0.125;

  /// Coarse scan step. The altitude changes by at most ~4°/step at this
  /// size, far smaller than the swing between horizon crossings, so no
  /// crossing can be skipped.
  static const Duration _scanStep = Duration(minutes: 10);

  /// Bisection stops when the bracket is this small.
  static const Duration _bisectPrecision = Duration(seconds: 1);

  /// The first moonrise and first moonset in ([start], [end]] (both UTC) as
  /// seen from [latitudeDeg] / [longitudeDeg] (east positive).
  ///
  /// Either field is `null` when that event does not occur in the window.
  ({DateTime? moonriseUtc, DateTime? moonsetUtc}) riseAndSet({
    required DateTime start,
    required DateTime end,
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    if (!endUtc.isAfter(startUtc)) {
      return (moonriseUtc: null, moonsetUtc: null);
    }

    double f(DateTime t) =>
        _moonAltitudeDeg(t, latitudeDeg, longitudeDeg) - _riseSetAltitudeDeg;

    DateTime? rise;
    DateTime? set;

    var lo = startUtc;
    var fLo = f(lo);
    while (lo.isBefore(endUtc) && (rise == null || set == null)) {
      var hi = lo.add(_scanStep);
      if (hi.isAfter(endUtc)) hi = endUtc;
      final fHi = f(hi);

      if (fLo <= 0 && fHi > 0 && rise == null) {
        rise = _bisect(lo, hi, f, rising: true);
      } else if (fLo >= 0 && fHi < 0 && set == null) {
        set = _bisect(lo, hi, f, rising: false);
      }

      lo = hi;
      fLo = fHi;
    }

    return (moonriseUtc: rise, moonsetUtc: set);
  }

  /// The instant in [lo] → [hi] where the sign of [f] flips — upward when
  /// [rising], downward otherwise.
  DateTime _bisect(
    DateTime lo,
    DateTime hi,
    double Function(DateTime) f, {
    required bool rising,
  }) {
    while (hi.difference(lo) > _bisectPrecision) {
      final mid = lo.add(
        Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
      );
      final below = rising ? f(mid) <= 0 : f(mid) >= 0;
      if (below) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return hi;
  }

  /// The Moon's geometric altitude above the horizon, degrees, at UTC
  /// [instant] from the given place.
  double _moonAltitudeDeg(DateTime instant, double latDeg, double lonDeg) {
    final eq = _lunar.moonEquatorial(instant);

    // Local hour angle = local sidereal time − right ascension.
    final lstDeg = _gmstDeg(instant) + lonDeg;
    final haRad = _rad(lstDeg - eq.raDeg);

    final latRad = _rad(latDeg);
    final decRad = _rad(eq.decDeg);
    final sinAlt =
        math.sin(latRad) * math.sin(decRad) +
        math.cos(latRad) * math.cos(decRad) * math.cos(haRad);
    return math.asin(sinAlt.clamp(-1.0, 1.0)) * 180.0 / math.pi;
  }

  /// Greenwich mean sidereal time in degrees at UTC [instant] (Meeus 12.4).
  double _gmstDeg(DateTime instant) {
    final utc = instant.toUtc();
    // JD including time of day ([DateUtils.julianDay] is that date's noon).
    final midnightJd = DateUtils.julianDay(utc) - 0.5;
    final micros = utc.difference(DateUtils.startOfDayUtc(utc)).inMicroseconds;
    final jd = midnightJd + micros / 86400e6;
    final t = (jd - 2451545.0) / 36525.0;

    final gmst =
        280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    return _mod360(gmst);
  }

  static double _rad(double degrees) => degrees * math.pi / 180.0;

  static double _mod360(double degrees) {
    final r = degrees % 360.0;
    return r < 0 ? r + 360.0 : r;
  }
}
