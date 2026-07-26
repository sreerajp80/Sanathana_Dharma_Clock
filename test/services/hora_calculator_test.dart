import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/core/constants/hora_names.dart';
import 'package:sanathana_dharma_clock/services/hora_calculator.dart';

void main() {
  const calculator = HoraCalculator();

  // A clean fixed day: sunrise 06:00, sunset 18:00, next sunrise 06:00.
  // 2026-07-19 UTC is a Sunday.
  final sunrise = DateTime.utc(2026, 7, 19, 6);
  final sunset = DateTime.utc(2026, 7, 19, 18);
  final nextSunrise = DateTime.utc(2026, 7, 20, 6);

  List<dynamic> horasFor(int weekday) => calculator.horaList(
    sunrise: sunrise,
    sunset: sunset,
    nextSunrise: nextSunrise,
    weekday: weekday,
  );

  group('HoraCalculator.horaList', () {
    test('returns 24 horās of exactly 60 minutes each on a 12h/12h day', () {
      final horas = horasFor(DateTime.sunday);
      expect(horas, hasLength(24));
      for (final h in horas) {
        expect(h.end.difference(h.start), const Duration(minutes: 60));
      }
    });

    test('day horās come first, night horās after', () {
      final horas = horasFor(DateTime.sunday);
      for (var i = 0; i < 12; i++) {
        expect(horas[i].isDay, isTrue, reason: 'index $i should be day');
      }
      for (var i = 12; i < 24; i++) {
        expect(horas[i].isDay, isFalse, reason: 'index $i should be night');
      }
    });

    test('the 24 windows tile sunrise → next sunrise with no gaps', () {
      final horas = horasFor(DateTime.wednesday);
      expect(horas.first.start, sunrise);
      expect(horas.last.end, nextSunrise);
      for (var i = 1; i < horas.length; i++) {
        expect(horas[i].start, horas[i - 1].end, reason: 'gap before index $i');
      }
    });

    test('first day-horā is ruled by the weekday lord, for all 7 weekdays', () {
      const expected = {
        DateTime.sunday: 'Sūrya (Sun)',
        DateTime.monday: 'Chandra (Moon)',
        DateTime.tuesday: 'Maṅgala (Mars)',
        DateTime.wednesday: 'Budha (Mercury)',
        DateTime.thursday: 'Guru (Jupiter)',
        DateTime.friday: 'Śukra (Venus)',
        DateTime.saturday: 'Śani (Saturn)',
      };
      expected.forEach((weekday, lord) {
        expect(horasFor(weekday).first.lord, lord, reason: 'weekday $weekday');
      });
    });

    test('lords step through the fixed horā order', () {
      final horas = horasFor(DateTime.sunday);
      // Sunday starts at Sūrya (index 0), so horā k is simply order[k % 7].
      for (var k = 0; k < 24; k++) {
        expect(horas[k].lord, HoraNames.order[k % 7], reason: 'horā $k');
      }
    });

    test('the 25th horā would be the next weekday lord (24 mod 7 = 3)', () {
      // Sunday's horā 24 (the next sunrise) = order[24 % 7] = order[3]
      // = Chandra, Monday's lord — the classic self-consistency check.
      expect(HoraNames.lordAt(DateTime.sunday, 24), 'Chandra (Moon)');
    });

    test('non-positive daytime returns an empty list', () {
      final horas = calculator.horaList(
        sunrise: sunrise,
        sunset: sunrise, // no daytime
        nextSunrise: nextSunrise,
        weekday: DateTime.sunday,
      );
      expect(horas, isEmpty);
    });

    test('non-positive night returns an empty list', () {
      final horas = calculator.horaList(
        sunrise: sunrise,
        sunset: nextSunrise, // sunset at next sunrise: no night
        nextSunrise: nextSunrise,
        weekday: DateTime.sunday,
      );
      expect(horas, isEmpty);
    });

    test('uneven halves still tile and split each half into 12', () {
      // 14h day, 10h night.
      final lateSunset = DateTime.utc(2026, 7, 19, 20);
      final horas = calculator.horaList(
        sunrise: sunrise,
        sunset: lateSunset,
        nextSunrise: nextSunrise,
        weekday: DateTime.friday,
      );
      expect(horas, hasLength(24));
      // Day horās are 70 min, night horās 50 min.
      expect(
        horas[0].end.difference(horas[0].start),
        const Duration(minutes: 70),
      );
      expect(horas[12].start, lateSunset);
      expect(
        horas[12].end.difference(horas[12].start),
        const Duration(minutes: 50),
      );
      expect(horas.last.end, nextSunrise);
    });
  });
}
