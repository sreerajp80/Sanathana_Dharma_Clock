import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/core/constants/muhurta_names.dart';
import 'package:sanathana_dharma_clock/models/muhurta_window.dart';

/// Pure arithmetic for the day's named windows (plan 20260723_063734).
///
/// Two jobs:
/// 1. [muhurtaList] — the 30 muhūrtas of the app's elastic sunrise-to-sunrise
///    day (each `span / 30`), named from [MuhurtaNames]. This matches exactly
///    what the clock and dial already show.
/// 2. [kalaWindows] — the daytime windows: Abhijit Muhūrta (auspicious) and the
///    three inauspicious kālas (Rāhu, Yamagaṇḍa, Gulika). These split the
///    sunrise→sunset daytime, so they need a sunset.
///
/// Like the other services this is pure: values in, values out. No plugins, no
/// `BuildContext`, no UI strings beyond the window names (architecture §7). All
/// splitting is done in microseconds to avoid float drift, mirroring
/// `TimeCalculator`.
class MuhurtaKalaCalculator {
  const MuhurtaKalaCalculator();

  /// Index (0-based) of Brahma Muhūrta in [MuhurtaNames.names] — the pre-dawn
  /// muhūrta, tagged auspicious in the list.
  static const int brahmaMuhurtaIndex = 28;

  /// The daytime is split into 8 equal parts, numbered 1–8 from sunrise; the
  /// weekday picks which part each kāla takes (standard tables). Keys are
  /// `DateTime.weekday` (1 = Monday … 7 = Sunday).
  static const Map<int, int> _rahuPart = {
    DateTime.monday: 2,
    DateTime.tuesday: 7,
    DateTime.wednesday: 5,
    DateTime.thursday: 6,
    DateTime.friday: 4,
    DateTime.saturday: 3,
    DateTime.sunday: 8,
  };

  static const Map<int, int> _yamagandaPart = {
    DateTime.monday: 4,
    DateTime.tuesday: 3,
    DateTime.wednesday: 2,
    DateTime.thursday: 1,
    DateTime.friday: 7,
    DateTime.saturday: 6,
    DateTime.sunday: 5,
  };

  static const Map<int, int> _gulikaPart = {
    DateTime.monday: 6,
    DateTime.tuesday: 5,
    DateTime.wednesday: 4,
    DateTime.thursday: 3,
    DateTime.friday: 2,
    DateTime.saturday: 1,
    DateTime.sunday: 7,
  };

  /// The 30 muhūrtas of the dharma day that starts at [sunrise] (UTC) and lasts
  /// [span]. Muhūrta `i` runs `[sunrise + i·span/30, sunrise + (i+1)·span/30)`.
  ///
  /// A non-positive [span] falls back to a fixed 86,400 s day, the same guard as
  /// `TimeCalculator` (CLAUDE.md hard rule 4), so this never returns an empty or
  /// inverted list.
  List<MuhurtaWindow> muhurtaList({
    required DateTime sunrise,
    required Duration span,
  }) {
    final start = sunrise.toUtc();
    final rawSpan = span.inMicroseconds;
    final spanMicros = rawSpan > 0
        ? rawSpan
        : AppConstants.secondsPerDay * Duration.microsecondsPerSecond;

    return List<MuhurtaWindow>.generate(AppConstants.muhurtaPerDay, (i) {
      // Round each boundary from the exact fraction so the 30 windows tile the
      // span with no gaps and no drift.
      final from = (spanMicros * i / AppConstants.muhurtaPerDay).round();
      final to = (spanMicros * (i + 1) / AppConstants.muhurtaPerDay).round();
      return MuhurtaWindow(
        name: MuhurtaNames.at(i),
        label: WindowLabel.muhurta,
        index: i,
        kind: i == brahmaMuhurtaIndex
            ? WindowKind.auspicious
            : WindowKind.neutral,
        start: start.add(Duration(microseconds: from)),
        end: start.add(Duration(microseconds: to)),
      );
    });
  }

  /// The daytime windows for the day whose daytime runs [sunrise] → [sunset]
  /// (both UTC) on [weekday] (`DateTime.weekday`, 1 = Monday … 7 = Sunday):
  /// Abhijit Muhūrta, Rāhu Kālam, Yamagaṇḍa, Gulika Kālam — in that order.
  ///
  /// Returns an empty list instead of inventing windows when the daytime is not
  /// positive (bad input or a polar edge), so a caller can never show fake
  /// times (CLAUDE.md hard rule 4).
  List<MuhurtaWindow> kalaWindows({
    required DateTime sunrise,
    required DateTime sunset,
    required int weekday,
  }) {
    final dayStart = sunrise.toUtc();
    final daytimeMicros = sunset.toUtc().difference(dayStart).inMicroseconds;
    if (daytimeMicros <= 0) return const [];

    // One window covering the given 1-based part of an equal N-way split.
    MuhurtaWindow part({
      required String name,
      required WindowLabel label,
      required WindowKind kind,
      required int index,
      required int of,
    }) {
      final from = (daytimeMicros * (index - 1) / of).round();
      final to = (daytimeMicros * index / of).round();
      return MuhurtaWindow(
        name: name,
        label: label,
        kind: kind,
        start: dayStart.add(Duration(microseconds: from)),
        end: dayStart.add(Duration(microseconds: to)),
      );
    }

    return [
      // Abhijit: the 8th of the 15 day-muhūrtas, around local solar noon.
      part(
        name: 'Abhijit Muhūrta',
        label: WindowLabel.abhijit,
        kind: WindowKind.auspicious,
        index: 8,
        of: 15,
      ),
      part(
        name: 'Rāhu Kālam',
        label: WindowLabel.rahuKala,
        kind: WindowKind.inauspicious,
        index: _rahuPart[weekday] ?? 8,
        of: 8,
      ),
      part(
        name: 'Yamagaṇḍa',
        label: WindowLabel.yamagandaKala,
        kind: WindowKind.inauspicious,
        index: _yamagandaPart[weekday] ?? 5,
        of: 8,
      ),
      part(
        name: 'Gulika Kālam',
        label: WindowLabel.gulikaKala,
        kind: WindowKind.inauspicious,
        index: _gulikaPart[weekday] ?? 7,
        of: 8,
      ),
    ];
  }
}
