import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';

void main() {
  const lunar = LunarCalculator();

  group('LunarCalculator.moonLongitudeDeg — against Meeus example 47.a', () {
    test('1992 April 12.0 → apparent λ ≈ 133.167°', () {
      // Meeus, Astronomical Algorithms (2nd ed.), example 47.a:
      // geocentric λ = 133.162655°, apparent (with nutation) = 133.167265°.
      // Our value uses UT (not TT; ΔT ≈ 58 s moves the Moon ~0.009°) and a
      // truncated series, so allow a small tolerance.
      final lon = lunar.moonLongitudeDeg(DateTime.utc(1992, 4, 12));
      expect((lon - 133.167).abs(), lessThan(0.05), reason: 'λ = $lon');
    });
  });

  group('LunarCalculator.sunLongitudeDeg — against Meeus example 25.a', () {
    test('1992 October 13.0 → apparent λ ≈ 199.909°', () {
      // Meeus example 25.a: apparent λ☉ = 199.90895°.
      final lon = lunar.sunLongitudeDeg(DateTime.utc(1992, 10, 13));
      expect((lon - 199.909).abs(), lessThan(0.02), reason: 'λ = $lon');
    });
  });

  group('LunarCalculator.ayanamsaDeg', () {
    test('is ≈ 24.2° (Lahiri) in mid-2026', () {
      final a = lunar.ayanamsaDeg(DateTime.utc(2026, 7, 1));
      expect(a, greaterThan(24.1));
      expect(a, lessThan(24.3));
    });

    test('grows with time (precession)', () {
      final a2000 = lunar.ayanamsaDeg(DateTime.utc(2000, 1, 1));
      final a2026 = lunar.ayanamsaDeg(DateTime.utc(2026, 1, 1));
      expect(a2026, greaterThan(a2000));
    });
  });

  group('LunarCalculator.elongationDeg', () {
    test('is near 0°/360° at a solar eclipse (a new moon by definition)', () {
      // Total solar eclipse of 2026-08-12, greatest eclipse ≈ 17:46 UTC.
      // The Moon−Sun longitude difference must be very small there.
      final e = lunar.elongationDeg(DateTime.utc(2026, 8, 12, 17, 46));
      final distToZero = e > 180 ? 360 - e : e;
      expect(distToZero, lessThan(1.0), reason: 'elongation = $e');
    });

    test('advances ≈ 12.2°/day (one tithi per day on average)', () {
      final t0 = DateTime.utc(2026, 7, 1);
      final t1 = DateTime.utc(2026, 7, 2);
      var advance = lunar.elongationDeg(t1) - lunar.elongationDeg(t0);
      if (advance < 0) advance += 360;
      expect(advance, greaterThan(10.0));
      expect(advance, lessThan(15.0));
    });
  });
}
