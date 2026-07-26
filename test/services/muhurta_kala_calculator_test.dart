import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/core/constants/muhurta_names.dart';
import 'package:sanathana_dharma_clock/models/muhurta_window.dart';
import 'package:sanathana_dharma_clock/services/muhurta_kala_calculator.dart';

void main() {
  const calc = MuhurtaKalaCalculator();

  // A clean fixed day: sunrise 06:00, sunset 18:00 UTC → daytime 12 h, so each
  // eighth is exactly 90 min and each day-muhūrta (of 15) is 48 min.
  final sunrise = DateTime.utc(2026, 7, 20, 6); // a Monday
  final sunset = DateTime.utc(2026, 7, 20, 18);

  group('MuhurtaKalaCalculator.muhurtaList', () {
    test('30 windows tile the span with no gaps, in MuhurtaNames order', () {
      const span = Duration(hours: 24);
      final list = calc.muhurtaList(sunrise: sunrise, span: span);

      expect(list, hasLength(AppConstants.muhurtaPerDay));
      expect(list.first.start, sunrise);
      expect(list.last.end, sunrise.add(span));
      for (var i = 0; i < list.length; i++) {
        expect(list[i].name, MuhurtaNames.at(i));
        if (i > 0) {
          expect(list[i].start, list[i - 1].end, reason: 'gap before $i');
        }
      }
      // 24 h / 30 = 48 min each.
      expect(
        list.first.end.difference(list.first.start),
        const Duration(minutes: 48),
      );
    });

    test('Brahma Muhūrta (index 28) is tagged auspicious, others neutral', () {
      final list = calc.muhurtaList(
        sunrise: sunrise,
        span: const Duration(hours: 24),
      );
      for (var i = 0; i < list.length; i++) {
        expect(
          list[i].kind,
          i == MuhurtaKalaCalculator.brahmaMuhurtaIndex
              ? WindowKind.auspicious
              : WindowKind.neutral,
        );
      }
    });

    test('non-positive span falls back to a fixed 86,400 s day', () {
      final list = calc.muhurtaList(sunrise: sunrise, span: Duration.zero);
      expect(list, hasLength(AppConstants.muhurtaPerDay));
      expect(
        list.last.end.difference(list.first.start),
        const Duration(seconds: AppConstants.secondsPerDay),
      );
    });
  });

  group('MuhurtaKalaCalculator.kalaWindows — weekday tables', () {
    // Expected 1-based eighth of the daytime for each weekday.
    const rahu = {
      DateTime.monday: 2,
      DateTime.tuesday: 7,
      DateTime.wednesday: 5,
      DateTime.thursday: 6,
      DateTime.friday: 4,
      DateTime.saturday: 3,
      DateTime.sunday: 8,
    };
    const yamaganda = {
      DateTime.monday: 4,
      DateTime.tuesday: 3,
      DateTime.wednesday: 2,
      DateTime.thursday: 1,
      DateTime.friday: 7,
      DateTime.saturday: 6,
      DateTime.sunday: 5,
    };
    const gulika = {
      DateTime.monday: 6,
      DateTime.tuesday: 5,
      DateTime.wednesday: 4,
      DateTime.thursday: 3,
      DateTime.friday: 2,
      DateTime.saturday: 1,
      DateTime.sunday: 7,
    };

    DateTime eighth(int part) =>
        sunrise.add(Duration(minutes: 90 * (part - 1)));

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      test('weekday $weekday puts each kāla in its eighth', () {
        final windows = calc.kalaWindows(
          sunrise: sunrise,
          sunset: sunset,
          weekday: weekday,
        );
        final byName = {for (final w in windows) w.name: w};

        final rahuWindow = byName['Rāhu Kālam']!;
        expect(rahuWindow.start, eighth(rahu[weekday]!));
        expect(rahuWindow.end, eighth(rahu[weekday]! + 1));
        expect(rahuWindow.kind, WindowKind.inauspicious);

        final yamaWindow = byName['Yamagaṇḍa']!;
        expect(yamaWindow.start, eighth(yamaganda[weekday]!));
        expect(yamaWindow.end, eighth(yamaganda[weekday]! + 1));
        expect(yamaWindow.kind, WindowKind.inauspicious);

        final gulikaWindow = byName['Gulika Kālam']!;
        expect(gulikaWindow.start, eighth(gulika[weekday]!));
        expect(gulikaWindow.end, eighth(gulika[weekday]! + 1));
        expect(gulikaWindow.kind, WindowKind.inauspicious);
      });
    }

    test(
      'Abhijit is the 8th of 15 day-muhūrtas: 11:36–12:24 on a 06–18 day',
      () {
        final windows = calc.kalaWindows(
          sunrise: sunrise,
          sunset: sunset,
          weekday: DateTime.monday,
        );
        final abhijit = windows.firstWhere((w) => w.name == 'Abhijit Muhūrta');

        // 7/15 of 12 h = 5 h 36 m after 06:00 → 11:36; ends 48 min later.
        expect(abhijit.start, DateTime.utc(2026, 7, 20, 11, 36));
        expect(abhijit.end, DateTime.utc(2026, 7, 20, 12, 24));
        expect(abhijit.kind, WindowKind.auspicious);
      },
    );

    test('non-positive daytime returns no windows instead of fake ones', () {
      final windows = calc.kalaWindows(
        sunrise: sunset, // inverted on purpose
        sunset: sunrise,
        weekday: DateTime.monday,
      );
      expect(windows, isEmpty);
    });
  });

  group('MuhurtaWindow.contains', () {
    test('start is inside, end is outside', () {
      final w = MuhurtaWindow(
        name: 'x',
        kind: WindowKind.neutral,
        start: sunrise,
        end: sunset,
      );
      expect(w.contains(sunrise), isTrue);
      expect(w.contains(sunset), isFalse);
      expect(w.contains(sunrise.add(const Duration(hours: 1))), isTrue);
    });
  });
}
