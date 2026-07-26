import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/models/almanac_year.dart';
import 'package:sanathana_dharma_clock/services/almanac_calculator.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';
import 'package:sanathana_dharma_clock/services/solar_calculator.dart';

void main() {
  const calculator = AlmanacCalculator(SolarCalculator(), LunarCalculator());

  // London — the same reference place the solar tests use.
  final almanac2026 = calculator.almanacFor(
    year: 2026,
    latitudeDeg: 51.5074,
    longitudeDeg: -0.1278,
  );

  AlmanacEvent eventOf(AlmanacEventKind kind) =>
      almanac2026.events.singleWhere((e) => e.kind == kind);

  group('AlmanacCalculator — 2026 sun events', () {
    // Reference instants (UTC) from standard astronomical tables. The app's
    // simplified sun longitude is good to a few minutes, so a generous
    // 2-hour window is asserted.
    void expectNear(AlmanacEventKind kind, DateTime expectedUtc) {
      final diff = eventOf(kind).instantUtc.difference(expectedUtc);
      expect(
        diff.abs(),
        lessThanOrEqualTo(const Duration(hours: 2)),
        reason: '$kind off by ${diff.inMinutes} min',
      );
    }

    test('March equinox ≈ 20 Mar 14:46 UTC', () {
      expectNear(
        AlmanacEventKind.marchEquinox,
        DateTime.utc(2026, 3, 20, 14, 46),
      );
    });

    test('June solstice ≈ 21 Jun 08:25 UTC', () {
      expectNear(
        AlmanacEventKind.juneSolstice,
        DateTime.utc(2026, 6, 21, 8, 25),
      );
    });

    test('September equinox ≈ 23 Sep 00:05 UTC', () {
      expectNear(
        AlmanacEventKind.septemberEquinox,
        DateTime.utc(2026, 9, 23, 0, 5),
      );
    });

    test('December solstice ≈ 21 Dec 20:50 UTC', () {
      expectNear(
        AlmanacEventKind.decemberSolstice,
        DateTime.utc(2026, 12, 21, 20, 50),
      );
    });

    test('Uttarāyaṇa starts in mid-January (Makara Saṅkrānti)', () {
      final instant = eventOf(AlmanacEventKind.uttarayanaStart).instantUtc;
      expect(instant.month, 1);
      expect(instant.day, inInclusiveRange(13, 16));
    });

    test('Dakṣiṇāyana starts in mid-July (Karka Saṅkrānti)', () {
      final instant = eventOf(AlmanacEventKind.dakshinayanaStart).instantUtc;
      expect(instant.month, 7);
      expect(instant.day, inInclusiveRange(15, 18));
    });

    test('all six events are present and sorted by date', () {
      expect(almanac2026.events, hasLength(6));
      for (var i = 1; i < almanac2026.events.length; i++) {
        expect(
          almanac2026.events[i].instantUtc.isAfter(
            almanac2026.events[i - 1].instantUtc,
          ),
          isTrue,
        );
      }
    });
  });

  group('AlmanacCalculator — day table', () {
    test('has one row per day of the year', () {
      expect(almanac2026.days, hasLength(365)); // 2026 is not a leap year.
      expect(almanac2026.days.first.date, DateTime.utc(2026, 1, 1));
      expect(almanac2026.days.last.date, DateTime.utc(2026, 12, 31));
    });

    test('21 Jun in London matches the solar reference values', () {
      final day = almanac2026.days.singleWhere(
        (d) => d.date.month == 6 && d.date.day == 21,
      );
      // Same references as solar_calculator_test.dart.
      expect(
        day.sunriseUtc!.difference(DateTime.utc(2026, 6, 21, 3, 43)).abs(),
        lessThanOrEqualTo(const Duration(minutes: 3)),
      );
      expect(
        day.sunsetUtc!.difference(DateTime.utc(2026, 6, 21, 20, 21)).abs(),
        lessThanOrEqualTo(const Duration(minutes: 3)),
      );
      expect(day.dayLength, isNotNull);
      expect(day.dayLength!.inHours, inInclusiveRange(16, 17));
    });

    test('a polar summer date has no sunrise/sunset and no day length', () {
      final polar = calculator.almanacFor(
        year: 2026,
        latitudeDeg: 80.0,
        longitudeDeg: 0.0,
      );
      final day = polar.days.singleWhere(
        (d) => d.date.month == 6 && d.date.day == 21,
      );
      expect(day.sunriseUtc, isNull);
      expect(day.sunsetUtc, isNull);
      expect(day.dayLength, isNull);
    });
  });
}
