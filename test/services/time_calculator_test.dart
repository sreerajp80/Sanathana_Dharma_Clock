import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/services/time_calculator.dart';

void main() {
  const calc = TimeCalculator();

  // A fixed anchor used across the tests.
  final sunrise = DateTime.utc(2026, 7, 21, 0, 30);

  group('TimeCalculator.toDharmaTime — mapping', () {
    test('24 h span: one Ghaṭikā is 24 min, nesting is exact', () {
      const span = Duration(seconds: 86400); // Ghaṭikā = 1440 s = 24 min
      final now = sunrise.add(const Duration(seconds: 3600)); // 1 h in

      final t = calc.toDharmaTime(now: now, sunrise: sunrise, span: span);

      // 3600 s = 2 Ghaṭikā (2880 s) + 720 s → 30 Vināḍī (24 s each) + 0 Prāṇa.
      expect(t.ghatika, 2);
      expect(t.vinadi, 30);
      expect(t.prana, 0);
      expect(t.muhurta, 1); // 2 ~/ 2
      expect(t.span, span);
      expect(t.ghatikaLen, const Duration(seconds: 1440));
    });

    test('elastic span: units scale with the longer day', () {
      const span = Duration(seconds: 90000); // Ghaṭikā = 1500 s = 25 min
      final now = sunrise.add(const Duration(seconds: 2500));

      final t = calc.toDharmaTime(now: now, sunrise: sunrise, span: span);

      // 2500 s = 1 Ghaṭikā (1500 s) + 1000 s → 40 Vināḍī (25 s each) + 0 Prāṇa.
      expect(t.ghatika, 1);
      expect(t.vinadi, 40);
      expect(t.prana, 0);
      expect(t.muhurta, 0);
      expect(t.ghatikaLen, const Duration(seconds: 1500));
    });
  });

  group('TimeCalculator — reverse and reversibility', () {
    test('toCivilTime returns the start of the cell', () {
      const span = Duration(seconds: 86400);
      final civil = calc.toCivilTime(
        ghatika: 2,
        vinadi: 30,
        prana: 0,
        sunrise: sunrise,
        span: span,
      );
      expect(civil, sunrise.add(const Duration(seconds: 3600)));
    });

    test('reading → civil → reading round-trips (24 h span)', () {
      const span = Duration(seconds: 86400);
      final civil = calc.toCivilTime(
        ghatika: 37,
        vinadi: 15,
        prana: 4,
        sunrise: sunrise,
        span: span,
      );
      final t = calc.toDharmaTime(now: civil, sunrise: sunrise, span: span);

      expect(t.ghatika, 37);
      expect(t.vinadi, 15);
      expect(t.prana, 4);
    });

    test('reading → civil → reading round-trips (elastic span)', () {
      const span = Duration(seconds: 90000);
      final civil = calc.toCivilTime(
        ghatika: 12,
        vinadi: 59,
        prana: 5,
        sunrise: sunrise,
        span: span,
      );
      final t = calc.toDharmaTime(now: civil, sunrise: sunrise, span: span);

      expect(t.ghatika, 12);
      expect(t.vinadi, 59);
      expect(t.prana, 5);
    });
  });

  group('TimeCalculator.toDharmaTime — smooth hand fractions', () {
    const span = Duration(seconds: 86400); // Ghaṭikā 1440 s, Vināḍī 24 s.

    test('at sunrise both sub-fractions are 0', () {
      final t = calc.toDharmaTime(now: sunrise, sunrise: sunrise, span: span);
      expect(t.vinadiFraction, 0.0);
      expect(t.pranaFraction, 0.0);
    });

    test('half way through a Ghaṭikā gives vinadiFraction 0.5', () {
      // 3600 s = 2 Ghaṭikā (2880 s) + 720 s; 720 s is half of a 1440 s Ghaṭikā.
      final now = sunrise.add(const Duration(seconds: 3600));
      final t = calc.toDharmaTime(now: now, sunrise: sunrise, span: span);
      expect(t.vinadiFraction, closeTo(0.5, 1e-9));
      expect(t.pranaFraction, closeTo(0.0, 1e-9));
    });

    test('half way through a Vināḍī gives pranaFraction 0.5', () {
      // 12 s past the Vināḍī start is half of a 24 s Vināḍī.
      final now = sunrise.add(const Duration(seconds: 3612));
      final t = calc.toDharmaTime(now: now, sunrise: sunrise, span: span);
      expect(t.pranaFraction, closeTo(0.5, 1e-9));
    });
  });

  group('TimeCalculator — day boundary', () {
    const span = Duration(seconds: 86400);

    test('at sunrise the reading is 0:0:0 (M0) with fraction 0', () {
      final t = calc.toDharmaTime(now: sunrise, sunrise: sunrise, span: span);
      expect(t.ghatika, 0);
      expect(t.vinadi, 0);
      expect(t.prana, 0);
      expect(t.muhurta, 0);
      expect(t.fraction, 0.0);
    });

    test(
      'at the end of the day it saturates to 59:59:5 (M29), fraction < 1',
      () {
        final now = sunrise.add(span); // exactly the next sunrise
        final t = calc.toDharmaTime(now: now, sunrise: sunrise, span: span);
        expect(t.ghatika, 59);
        expect(t.vinadi, 59);
        expect(t.prana, 5);
        expect(t.muhurta, 29);
        expect(t.fraction, lessThan(1.0));
      },
    );

    test('before sunrise is clamped to the start of the day', () {
      final now = sunrise.subtract(const Duration(hours: 2));
      final t = calc.toDharmaTime(now: now, sunrise: sunrise, span: span);
      expect(t.ghatika, 0);
      expect(t.vinadi, 0);
      expect(t.prana, 0);
      expect(t.fraction, 0.0);
    });
  });
}
