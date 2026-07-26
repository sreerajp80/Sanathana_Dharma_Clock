import 'dart:math' as math;

import 'package:sanathana_dharma_clock/core/utils/date_utils.dart';

/// Pure lunar/solar longitude math for the Panchang (plan 20260723_075550).
///
/// Everything the five Panchang limbs need reduces to two angles at an
/// instant: the Moon's and the Sun's geocentric ecliptic longitude. Both are
/// computed here directly from truncated series in Meeus, *Astronomical
/// Algorithms* (2nd ed.) — ch. 47 for the Moon, ch. 25 for the Sun — so the
/// app stays fully offline (CLAUDE.md hard rule 1). The truncation keeps
/// roughly arc-minute accuracy, which moves a tithi end time by only a minute
/// or two.
///
/// Like [SolarCalculator] this service is pure values-in/values-out: no
/// `BuildContext`, no plugins, no prefs, all instants in UTC (architecture
/// §7). It carries its own copy of the few solar terms it shares with
/// `SolarCalculator` so the two services stay independent.
class LunarCalculator {
  const LunarCalculator();

  /// Degrees per nakṣatra / yoga arc: 13°20′.
  static const double arcDeg = 360.0 / 27.0;

  /// The Moon's apparent geocentric ecliptic longitude, in degrees [0, 360),
  /// at UTC [instant].
  ///
  /// Truncated Meeus ch. 47: the mean longitude L′ plus the ~30 largest
  /// periodic terms and the three additive terms, then the same nutation
  /// correction the Sun uses, so the Moon−Sun difference is consistent.
  double moonLongitudeDeg(DateTime instant) {
    final t = _julianCenturies(instant);

    // Mean elements (Meeus 47.1–47.5), degrees.
    final lp = _mod360(
      218.3164477 +
          481267.88123421 * t -
          0.0015786 * t * t +
          t * t * t / 538841.0 -
          t * t * t * t / 65194000.0,
    );
    final d = _mod360(
      297.8501921 +
          445267.1114034 * t -
          0.0018819 * t * t +
          t * t * t / 545868.0 -
          t * t * t * t / 113065000.0,
    );
    final m = _mod360(
      357.5291092 +
          35999.0502909 * t -
          0.0001536 * t * t +
          t * t * t / 24490000.0,
    );
    final mp = _mod360(
      134.9633964 +
          477198.8675055 * t +
          0.0087414 * t * t +
          t * t * t / 69699.0 -
          t * t * t * t / 14712000.0,
    );
    final f = _mod360(
      93.2720950 +
          483202.0175233 * t -
          0.0036539 * t * t -
          t * t * t / 3526000.0 +
          t * t * t * t / 863310000.0,
    );

    // Eccentricity damping for terms containing the Sun's anomaly M.
    final e = 1.0 - 0.002516 * t - 0.0000074 * t * t;

    // Periodic longitude terms: multiples of (D, M, M′, F) and the
    // coefficient in 1e-6 degrees (Meeus table 47.A, largest terms).
    var sumL = 0.0;
    for (final term in _longitudeTerms) {
      final argDeg = term[0] * d + term[1] * m + term[2] * mp + term[3] * f;
      var coeff = term[4];
      final mMult = term[1].abs();
      if (mMult == 1) coeff *= e;
      if (mMult == 2) coeff *= e * e;
      sumL += coeff * math.sin(_rad(argDeg));
    }

    // Additive terms: Venus (A1), Jupiter (A2), and the flattening term.
    final a1 = 119.75 + 131.849 * t;
    final a2 = 53.09 + 479264.290 * t;
    sumL +=
        3958.0 * math.sin(_rad(a1)) +
        1962.0 * math.sin(_rad(lp - f)) +
        318.0 * math.sin(_rad(a2));

    return _mod360(lp + sumL / 1e6 + _nutationLongDeg(t));
  }

  /// The Sun's apparent geocentric ecliptic longitude, in degrees [0, 360),
  /// at UTC [instant].
  ///
  /// Same expression the NOAA sunrise math uses (mean longitude + equation of
  /// centre − aberration + nutation), so it matches `SolarCalculator`'s view
  /// of the Sun.
  double sunLongitudeDeg(DateTime instant) {
    final t = _julianCenturies(instant);

    final geomMeanLong = _mod360(280.46646 + t * (36000.76983 + t * 0.0003032));
    final geomMeanAnom = 357.52911 + t * (35999.05029 - 0.0001537 * t);

    final mRad = _rad(geomMeanAnom);
    final sunEqCtr =
        math.sin(mRad) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        math.sin(2 * mRad) * (0.019993 - 0.000101 * t) +
        math.sin(3 * mRad) * 0.000289;

    // True longitude − 0.00569 (aberration) + nutation.
    return _mod360(geomMeanLong + sunEqCtr - 0.00569 + _nutationLongDeg(t));
  }

