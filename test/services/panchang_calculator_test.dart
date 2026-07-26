import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/core/constants/panchang_names.dart';
import 'package:sanathana_dharma_clock/models/panchang_day.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';
import 'package:sanathana_dharma_clock/services/moon_rise_set_calculator.dart';
import 'package:sanathana_dharma_clock/services/panchang_calculator.dart';
import 'package:sanathana_dharma_clock/services/solar_calculator.dart';

void main() {
  const lunar = LunarCalculator();
  const calculator = PanchangCalculator(lunar, MoonRiseSetCalculator(lunar));
  const solar = SolarCalculator();

  // Ujjain — the classical Panchang reference city.
  const lat = 23.1793;
  const lon = 75.7849;

  /// The real dharma day (sunrise → next sunrise) for [dateUtc] at Ujjain.
  PanchangDay panchangOn(DateTime dateUtc) {
    final sunrise = solar.sunriseUtc(dateUtc, lat, lon)!;
    final nextSunrise = solar.sunriseUtc(
      dateUtc.add(const Duration(days: 1)),
      lat,
      lon,
    )!;
    // Ujjain is UTC+5:30; the local weekday matches the UTC date's weekday
    // because sunrise (~00:30 UTC) is ~06:00 local the same date.
    return calculator.panchangFor(
      sunrise: sunrise,
      nextSunrise: nextSunrise,
      weekday: dateUtc.weekday,
      latitudeDeg: lat,
      longitudeDeg: lon,
    )!;
  }

  group('PanchangCalculator — solar-eclipse day (2026-08-12, a new moon)', () {
    // A solar eclipse can only happen at a new moon, so at sunrise that day
    // the tithi must be Amāvāsyā (Kṛṣṇa 15), ending near the conjunction
    // (greatest eclipse ≈ 17:46 UTC).
    test('tithi at sunrise is Amāvāsyā, ending near the conjunction', () {
      final p = panchangOn(DateTime.utc(2026, 8, 12));

      expect(p.tithi.name, PanchangNames.amavasya);
      expect(p.tithi.detail, PanchangNames.krishnaPaksha);
      expect(p.tithi.endUtc, isNotNull);
      final diff = p.tithi.endUtc!
          .difference(DateTime.utc(2026, 8, 12, 17, 46))
          .inMinutes
          .abs();
      expect(diff, lessThan(60), reason: 'tithi ends ${p.tithi.endUtc}');
    });

    test('vāra is the weekday name (Wednesday)', () {
      final p = panchangOn(DateTime.utc(2026, 8, 12));
      expect(p.vara, PanchangNames.varas[DateTime.wednesday]);
    });
  });

  group('PanchangCalculator — internal consistency', () {
    final p = panchangOn(DateTime.utc(2026, 7, 23));
    final sunrise = p.sunriseUtc;

    test('tithi and karaṇa agree with the elongation at sunrise', () {
      final e = lunar.elongationDeg(sunrise);
      expect(p.tithi.index, (e / 12.0).floor());
      expect(p.karana.index, (e / 6.0).floor());
      expect(p.tithi.name, PanchangNames.tithi(p.tithi.index));
      expect(p.karana.name, PanchangNames.karana(p.karana.index));
    });

    test('nakṣatra and yoga agree with the sidereal angles at sunrise', () {
      final nak = lunar.moonSiderealLongitudeDeg(sunrise);
      final sum = lunar.yogaSumDeg(sunrise);
      expect(p.nakshatra.index, (nak / LunarCalculator.arcDeg).floor());
      expect(p.yoga.index, (sum / LunarCalculator.arcDeg).floor());
      expect(p.nakshatra.name, PanchangNames.nakshatras[p.nakshatra.index]);
      expect(p.yoga.name, PanchangNames.yogas[p.yoga.index]);
    });

    test('every reported end time lands on its limb boundary', () {
      final checks = <(PanchangLimb, double, double Function(DateTime))>[
        (p.tithi, 12.0, lunar.elongationDeg),
        (p.karana, 6.0, lunar.elongationDeg),
        (p.nakshatra, LunarCalculator.arcDeg, lunar.moonSiderealLongitudeDeg),
        (p.yoga, LunarCalculator.arcDeg, lunar.yogaSumDeg),
      ];
      for (final (limb, step, angleAt) in checks) {
        final end = limb.endUtc;
        if (end == null) continue;
        // At the end instant the angle sits on the next boundary. The angle
        // moves < 16°/day, so 1 s of bisection slack is < 0.0002°.
        final angle = angleAt(end);
        final offBoundary = (angle / step) - (angle / step).roundToDouble();
        expect(offBoundary.abs() * step, lessThan(0.001));
        expect(end.isAfter(p.sunriseUtc), isTrue);
      }
    });
  });

  group('PanchangCalculator — safe fallbacks (hard rule 4)', () {
    test('a non-positive span returns null, never a fake Panchang', () {
      final t = DateTime.utc(2026, 7, 23, 1);
      expect(
        calculator.panchangFor(
          sunrise: t,
          nextSunrise: t,
          weekday: 4,
          latitudeDeg: lat,
          longitudeDeg: lon,
        ),
        isNull,
      );
    });

    test('a limb that outlasts a (shortened) day gets a null end', () {
      // A 30-minute "day": the Moon gains < 0.5° — nothing can end inside it,
      // except a limb caught within a hair of its boundary.
      final sunrise = DateTime.utc(2026, 7, 23, 1);
      final p = calculator.panchangFor(
        sunrise: sunrise,
        nextSunrise: sunrise.add(const Duration(minutes: 30)),
        weekday: 4,
        latitudeDeg: lat,
        longitudeDeg: lon,
      )!;
      final ends = [
        p.tithi.endUtc,
        p.nakshatra.endUtc,
        p.yoga.endUtc,
        p.karana.endUtc,
      ];
      expect(ends.where((e) => e == null).length, greaterThanOrEqualTo(3));
    });
  });

  group('PanchangCalculator — calendar (māsa/pakṣa/ṛtu/ayana)', () {
    // Adhika Śrāvaṇa ran 2023-07-18 → 2023-08-16 (a documented leap month).
    test('2023-08-01 is Adhika Śrāvaṇa, Śukla pakṣa', () {
      final c = panchangOn(DateTime.utc(2023, 8, 1)).calendar!;
      expect(c.amantaMasa, 'Śrāvaṇa');
      expect(c.isAdhika, isTrue);
      expect(c.paksha, PanchangNames.shuklaPaksha);
      // In Śukla pakṣa both conventions carry the same name.
      expect(c.purnimantaMasa, c.amantaMasa);
    });

    test('2023-08-25 is (nija) Śrāvaṇa — not adhika', () {
      final c = panchangOn(DateTime.utc(2023, 8, 25)).calendar!;
      expect(c.amantaMasa, 'Śrāvaṇa');
      expect(c.isAdhika, isFalse);
      expect(c.paksha, PanchangNames.shuklaPaksha);
    });

    // Śarad Navaratri began 2023-10-15 = Āśvina Śukla Pratipadā.
    test('2023-10-16 is Āśvina, Śarad ṛtu', () {
      final c = panchangOn(DateTime.utc(2023, 10, 16)).calendar!;
      expect(c.amantaMasa, 'Āśvina');
      expect(c.isAdhika, isFalse);
      expect(c.rtu, PanchangNames.rtus[3]); // Śarad.
    });

    test('in Kṛṣṇa pakṣa the pūrṇimānta name runs one month ahead', () {
      // 2023-10-05: amānta Bhādrapada Kṛṣṇa → pūrṇimānta Āśvina.
      final c = panchangOn(DateTime.utc(2023, 10, 5)).calendar!;
      expect(c.paksha, PanchangNames.krishnaPaksha);
      expect(c.amantaMasa, 'Bhādrapada');
      expect(c.purnimantaMasa, 'Āśvina');
    });

    test('ayana flips at Makara Saṅkrānti (~Jan 14), not the solstice', () {
      // Early January: past the December solstice but still Dakṣiṇāyana.
      expect(
        panchangOn(DateTime.utc(2026, 1, 10)).calendar!.ayana,
        PanchangNames.dakshinayana,
      );
      expect(
        panchangOn(DateTime.utc(2026, 1, 20)).calendar!.ayana,
        PanchangNames.uttarayana,
      );
      expect(
        panchangOn(DateTime.utc(2026, 7, 23)).calendar!.ayana,
        PanchangNames.dakshinayana,
      );
    });
  });

  group('PanchangNames — māsa / ṛtu tables', () {
    test('māsa wraps and starts at Chaitra', () {
      expect(PanchangNames.masa(0), 'Chaitra');
      expect(PanchangNames.masa(11), 'Phālguna');
      expect(PanchangNames.masa(12), 'Chaitra');
    });

    test('each ṛtu spans two māsas from Chaitra', () {
      expect(PanchangNames.rtuOfMasa(0), PanchangNames.rtus[0]); // Vasanta.
      expect(PanchangNames.rtuOfMasa(1), PanchangNames.rtus[0]);
      expect(PanchangNames.rtuOfMasa(4), PanchangNames.rtus[2]); // Varṣā.
      expect(PanchangNames.rtuOfMasa(11), PanchangNames.rtus[5]); // Śiśira.
    });
  });

  group('PanchangNames — karaṇa slot table', () {
    test('slot 0 is Kiṁstughna, 57–59 the closing fixed three', () {
      expect(PanchangNames.karana(0), PanchangNames.kimstughna);
      expect(PanchangNames.karana(57), 'Śakuni');
      expect(PanchangNames.karana(58), 'Chatuṣpāda');
      expect(PanchangNames.karana(59), 'Nāga');
    });

    test('slots 1–56 cycle the movable seven', () {
      expect(PanchangNames.karana(1), 'Bava');
      expect(PanchangNames.karana(7), 'Viṣṭi');
      expect(PanchangNames.karana(8), 'Bava');
      expect(PanchangNames.karana(56), 'Viṣṭi');
    });

    test('tithi names: 15th of each pakṣa is Pūrṇimā / Amāvāsyā', () {
      expect(PanchangNames.tithi(0), 'Pratipadā');
      expect(PanchangNames.tithi(14), PanchangNames.purnima);
      expect(PanchangNames.tithi(15), 'Pratipadā');
      expect(PanchangNames.tithi(29), PanchangNames.amavasya);
      expect(PanchangNames.paksha(0), PanchangNames.shuklaPaksha);
      expect(PanchangNames.paksha(29), PanchangNames.krishnaPaksha);
    });
  });

  group('PanchangNames — Kerala style and bracket formatting', () {
    test('Kerala Nakshatra names and cross-reference bracket formatting', () {
      expect(
        PanchangNames.nakshatraFormatted(
          0,
          keralaStyle: true,
          isMalayalam: true,
        ),
        'അശ്വതി (Aśvinī)',
      );
      expect(
        PanchangNames.nakshatraFormatted(
          0,
          keralaStyle: true,
          isMalayalam: false,
        ),
        'Aswathi (Aśvinī)',
      );
      expect(
        PanchangNames.nakshatraFormatted(
          0,
          keralaStyle: false,
          isMalayalam: true,
        ),
        'Aśvinī (അശ്വതി)',
      );
    });

    test('Kerala Tithi names and cross-reference bracket formatting', () {
      expect(
        PanchangNames.tithiFormatted(0, keralaStyle: true, isMalayalam: true),
        'പ്രതിപദം (Pratipadā)',
      );
      expect(
        PanchangNames.tithiFormatted(14, keralaStyle: true, isMalayalam: true),
        'പൗർണ്ണമി (വെളുത്ത വാവ്) (Pūrṇimā)',
      );
    });

    test('Kerala Solar Month & Kollavarsham Year calculation', () {
      final p = panchangOn(DateTime.utc(2026, 7, 26));
      expect(p.calendar, isNotNull);
      expect(p.calendar!.kollavarshamYear, 1201);
      expect(p.calendar!.solarMasaIndex, 3); // Karkidakam
    });
  });
}
