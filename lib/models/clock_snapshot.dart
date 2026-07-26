import 'dharma_time.dart';
import '../services/location_resolver.dart';

/// One tick of the clock: everything the readout needs at a single instant.
///
/// Immutable, recomputed once per second by the clock provider. It is a superset
/// of [DharmaTime]: it also carries the ticking [civilTime], whether the day fell
/// back to a fixed span ([isPolar]), and where the anchor location came from
/// ([source], `null` when neither live nor saved was available and a
/// midnight-anchored day was used).
class ClockSnapshot {
  /// The civil (wall-clock) time of this reading, in local time.
  final DateTime civilTime;

  /// The dharma-time reading for [civilTime].
  final DharmaTime dharma;

  /// `true` when no real sunrise anchored the day and the fixed 86,400 s span
  /// was used (polar date or no location).
  final bool isPolar;

  /// Where the anchoring coordinates came from, or `null` for the
  /// midnight-anchored fallback.
  final LocationSource? source;

  const ClockSnapshot({
    required this.civilTime,
    required this.dharma,
    required this.isPolar,
    required this.source,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClockSnapshot &&
          runtimeType == other.runtimeType &&
          civilTime == other.civilTime &&
          dharma == other.dharma &&
          isPolar == other.isPolar &&
          source == other.source;

  @override
  int get hashCode => Object.hash(civilTime, dharma, isPolar, source);

  @override
  String toString() =>
      'ClockSnapshot($dharma, polar: $isPolar, source: $source)';
}
