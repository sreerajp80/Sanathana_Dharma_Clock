import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/models/saved_location.dart';

/// The only place that reads and writes the saved location and the
/// "use live location" flag in `shared_preferences`.
///
/// Widgets and services never touch prefs directly — they go through this
/// repository (architecture §7, §12). It holds no location math and no UI.
///
/// Reads are defensive: a missing or corrupt record returns a safe default
/// (`null` for the location, `false` for the flag) so a bad pref never crashes
/// the app (CLAUDE.md hard rule 4). Nothing here logs coordinates.
class LocationRepository {
  final SharedPreferences _prefs;

  const LocationRepository(this._prefs);

  /// Returns the single saved location, or `null` when none is stored or the
  /// stored value cannot be parsed.
  SavedLocation? readSavedLocation() {
    final raw = _prefs.getString(AppConstants.prefSavedLocation);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return SavedLocation.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Stores [location] as the single saved record, replacing any previous one.
  Future<bool> writeSavedLocation(SavedLocation location) {
    return _prefs.setString(
      AppConstants.prefSavedLocation,
      jsonEncode(location.toJson()),
    );
  }

  /// Removes the saved location (the Settings "clear" action, security.md §13).
  Future<bool> clearSavedLocation() {
    return _prefs.remove(AppConstants.prefSavedLocation);
  }

  /// Whether the clock should use live GPS. Defaults to `false` (saved
  /// location) when the flag has never been set.
  bool readUseLiveLocation() {
    return _prefs.getBool(AppConstants.prefUseLiveLocation) ?? false;
  }

  /// Stores the "use live location" flag.
  Future<bool> writeUseLiveLocation(bool useLive) {
    return _prefs.setBool(AppConstants.prefUseLiveLocation, useLive);
  }
}
