import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/models/dharma_time.dart';

/// The elastic-span mapping between civil time and dharma time, and its exact
/// reverse (idea doc §4).
///
/// Pure: it takes only values (a civil instant, the anchoring sunrise, the day
/// span) and returns a [DharmaTime]. It knows nothing about how the sunrise was
/// found — that is [resolveDay]'s job — so the mapping stays independently
/// testable and reversible. All arithmetic is in microseconds to avoid float
/// drift.
class TimeCalculator {
  const TimeCalculator();

  /// Maps [now] onto Ghaṭikā : Vināḍī : Prāṇa : Muhūrta within the dharma day
  /// that starts at [sunrise] and lasts [span].
  ///
  /// `s = now - sunrise` is clamped to `[0, span)` as a safety net; the caller
  /// ([resolveDay]) is expected to pick an anchor that already keeps `s ≥ 0`.
  /// A non-positive [span] falls back to a fixed 86,400 s day so the clock never
  /// divides by zero (CLAUDE.md hard rule 4).
  DharmaTime toDharmaTime({
    required DateTime now,
    required DateTime sunrise,
    required Duration span,
  }) {
    final rawSpan = span.inMicroseconds;
    final spanMicros = rawSpan > 0
        ? rawSpan
        : AppConstants.secondsPerDay * Duration.microsecondsPerSecond;

    var s = now.toUtc().difference(sunrise.toUtc()).inMicroseconds;
    if (s < 0) s = 0;
    if (s >= spanMicros) s = spanMicros - 1;

    final ghatikaLen = spanMicros / AppConstants.ghatikaPerDay;
    final vinadiLen = ghatikaLen / AppConstants.vinadiPerGhatika;
    final pranaLen = vinadiLen / AppConstants.pranaPerVinadi;

    final ghatika = (s / ghatikaLen).floor();
    final afterGhatika = s - ghatika * ghatikaLen;
    final vinadi = (afterGhatika / vinadiLen).floor();
    final afterVinadi = afterGhatika - vinadi * vinadiLen;
    final prana = (afterVinadi / pranaLen).floor();
    final muhurta = ghatika ~/ 2;

    final fraction = (s / spanMicros).clamp(0.0, 1.0);
    // Smooth progress through the current Ghaṭikā and the current Vināḍī, so the
    // Vināḍī and fast hands sweep instead of jumping between whole units.
    final vinadiFraction = (afterGhatika / ghatikaLen).clamp(0.0, 1.0);
    final pranaFraction = (afterVinadi / vinadiLen).clamp(0.0, 1.0);

    return DharmaTime(
      ghatika: ghatika.clamp(0, AppConstants.ghatikaPerDay - 1),
      vinadi: vinadi.clamp(0, AppConstants.vinadiPerGhatika - 1),
      prana: prana.clamp(0, AppConstants.pranaPerVinadi - 1),
      muhurta: muhurta.clamp(0, AppConstants.muhurtaPerDay - 1),
      fraction: fraction,
      vinadiFraction: vinadiFraction,
      pranaFraction: pranaFraction,
      span: span,
      ghatikaLen: Duration(microseconds: ghatikaLen.round()),
      sunrise: sunrise,
    );
  }

  /// The exact reverse: the civil instant at the **start** of the given
  /// Ghaṭikā : Vināḍī : Prāṇa cell, within the day that starts at [sunrise] and
  /// lasts [span].
  ///
  /// Muhūrta is not an argument because it is derived from Ghaṭikā and carries no
  /// extra information. Because this returns the start of the cell,
  /// `reading → civil → reading` round-trips to the same reading.
  ///
  /// The cell start is rarely a whole number of microseconds for an elastic
  /// span, so it is snapped **up** (`ceil`) to the next whole microsecond. That
  /// keeps the returned instant inside the requested cell (it can never reach the
  /// next boundary, which is a full Prāṇa away), so the forward mapping recovers
  /// the same reading exactly.
  DateTime toCivilTime({
    required int ghatika,
    required int vinadi,
    required int prana,
    required DateTime sunrise,
    required Duration span,
  }) {
    final spanMicros = span.inMicroseconds;
    final ghatikaLen = spanMicros / AppConstants.ghatikaPerDay;
    final vinadiLen = ghatikaLen / AppConstants.vinadiPerGhatika;
    final pranaLen = vinadiLen / AppConstants.pranaPerVinadi;

    final offset =
        (ghatika * ghatikaLen + vinadi * vinadiLen + prana * pranaLen).ceil();
    return sunrise.add(Duration(microseconds: offset));
  }
}
