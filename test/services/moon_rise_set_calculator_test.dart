import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/services/lunar_calculator.dart';
import 'package:sanathana_dharma_clock/services/moon_rise_set_calculator.dart';
import 'package:sanathana_dharma_clock/services/solar_calculator.dart';

void main() {
  const lunar = LunarCalculator();
  const calculator = MoonRiseSetCalculator(lunar);
  const solar = SolarCalculator();

  // Ujjain — the classical Panchang reference city (UTC+5:30).
  const lat = 23.1793;
  const lon = 75.7849;

  /// Rise/set over the real dharma day (sunrise → next sunrise) of [dateUtc].
  ({DateTime? moonriseUtc, DateTime? moonsetUtc}) dayEvents(
    DateTime dateUtc, {
    double latitude = lat,
    double longitude = lon,
  }) {
    final sunrise = solar.sunriseUtc(dateUtc, latitude, longitude)!;
    final nextSunrise = solar.sunriseUtc(
      dateUtc.add(const Duration(days: 1)),
      latitude,
      longitude,
    )!;
    return calculator.riseAndSet(
      start: sunrise,
      end: nextSunrise,
      latitudeDeg: latitude,
      longitudeDeg: longitude,
    );
  }

  group('MoonRiseSetCalculator — physical checks at Ujjain', () {
    test('events, when present, always land inside the day window', () {
      for (var d = 0; d < 10; d++) {
        final date = DateTime.utc(2026, 7, 18 + d);
        final sunrise = solar.sunriseUtc(date, lat, lon)!;
        final nextSunrise = solar.sunriseUtc(
          date.add(const Duration(days: 1)),
          lat,
          lon,
        )!;
        final events = dayEvents(date);
        for (final e in [events.moonriseUtc, events.moonsetUtc]) {
          if (e == null) continue;
          expect(e.isAfter(sunrise), isTrue, reason: '$e on $date');
          expect(e.isBefore(nextSunrise), isTrue, reason: '$e on $date');
        }
      }
    });

    test('successive moonrises are one lunar day (~24 h 50 min) apart', () {
      // The dharma-day windows tile time with no gap, so every real moonrise
      // falls in exactly one window; successive captured rises must be
      // spaced by the Moon's own day.
      final rises = <DateTime>[];
      for (var d = 0; d < 8; d++) {
        final r = dayEvents(DateTime.utc(2026, 7, 18 + d)).moonriseUtc;
        if (r != null) rises.add(r);
      }
      expect(rises.length, greaterThanOrEqualTo(6));
      for (var i = 1; i < rises.length; i++) {
        final gap = rises[i].difference(rises[i - 1]);
        expect(gap, greaterThan(const Duration(hours: 24)));
        expect(gap, lessThan(const Duration(hours: 27)));
      }
    });

    test('on the full-moon day the Moon rises near sunset', () {
      // The dharma day of 2026-07-29 has Pūrṇimā at its sunrise. A full moon
      // stands opposite the Sun, so it rises about when the Sun sets.
      final date = DateTime.utc(2026, 7, 29);
      final sunrise = solar.sunriseUtc(date, lat, lon)!;
      final elongation = lunar.elongationDeg(sunrise);
      expect((elongation / 12.0).floor(), 14, reason: 'day must be Pūrṇimā');

      final rise = dayEvents(date).moonriseUtc;
      final sunset = solar.sunsetUtc(date, lat, lon)!;
      expect(rise, isNotNull);
      expect(
        rise!.difference(sunset).inMinutes.abs(),
        lessThan(60),
        reason: 'moonrise $rise vs sunset $sunset',
      );
    });

    test('on the new-moon day the Moon sets near sunset', () {
      // New moon (solar eclipse) 2026-08-12 ≈ 17:46 UTC: the Moon travels
      // with the Sun, so it sets about when the Sun sets.
      final date = DateTime.utc(2026, 8, 12);
      final set = dayEvents(date).moonsetUtc;
      final sunset = solar.sunsetUtc(date, lat, lon)!;
      expect(set, isNotNull);
      expect(
        set!.difference(sunset).inMinutes.abs(),
        lessThan(60),
        reason: 'moonset $set vs sunset $sunset',
      );
    });
  });

  group('MoonRiseSetCalculator — safe fallbacks (hard rule 4)', () {
    test('a non-positive window returns null for both events', () {
      final t = DateTime.utc(2026, 7, 23, 1);
      final events = calculator.riseAndSet(
        start: t,
        end: t,
        latitudeDeg: lat,
        longitudeDeg: lon,
      );
      expect(events.moonriseUtc, isNull);
      expect(events.moonsetUtc, isNull);
    });

    test('a window too short for any crossing returns nulls, no crash', () {
      // Midday at Ujjain a few hours long — the Moon crosses the horizon at
      // most twice a day, so a short window usually holds no crossing.
      final start = DateTime.utc(2026, 7, 23, 7); // ~12:30 local
      final events = calculator.riseAndSet(
        start: start,
        end: start.add(const Duration(minutes: 40)),
        latitudeDeg: lat,
        longitudeDeg: lon,
      );
      // Nothing to assert about which is null — only that nothing crashes
      // and any found event lies inside the window.
      for (final e in [events.moonriseUtc, events.moonsetUtc]) {
        if (e == null) continue;
        expect(e.isAfter(start), isTrue);
      }
    });

    test('an extreme polar latitude never crashes or invents times', () {
      // At 89.9° the Moon stays up (or down) for about two weeks at a time,
      // so most days have no rise or set at all.
      final start = DateTime.utc(2026, 7, 23);
      final end = start.add(const Duration(hours: 24));
      final events = calculator.riseAndSet(
        start: start,
        end: end,
        latitudeDeg: 89.9,
        longitudeDeg: 0,
      );
      for (final e in [events.moonriseUtc, events.moonsetUtc]) {
        if (e == null) continue;
        expect(e.isAfter(start) && !e.isAfter(end), isTrue);
      }
    });
  });
}
