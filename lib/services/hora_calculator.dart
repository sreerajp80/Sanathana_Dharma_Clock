import 'package:sanathana_dharma_clock/core/constants/hora_names.dart';
import 'package:sanathana_dharma_clock/models/hora_window.dart';

/// Pure arithmetic for the day's 24 horās (planetary hours)
/// (plan 20260723_073637).
///
/// The daytime (sunrise → sunset) splits into 12 equal day horās and the night
/// (sunset → next sunrise) into 12 equal night horās. Each horā's ruler comes
/// from [HoraNames]: the first day horā is the weekday's lord, then the fixed
/// horā order repeats.
///
/// Like the other services this is pure: values in, values out. No plugins, no
/// `BuildContext`, no UI strings beyond the planet names (architecture §7).
/// All splitting is done in microseconds with rounded boundaries, mirroring
/// `MuhurtaKalaCalculator`, so the 12 + 12 windows tile sunrise → next sunrise
/// with no gaps.
class HoraCalculator {
  const HoraCalculator();

  /// Horās in each half of the day (12 by day, 12 by night).
  static const int horasPerHalf = 12;

  /// The 24 horās of the day that runs [sunrise] → [sunset] → [nextSunrise]
  /// (all UTC), on [weekday] (`DateTime.weekday`, 1 = Monday … 7 = Sunday).
  /// Day horās come first (indices 0–11), then night horās (12–23).
  ///
  /// Returns an empty list instead of inventing windows when either half is
  /// not positive (bad input or a polar edge), so a caller can never show fake
  /// times (CLAUDE.md hard rule 4).
  List<HoraWindow> horaList({
    required DateTime sunrise,
    required DateTime sunset,
    required DateTime nextSunrise,
    required int weekday,
  }) {
    final dayStart = sunrise.toUtc();
    final nightStart = sunset.toUtc();
    final dayEnd = nextSunrise.toUtc();
    final dayMicros = nightStart.difference(dayStart).inMicroseconds;
    final nightMicros = dayEnd.difference(nightStart).inMicroseconds;
    if (dayMicros <= 0 || nightMicros <= 0) return const [];

    return List<HoraWindow>.generate(2 * horasPerHalf, (k) {
      final isDay = k < horasPerHalf;
      final base = isDay ? dayStart : nightStart;
      final halfMicros = isDay ? dayMicros : nightMicros;
      final i = isDay ? k : k - horasPerHalf;
      // Round each boundary from the exact fraction so the 12 windows tile
      // their half with no gaps and no drift.
      final from = (halfMicros * i / horasPerHalf).round();
      final to = (halfMicros * (i + 1) / horasPerHalf).round();
      return HoraWindow(
        lord: HoraNames.lordAt(weekday, k),
        lordIndex: HoraNames.indexAt(weekday, k),
        isDay: isDay,
        start: base.add(Duration(microseconds: from)),
        end: base.add(Duration(microseconds: to)),
      );
    });
  }
}
