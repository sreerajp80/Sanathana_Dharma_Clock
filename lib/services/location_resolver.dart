import 'package:sanathana_dharma_clock/models/saved_location.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';

/// Where the effective coordinates came from.
enum LocationSource { live, saved }

/// The coordinates the clock will actually run from, plus where they came from.
///
/// Immutable and plugin-free. Carries only the numbers the solar math needs.
class EffectiveLocation {
  final double latitude;
  final double longitude;
  final LocationSource source;

  const EffectiveLocation({
    required this.latitude,
    required this.longitude,
    required this.source,
  });

  /// Deliberately omits the coordinates — never log the exact position.
  @override
  String toString() => 'EffectiveLocation(source: $source)';
}

/// Pure decision logic for the location fallback chain:
/// **live → saved → none**.
///
/// No plugins, no prefs, no UI — just the rule, so it is fully unit-testable.
/// When it returns `null` there is no anchor at all; the caller then uses a
/// midnight-anchored day, which `SolarCalculator` already produces via its
/// fixed-span fallback (CLAUDE.md hard rule 4).
abstract final class LocationResolver {
  /// Picks the effective location:
  /// - If [useLive] and [live] is a successful fix → the live coordinates.
  /// - Else if [saved] is present → the saved coordinates.
  /// - Else → `null` (no anchor; caller falls back to a midnight day).
  static EffectiveLocation? resolve({
    required bool useLive,
    LocationResult? live,
    SavedLocation? saved,
  }) {
    if (useLive && live != null && live.isSuccess) {
      return EffectiveLocation(
        latitude: live.latitude!,
        longitude: live.longitude!,
        source: LocationSource.live,
      );
    }
    if (saved != null) {
      return EffectiveLocation(
        latitude: saved.latitude,
        longitude: saved.longitude,
        source: LocationSource.saved,
      );
    }
    return null;
  }
}