  /// The Moon's geocentric ecliptic **latitude**, in degrees (roughly ±5.3°),
  /// at UTC [instant].
  ///
  /// Truncated Meeus ch. 47 (table 47.B largest terms plus the additive
  /// terms). Only rise/set needs the latitude — the five Panchang limbs use
  /// longitudes alone — so the truncation (about arc-minute accuracy) moves a
  /// moonrise time by well under a minute.
  double moonLatitudeDeg(DateTime instant) {
    final t = _julianCenturies(instant);

    // Same mean elements as the longitude (Meeus 47.1–47.5), degrees.
    final lp = _mod360(
      218.3164477 +
          481267.88123421 * t -
          0.0015786 * t * t +
          t * t * t / 538841.0 -
          t * t * t * t / 65194000.0,
    );
    final d = _mod360(
      297.8501921 +
          445267.1114034 * t -
          0.0018819 * t * t +
          t * t * t / 545868.0 -
          t * t * t * t / 113065000.0,
    );
    final m = _mod360(
      357.5291092 +
          35999.0502909 * t -
          0.0001536 * t * t +
          t * t * t / 24490000.0,
    );
    final mp = _mod360(
      134.9633964 +
          477198.8675055 * t +
          0.0087414 * t * t +
          t * t * t / 69699.0 -
          t * t * t * t / 14712000.0,
    );
    final f = _mod360(
      93.2720950 +
          483202.0175233 * t -
          0.0036539 * t * t -
          t * t * t / 3526000.0 +
          t * t * t * t / 863310000.0,
    );

    final e = 1.0 - 0.002516 * t - 0.0000074 * t * t;

    var sumB = 0.0;
    for (final term in _latitudeTerms) {
      final argDeg = term[0] * d + term[1] * m + term[2] * mp + term[3] * f;
      var coeff = term[4];
      final mMult = term[1].abs();
      if (mMult == 1) coeff *= e;
      if (mMult == 2) coeff *= e * e;
      sumB += coeff * math.sin(_rad(argDeg));
    }

    // Additive latitude terms (Meeus p. 342): Venus, and flattening couplings.
    final a1 = 119.75 + 131.849 * t;
    final a3 = 313.45 + 481266.484 * t;
    sumB +=
        -2235.0 * math.sin(_rad(lp)) +
        382.0 * math.sin(_rad(a3)) +
        175.0 * math.sin(_rad(a1 - f)) +
        175.0 * math.sin(_rad(a1 + f)) +
        127.0 * math.sin(_rad(lp - mp)) -
        115.0 * math.sin(_rad(lp + mp));

    return sumB / 1e6;
  }

  /// The Moon's apparent equatorial place at UTC [instant]: right ascension
  /// and declination, both in degrees (RA in [0, 360)).
  ///
  /// Standard ecliptic → equatorial rotation through the mean obliquity.
  /// This is what rise/set needs: where the Moon stands in the *sky*, not
  /// just along the ecliptic.
  ({double raDeg, double decDeg}) moonEquatorial(DateTime instant) {
    final lambda = _rad(moonLongitudeDeg(instant));
    final beta = _rad(moonLatitudeDeg(instant));
    final eps = _rad(_meanObliquityDeg(_julianCenturies(instant)));

    final sinDec =
        math.sin(beta) * math.cos(eps) +
        math.cos(beta) * math.sin(eps) * math.sin(lambda);
    final ra = math.atan2(
      math.sin(lambda) * math.cos(eps) - math.tan(beta) * math.sin(eps),
      math.cos(lambda),
    );

    return (
      raDeg: _mod360(ra * 180.0 / math.pi),
      decDeg: math.asin(sinDec) * 180.0 / math.pi,
    );
  }

  /// Mean obliquity of the ecliptic ε₀, degrees (Meeus 22.2, truncated).
  static double _meanObliquityDeg(double t) =>
      23.4392911 - 0.0130042 * t - 1.64e-7 * t * t;

  /// The Lahiri (Chitrapakṣa) ayanāṁśa in degrees at UTC [instant]: the
  /// offset subtracted from a tropical longitude to get the sidereal
  /// (nirayana) one.
  ///
  /// Standard linear approximation: 23.85° at J2000.0, growing by the general
  /// precession rate ≈ 50.29″ per year (0.013969°/yr). Good to well under a
  /// nakṣatra minute over the app's useful decades.
  double ayanamsaDeg(DateTime instant) {
    final t = _julianCenturies(instant);
    return 23.85 + 1.3969 * t; // 0.013969°/yr × 100 yr per century.
  }

  /// The Moon's *sidereal* longitude, degrees [0, 360), at UTC [instant].
  double moonSiderealLongitudeDeg(DateTime instant) =>
      _mod360(moonLongitudeDeg(instant) - ayanamsaDeg(instant));

  /// The Sun's *sidereal* longitude, degrees [0, 360), at UTC [instant].
  double sunSiderealLongitudeDeg(DateTime instant) =>
      _mod360(sunLongitudeDeg(instant) - ayanamsaDeg(instant));

