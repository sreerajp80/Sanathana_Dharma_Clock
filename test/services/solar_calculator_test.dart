import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/core/utils/date_utils.dart';
import 'package:sanathana_dharma_clock/services/solar_calculator.dart';

void main() {
  const solar = SolarCalculator();

  group('SolarCalculator.sunriseUtc — against reference values', () {
    test('London on the summer solstice ≈ 03:43 UTC (04:43 BST)', () {
      // London: 51.5074° N, 0.1278° W. Documented solstice sunrise 04:43 BST.
      final sunrise = solar.sunriseUtc(
        DateTime.utc(2026, 6, 21),
        51.5074,
        -0.1278,
      );

      expect(sunrise, isNotNull);
      final expected = DateTime.utc(2026, 6, 21, 3, 43);
      final diff = sunrise!.difference(expected).inSeconds.abs();
      expect(diff, lessThanOrEqualTo(180), reason: 'off by ${diff}s');
    });

    test('equator at prime meridian on the equinox rises near 06:00 UTC', () {
      // Declination ≈ 0 on the equinox, so sunrise sits close to local 06:00.
      final sunrise = solar.sunriseUtc(DateTime.utc(2026, 3, 20), 0.0, 0.0);

      expect(sunrise, isNotNull);
      expect(sunrise!.isAfter(DateTime.utc(2026, 3, 20, 5, 50)), isTrue);
      expect(sunrise.isBefore(DateTime.utc(2026, 3, 20, 6, 15)), isTrue);
    });
  });

  group('SolarCalculator.sunsetUtc — against reference values', () {
    test('London on the summer solstice ≈ 20:21 UTC (21:21 BST)', () {
      // London: 51.5074° N, 0.1278° W. Documented solstice sunset 21:21 BST.
      final sunset = solar.sunsetUtc(
        DateTime.utc(2026, 6, 21),
        51.5074,
        -0.1278,
      );

      expect(sunset, isNotNull);
      final expected = DateTime.utc(2026, 6, 21, 20, 21);
      final diff = sunset!.difference(expected).inSeconds.abs();
      expect(diff, lessThanOrEqualTo(180), reason: 'off by ${diff}s');
    });

    test('equator at prime meridian on the equinox sets near 18:00 UTC', () {
      final sunset = solar.sunsetUtc(DateTime.utc(2026, 3, 20), 0.0, 0.0);

      expect(sunset, isNotNull);
      expect(sunset!.isAfter(DateTime.utc(2026, 3, 20, 17, 50)), isTrue);
      expect(sunset.isBefore(DateTime.utc(2026, 3, 20, 18, 15)), isTrue);
    });

    test('sunset is after sunrise on the same date', () {
      final date = DateTime.utc(2026, 6, 21);
      final sunrise = solar.sunriseUtc(date, 51.5074, -0.1278)!;
      final sunset = solar.sunsetUtc(date, 51.5074, -0.1278)!;
      expect(sunset.isAfter(sunrise), isTrue);
    });
  });

  group('SolarCalculator.sunsetUtc — polar', () {
    test('high latitude on the summer solstice has no sunset (null)', () {
      final sunset = solar.sunsetUtc(DateTime.utc(2026, 6, 21), 80.0, 0.0);
      expect(sunset, isNull);
    });
  });

  group('SolarCalculator.sunriseUtc — polar', () {
    test('high latitude on the summer solstice has no sunrise (null)', () {
      final sunrise = solar.sunriseUtc(DateTime.utc(2026, 6, 21), 80.0, 0.0);
      expect(sunrise, isNull);
    });
  });

  group('SolarCalculator.resolveDay', () {
    test('polar day falls back to a fixed 86,400 s span at midnight', () {
      final now = DateTime.utc(2026, 6, 21, 12);
      final day = solar.resolveDay(now, 80.0, 0.0);

      expect(day.isPolar, isTrue);
      expect(day.span, const Duration(seconds: AppConstants.secondsPerDay));
      expect(day.sunrise, DateUtils.startOfDayUtc(now));
    });

    test('a normal day anchors to today and spans to tomorrow', () {
      final now = DateTime.utc(2026, 6, 21, 12); // well after sunrise
      final today = DateUtils.startOfDayUtc(now);
      final srToday = solar.sunriseUtc(today, 51.5074, -0.1278)!;
      final srTomorrow = solar.sunriseUtc(
        DateUtils.addDays(today, 1),
        51.5074,
        -0.1278,
      )!;

      final day = solar.resolveDay(now, 51.5074, -0.1278);

      expect(day.isPolar, isFalse);
      expect(day.sunrise, srToday);
      expect(day.span, srTomorrow.difference(srToday));
    });

    test('before today\'s sunrise, anchors to yesterday', () {
      final today = DateTime.utc(2026, 6, 21);
      final srToday = solar.sunriseUtc(today, 51.5074, -0.1278)!;
      final srYesterday = solar.sunriseUtc(
        DateUtils.addDays(today, -1),
        51.5074,
        -0.1278,
      )!;

      // One hour before today's sunrise (same UTC day here).
      final now = srToday.subtract(const Duration(hours: 1));
      final day = solar.resolveDay(now, 51.5074, -0.1278);

      expect(day.isPolar, isFalse);
      expect(day.sunrise, srYesterday);
      expect(day.span, srToday.difference(srYesterday));
      // The anchor must be at or before now, so seconds-since-sunrise ≥ 0.
      expect(now.isAfter(day.sunrise), isTrue);
    });
  });
}
