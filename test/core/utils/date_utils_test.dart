import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/core/utils/date_utils.dart';

void main() {
  group('DateUtils.startOfDayUtc', () {
    test('strips the time of day and returns a UTC value', () {
      final instant = DateTime.utc(2026, 7, 21, 14, 37, 12, 500);
      final start = DateUtils.startOfDayUtc(instant);

      expect(start, DateTime.utc(2026, 7, 21));
      expect(start.isUtc, isTrue);
    });

    test('converts a local instant to its UTC date first', () {
      final local = DateTime(2026, 7, 21, 9, 0);
      final start = DateUtils.startOfDayUtc(local);

      expect(start.isUtc, isTrue);
      expect(start, DateUtils.startOfDayUtc(local.toUtc()));
    });
  });

  group('DateUtils.addDays', () {
    test('crosses a month boundary forward', () {
      final result = DateUtils.addDays(DateTime.utc(2026, 1, 31), 1);
      expect(result, DateTime.utc(2026, 2, 1));
    });

    test('crosses a month boundary backward', () {
      final result = DateUtils.addDays(DateTime.utc(2026, 3, 1), -1);
      expect(result, DateTime.utc(2026, 2, 28));
    });

    test('drops the time of day and stays UTC', () {
      final result = DateUtils.addDays(DateTime.utc(2026, 7, 21, 13, 5), 1);
      expect(result, DateTime.utc(2026, 7, 22));
      expect(result.isUtc, isTrue);
    });
  });

  group('DateUtils.julianDay', () {
    test('J2000.0 epoch: 2000-01-01 → JD 2451545.0', () {
      expect(DateUtils.julianDay(DateTime.utc(2000, 1, 1)), 2451545.0);
    });

    test('one day later is one Julian day later', () {
      final jd0 = DateUtils.julianDay(DateTime.utc(2000, 1, 1));
      final jd1 = DateUtils.julianDay(DateTime.utc(2000, 1, 2));
      expect(jd1 - jd0, 1.0);
    });
  });
}