  /// Moon − Sun elongation in degrees [0, 360) at UTC [instant]. One tithi is
  /// 12° of this angle; one karaṇa is 6°. Ayanāṁśa cancels in the difference,
  /// so tropical longitudes are used directly.
  double elongationDeg(DateTime instant) =>
      _mod360(moonLongitudeDeg(instant) - sunLongitudeDeg(instant));

  /// Moon + Sun sidereal sum in degrees [0, 360) at UTC [instant]. One yoga
  /// is 13°20′ of this sum.
  double yogaSumDeg(DateTime instant) => _mod360(
    moonSiderealLongitudeDeg(instant) + sunSiderealLongitudeDeg(instant),
  );

  /// Nutation in longitude Δψ, degrees — the same single-term expression the
  /// NOAA formula folds into the Sun's apparent longitude. Applied to both
  /// bodies so it cancels in the elongation.
  double _nutationLongDeg(double t) =>
      -0.00478 * math.sin(_rad(125.04 - 1934.136 * t));

  /// Julian centuries from J2000.0 at UTC [instant], including time of day.
  ///
  /// [DateUtils.julianDay] returns the JD at that date's **noon**; subtracting
  /// 0.5 gives midnight, then the day fraction is added back.
  double _julianCenturies(DateTime instant) {
    final utc = instant.toUtc();
    final midnightJd = DateUtils.julianDay(utc) - 0.5;
    final micros = utc.difference(DateUtils.startOfDayUtc(utc)).inMicroseconds;
    final jd = midnightJd + micros / 86400e6;
    return (jd - 2451545.0) / 36525.0;
  }

  /// Meeus table 47.A (largest terms): D, M, M′, F multipliers and the sine
  /// coefficient in 1e-6 degrees.
  static const List<List<double>> _longitudeTerms = <List<double>>[
    [0, 0, 1, 0, 6288774],
    [2, 0, -1, 0, 1274027],
    [2, 0, 0, 0, 658314],
    [0, 0, 2, 0, 213618],
    [0, 1, 0, 0, -185116],
    [0, 0, 0, 2, -114332],
    [2, 0, -2, 0, 58793],
    [2, -1, -1, 0, 57066],
    [2, 0, 1, 0, 53322],
    [2, -1, 0, 0, 45758],
    [0, 1, -1, 0, -40923],
    [1, 0, 0, 0, -34720],
    [0, 1, 1, 0, -30383],
    [2, 0, 0, -2, 15327],
    [0, 0, 1, 2, -12528],
    [0, 0, 1, -2, 10980],
    [4, 0, -1, 0, 10675],
    [0, 0, 3, 0, 10034],
    [4, 0, -2, 0, 8548],
    [2, 1, -1, 0, -7888],
    [2, 1, 0, 0, -6766],
    [1, 0, -1, 0, -5163],
    [1, 1, 0, 0, 4987],
    [2, -1, 1, 0, 4036],
    [2, 0, 2, 0, 3994],
    [4, 0, 0, 0, 3861],
    [2, 0, -3, 0, 3665],
    [0, 1, -2, 0, -2689],
    [2, 0, -1, 2, -2602],
    [2, -1, -2, 0, 2390],
    [1, 0, 1, 0, -2348],
    [2, -2, 0, 0, 2236],
  ];

  /// Meeus table 47.B (largest terms): D, M, M′, F multipliers and the sine
  /// coefficient in 1e-6 degrees, for the Moon's ecliptic latitude.
  static const List<List<double>> _latitudeTerms = <List<double>>[
    [0, 0, 0, 1, 5128122],
    [0, 0, 1, 1, 280602],
    [0, 0, 1, -1, 277693],
    [2, 0, 0, -1, 173237],
    [2, 0, -1, 1, 55413],
    [2, 0, -1, -1, 46271],
    [2, 0, 0, 1, 32573],
    [0, 0, 2, 1, 17198],
    [2, 0, 1, -1, 9266],
    [0, 0, 2, -1, 8822],
    [2, -1, 0, -1, 8216],
    [2, 0, -2, -1, 4324],
    [2, 0, 1, 1, 4200],
    [2, 1, 0, -1, -3359],
    [2, -1, -1, 1, 2463],
    [2, -1, 0, 1, 2211],
    [2, -1, -1, -1, 2065],
    [0, 1, -1, -1, -1870],
    [4, 0, -1, -1, 1828],
    [0, 1, 0, 1, -1794],
    [0, 0, 0, 3, -1749],
    [0, 1, -1, 1, -1565],
    [1, 0, 0, 1, -1491],
    [0, 1, 1, 1, -1475],
    [0, 1, 1, -1, -1410],
    [0, 1, 0, -1, -1344],
    [1, 0, 0, -1, -1335],
    [0, 0, 3, 1, 1107],
    [4, 0, 0, -1, 1021],
    [4, 0, -1, 1, 833],
  ];

  static double _rad(double degrees) => degrees * math.pi / 180.0;

  static double _mod360(double degrees) {
    final r = degrees % 360.0;
    return r < 0 ? r + 360.0 : r;
  }
}
