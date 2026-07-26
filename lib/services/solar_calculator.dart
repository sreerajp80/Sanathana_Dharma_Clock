import 'dart:math' as math;

import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/core/utils/date_utils.dart';

/// The resolved dharma day: which sunrise anchors "now" and how long the day is.
///
/// Immutable. [sunrise] is a **UTC** instant; callers convert with `.toLocal()`
/// for display. [span] is the sunrise-to-next-sunrise length (≈ 24 h, elastic).
/// [isPolar] is `true` when a real sunrise could not be found and the fixed
/// 86,400 s fallback was used (idea doc §6).
class SolarDay {
  final DateTime sunrise;
  final Duration span;
  final bool isPolar;

  const SolarDay({
    required this.sunrise,
    required this.span,
    required this.isPolar,
  });
}

/// Pure solar math: the sunrise for a date at a place, and the resolution of the
/// dharma day (anchor sunrise + span) with the safe fallbacks.
///
/// This service knows nothing about `BuildContext`, routes, UI strings, plugins,
/// or `shared_preferences` (architecture §7). Every calculation is in UTC; local
/// conversion is the caller's job, done only for display (idea doc §6).
///
/// The sunrise uses the standard NOAA solar-position algorithm, written directly
/// so the app stays fully offline (architecture §14). Latitude is degrees north
/// (+), longitude is degrees east (+).
class SolarCalculator {
  const SolarCalculator();

  /// Standard sunrise refraction/solar-radius zenith angle, in degrees.
  static const double _sunriseZenithDeg = 90.833;

  /// The UTC instant of sunrise on [dateUtc]'s calendar date at
  /// ([latitude], [longitude]).
  ///
  /// Returns `null` when the sun does not rise/set that date at that latitude
  /// (polar day or polar night) — the caller uses this to trigger the fixed-span
  /// fallback. All math is in UTC.
  DateTime? sunriseUtc(DateTime dateUtc, double latitude, double longitude) =>
      _solarEventUtc(dateUtc, latitude, longitude, isSunrise: true);

  /// The UTC instant of sunset on [dateUtc]'s calendar date at
  /// ([latitude], [longitude]).
  ///
  /// Same NOAA math as [sunriseUtc]; the sun crosses the same hour angle on the
  /// evening side. Returns `null` on a polar date. Used by the Muhūrta/Kāla
  /// windows, which split the sunrise→sunset daytime.
  DateTime? sunsetUtc(DateTime dateUtc, double latitude, double longitude) =>
      _solarEventUtc(dateUtc, latitude, longitude, isSunrise: false);

  /// The shared NOAA computation behind [sunriseUtc] and [sunsetUtc]. The two
  /// events differ only in the sign of the hour angle: minutes from UTC noon are
  /// `∓4·haDeg` (sunrise −, sunset +), after the longitude and equation-of-time
  /// corrections.
  DateTime? _solarEventUtc(
    DateTime dateUtc,
    double latitude,
    double longitude, {
    required bool isSunrise,
  }) {
    final jd = DateUtils.julianDay(dateUtc);
    final t = (jd - 2451545.0) / 36525.0; // Julian century from J2000.0

    final geomMeanLong = _mod360(280.46646 + t * (36000.76983 + t * 0.0003032));
    final geomMeanAnom = 357.52911 + t * (35999.05029 - 0.0001537 * t);
    final eccent = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);

    final mRad = _rad(geomMeanAnom);
    final sunEqCtr =
        math.sin(mRad) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        math.sin(2 * mRad) * (0.019993 - 0.000101 * t) +
        math.sin(3 * mRad) * 0.000289;

    final sunTrueLong = geomMeanLong + sunEqCtr;
    final sunAppLong =
        sunTrueLong - 0.00569 - 0.00478 * math.sin(_rad(125.04 - 1934.136 * t));

    final meanObliq =
        23.0 +
        (26.0 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60.0) /
            60.0;
    final obliqCorr =
        meanObliq + 0.00256 * math.cos(_rad(125.04 - 1934.136 * t));

