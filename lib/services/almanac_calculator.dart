import 'package:sanathana_dharma_clock/models/almanac_year.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';
import 'package:sanathana_dharma_clock/services/solar_calculator.dart';

/// The yearly almanac math: the six sun events of a year and the per-day
/// sunrise/sunset table for one place (plan 20260723_181354).
///
/// Pure service — no `BuildContext`, no plugins, no prefs, no UI strings
/// (architecture §7). Everything is computed in UTC; local conversion is the
/// caller's job, done only for display. All the underlying math already lives
/// in [SolarCalculator] and [LunarCalculator]; this class only scans and
/// bisects, so the app stays fully offline with no new packages.
class AlmanacCalculator {
  final SolarCalculator _solar;
  final LunarCalculator _lunar;

  const AlmanacCalculator(this._solar, this._lunar);

  /// The full almanac of [year] at ([latitudeDeg], [longitudeDeg]):
  /// the six events in date order, and one row per calendar day.
  ///
  /// Polar dates keep `null` sunrise/sunset — the table shows the gap instead
  /// of inventing an event (CLAUDE.md hard rule 4).
  AlmanacYear almanacFor({
    required int year,
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    final events = _yearEvents(year)
      ..sort((a, b) => a.instantUtc.compareTo(b.instantUtc));

    final days = <AlmanacDay>[];
    var date = DateTime.utc(year, 1, 1);
    while (date.year == year) {
      days.add(
        AlmanacDay(
          date: date,
          sunriseUtc: _solar.sunriseUtc(date, latitudeDeg, longitudeDeg),
          sunsetUtc: _solar.sunsetUtc(date, latitudeDeg, longitudeDeg),
        ),
      );
      date = date.add(const Duration(days: 1));
    }

    return AlmanacYear(year: year, events: events, days: days);
  }

  /// The six sun events that fall inside calendar [year] (UTC).
  ///
  /// Tropical crossings give the equinoxes/solstices; sidereal crossings give
  /// the two ayana starts (Makara Saṅkrānti at 270°, Karka Saṅkrānti at 90°).
  List<AlmanacEvent> _yearEvents(int year) {
    final events = <AlmanacEvent>[];

    void add(
      AlmanacEventKind kind,
      double targetDeg, {
      required bool sidereal,
    }) {
      final instant = _findCrossing(year, targetDeg, sidereal: sidereal);
      if (instant != null) {
        events.add(AlmanacEvent(kind: kind, instantUtc: instant));
      }
    }

    add(AlmanacEventKind.marchEquinox, 0.0, sidereal: false);
    add(AlmanacEventKind.juneSolstice, 90.0, sidereal: false);
    add(AlmanacEventKind.septemberEquinox, 180.0, sidereal: false);
    add(AlmanacEventKind.decemberSolstice, 270.0, sidereal: false);
    add(AlmanacEventKind.uttarayanaStart, 270.0, sidereal: true);
    add(AlmanacEventKind.dakshinayanaStart, 90.0, sidereal: true);

    return events;
  }

  /// The UTC instant inside [year] when the Sun's longitude crosses
  /// [targetDeg] (tropical, or sidereal when [sidereal]).
  ///
  /// The Sun moves ~1°/day, so each target is crossed once per year. A daily
  /// scan finds the bracketing day (signed distance going negative → positive
  /// near zero — the antipode wrap flips the other way), then bisection
  /// narrows the bracket to under a minute. Returns `null` only if no bracket
  /// is found, which does not happen for these six targets.
  DateTime? _findCrossing(
    int year,
    double targetDeg, {
    required bool sidereal,
  }) {
    double distance(DateTime t) {
      final longitude = sidereal
          ? _lunar.sunSiderealLongitudeDeg(t)
          : _lunar.sunLongitudeDeg(t);
      // Signed distance to the target, in (-180, 180].
      return (longitude - targetDeg + 540.0) % 360.0 - 180.0;
    }

    var lo = DateTime.utc(year, 1, 1);
    var dLo = distance(lo);
    final end = DateTime.utc(year + 1, 1, 1);

    while (lo.isBefore(end)) {
      final hi = lo.add(const Duration(days: 1));
      final dHi = distance(hi);
      // The true crossing: distance rises through zero. The ±180° wrap on the
      // far side of the circle jumps downward instead, so it never matches.
      if (dLo < 0 && dHi >= 0 && (dHi - dLo) < 90.0) {
        return _bisect(lo, hi, distance);
      }
      lo = hi;
      dLo = dHi;
    }
    return null;
  }

  /// Bisects [lo, hi] (distance negative at [lo], non-negative at [hi]) down
  /// to under a minute and returns the midpoint.
  DateTime _bisect(DateTime lo, DateTime hi, double Function(DateTime) f) {
    while (hi.difference(lo) > const Duration(minutes: 1)) {
      final mid = lo.add(hi.difference(lo) ~/ 2);
      if (f(mid) < 0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo.add(hi.difference(lo) ~/ 2);
  }
}
