/// The one saved place the clock runs from when live location is off or
/// unavailable.
///
/// Persisted by the Phase 4 `LocationRepository` as a small JSON string in
/// `shared_preferences`. Immutable; a change makes a new value.
///
/// Security note: `toString()` deliberately omits the coordinates so a stray
/// log call cannot leak the user's position (see security.md §9).
class SavedLocation {
  final double latitude;
  final double longitude;

  /// A short human name for the place (e.g. a city). May be empty.
  final String label;

  const SavedLocation({
    required this.latitude,
    required this.longitude,
    this.label = '',
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
  };

  /// Reads field by field and falls back per field on a missing or wrong-typed
  /// value, so a corrupt saved record never crashes the app. Coordinates accept
  /// either `int` or `double`. Mirrors the defensive pattern in
  /// `AppConfig.fromJson`.
  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    double number(String key) {
      final value = json[key];
      return value is num ? value.toDouble() : 0.0;
    }

    final rawLabel = json['label'];

    return SavedLocation(
      latitude: number('latitude'),
      longitude: number('longitude'),
      label: rawLabel is String ? rawLabel : '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          label == other.label;

  @override
  int get hashCode => Object.hash(latitude, longitude, label);

  /// Omits the coordinates on purpose — never log the exact position.
  @override
  String toString() => 'SavedLocation(label: $label)';
}