    final declinRad = math.asin(
      math.sin(_rad(obliqCorr)) * math.sin(_rad(sunAppLong)),
    );

    final varY = math.tan(_rad(obliqCorr / 2)) * math.tan(_rad(obliqCorr / 2));
    final glRad = _rad(geomMeanLong);
    final eqOfTime =
        4.0 *
        _deg(
          varY * math.sin(2 * glRad) -
              2 * eccent * math.sin(mRad) +
              4 * eccent * varY * math.sin(mRad) * math.cos(2 * glRad) -
              0.5 * varY * varY * math.sin(4 * glRad) -
              1.25 * eccent * eccent * math.sin(2 * mRad),
        );

    final latRad = _rad(latitude);
    final cosHa =
        math.cos(_rad(_sunriseZenithDeg)) /
            (math.cos(latRad) * math.cos(declinRad)) -
        math.tan(latRad) * math.tan(declinRad);

    // Sun never reaches the sunrise zenith on this date at this latitude.
    if (cosHa < -1.0 || cosHa > 1.0) return null;

    final haDeg = _deg(math.acos(cosHa));

    // Minutes from UTC midnight (longitude east positive). Sunrise is the hour
    // angle before local solar noon, sunset the same angle after it.
    final minutesUtc = isSunrise
        ? 720.0 - 4.0 * (longitude + haDeg) - eqOfTime
        : 720.0 - 4.0 * (longitude - haDeg) - eqOfTime;

    final microseconds = (minutesUtc * 60.0 * 1000000.0).round();
    return DateUtils.startOfDayUtc(
      dateUtc,
    ).add(Duration(microseconds: microseconds));
  }

  /// Resolves the dharma day for [now] at ([latitude], [longitude]): the anchor
  /// sunrise and the span to the next sunrise, with the safe fallbacks.
  ///
  /// - If [now] is before today's sunrise, anchors to **yesterday's** sunrise
  ///   (idea doc §4: "if s < 0, use yesterday's sunrise").
  /// - Otherwise anchors to today's sunrise, span = tomorrow − today.
  /// - If any needed sunrise is missing (polar) or the span is not positive,
  ///   falls back to a midnight anchor and a fixed
  ///   [AppConstants.secondsPerDay] span, so the clock never crashes on a
  ///   missing anchor (CLAUDE.md hard rule 4).
  SolarDay resolveDay(DateTime now, double latitude, double longitude) {
    final nowUtc = now.toUtc();
    final today = DateUtils.startOfDayUtc(nowUtc);
    final yesterday = DateUtils.addDays(today, -1);
    final tomorrow = DateUtils.addDays(today, 1);

    final srYesterday = sunriseUtc(yesterday, latitude, longitude);
    final srToday = sunriseUtc(today, latitude, longitude);
    final srTomorrow = sunriseUtc(tomorrow, latitude, longitude);

    DateTime? anchor;
    DateTime? end;
    if (srToday != null && nowUtc.isBefore(srToday)) {
      anchor = srYesterday;
      end = srToday;
    } else if (srToday != null) {
      anchor = srToday;
      end = srTomorrow;
    }

    if (anchor == null || end == null) return _polarFallback(nowUtc);

    final span = end.difference(anchor);
    if (span.inMicroseconds <= 0) return _polarFallback(nowUtc);

    return SolarDay(sunrise: anchor, span: span, isPolar: false);
  }

  SolarDay _polarFallback(DateTime nowUtc) => SolarDay(
    sunrise: DateUtils.startOfDayUtc(nowUtc),
    span: const Duration(seconds: AppConstants.secondsPerDay),
    isPolar: true,
  );

  static double _rad(double degrees) => degrees * math.pi / 180.0;

  static double _deg(double radians) => radians * 180.0 / math.pi;

  static double _mod360(double degrees) {
    final r = degrees % 360.0;
    return r < 0 ? r + 360.0 : r;
  }
}
