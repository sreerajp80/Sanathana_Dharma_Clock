import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

/// The outcome of a live-location fetch.
///
/// The service never throws to its caller; every path maps to one of these so
/// the state layer can decide the fallback (idea: live → saved → midnight day).
enum LocationStatus {
  /// A fix was obtained; [LocationResult.latitude]/[longitude] are set.
  success,

  /// The device location service (GPS) is switched off.
  serviceDisabled,

  /// The user denied the permission this time (it can be asked again).
  permissionDenied,

  /// The user denied the permission permanently; only app settings can grant it.
  permissionDeniedForever,

  /// Anything else went wrong while fetching (plugin/platform error).
  error,
}

/// The result of [LocationService.getCurrentLocation].
///
/// On [LocationStatus.success] the coordinates are non-null; on every other
/// status they are `null`. Coordinates are never put in the string form so a
/// stray log cannot leak the user's position (security.md §9).
class LocationResult {
  final LocationStatus status;
  final double? latitude;
  final double? longitude;

  const LocationResult({required this.status, this.latitude, this.longitude});

  const LocationResult.failure(LocationStatus status) : this(status: status);

  bool get isSuccess => status == LocationStatus.success;

  /// Deliberately omits the coordinates — never log the exact position.
  @override
  String toString() => 'LocationResult(status: $status)';
}

/// Reads the device GPS position, asking for permission at the point of use.
///
/// This service knows nothing about `shared_preferences`, `BuildContext`,
/// routes, or UI strings (architecture §7). It wraps
/// [GeolocatorPlatform.instance]; the platform can be injected for tests.
///
/// GPS is a device sensor, not the network — using it does not break the
/// offline rule (architecture §14). The permission is requested here, at the
/// moment a fix is actually needed, never at startup (security.md §11).
class LocationService {
  final GeolocatorPlatform _geolocator;

  LocationService({GeolocatorPlatform? geolocator})
    : _geolocator = geolocator ?? GeolocatorPlatform.instance;

  /// City-level accuracy is enough to place sunrise, and it costs less power
  /// than a precise fix.
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 15),
  );

  /// Fetches the current position, requesting permission if needed.
  ///
  /// Returns a [LocationResult] describing what happened. Never throws — a
  /// plugin or platform error becomes [LocationStatus.error] so the clock can
  /// fall back safely (CLAUDE.md hard rule 4).
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await _geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(LocationStatus.serviceDisabled);
      }

      var permission = await _geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Ask at the point of use, with the manifest reason.
        permission = await _geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          LocationStatus.permissionDeniedForever,
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const LocationResult.failure(LocationStatus.permissionDenied);
      }

      final position = await _geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return LocationResult(
        status: LocationStatus.success,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Includes a permission-denied throw, a disabled service, or a timeout.
      // We only report the category, never the coordinates or the raw error.
      return const LocationResult.failure(LocationStatus.error);
    }
  }

  /// Opens app settings so the user can grant permission if blocked.
  Future<bool> openAppSettings() async {
    try {
      return await _geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
