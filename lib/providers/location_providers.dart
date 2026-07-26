import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_location.dart';
import '../services/location_resolver.dart';
import '../services/location_service.dart';
import 'service_providers.dart';

/// The location state the UI reacts to.
///
/// Immutable. [saved] is the single saved place (or `null`). [useLive] is the
/// user's "use live GPS" flag. [liveResult] is the most recent live fetch (or
/// `null` if never fetched). [isFetching] is `true` while a live fetch runs so
/// the UI can show a spinner. Nothing here logs coordinates.
class LocationState {
  final SavedLocation? saved;
  final bool useLive;
  final LocationResult? liveResult;
  final bool isFetching;

  const LocationState({
    this.saved,
    this.useLive = false,
    this.liveResult,
    this.isFetching = false,
  });

  LocationState copyWith({
    SavedLocation? saved,
    bool clearSaved = false,
    bool? useLive,
    LocationResult? liveResult,
    bool clearLiveResult = false,
    bool? isFetching,
  }) {
    return LocationState(
      saved: clearSaved ? null : (saved ?? this.saved),
      useLive: useLive ?? this.useLive,
      liveResult: clearLiveResult ? null : (liveResult ?? this.liveResult),
      isFetching: isFetching ?? this.isFetching,
    );
  }

  /// Deliberately omits the coordinates — never log the exact position.
  @override
  String toString() =>
      'LocationState(useLive: $useLive, hasSaved: ${saved != null}, '
      'liveStatus: ${liveResult?.status}, isFetching: $isFetching)';
}

/// Owns the saved location, the use-live flag, and the live GPS fetch.
///
/// It is the only provider that talks to [LocationRepository] and
/// [LocationService]. Screens call its methods; they never touch prefs or the
/// plugin directly (architecture §7, §9). Reads come from the repository's
/// defensive getters, so a corrupt pref cannot crash startup.
class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    final repo = ref.watch(locationRepositoryProvider);
    final useLive = repo.readUseLiveLocation();
    final saved = repo.readSavedLocation();

    // If live location was left on in a previous run, fetch a fresh fix on
    // startup. If there is no saved location, automatically enable live mode and
    // ask for location permission.
    if (useLive) {
      Future.microtask(() {
        if (ref.mounted) refreshLive();
      });
    } else if (saved == null) {
      Future.microtask(() {
        if (ref.mounted) setUseLive(true);
      });
    }

    return LocationState(saved: saved, useLive: useLive);
  }

  /// Fetches the current GPS position and stores the outcome in state.
  ///
  /// Never throws — [LocationService.getCurrentLocation] maps every failure to a
  /// [LocationResult], so the state always ends with a status the UI can show.
  Future<LocationResult> refreshLive() async {
    state = state.copyWith(isFetching: true);
    final result = await ref.read(locationServiceProvider).getCurrentLocation();
    if (!ref.mounted) return result;
    state = state.copyWith(liveResult: result, isFetching: false);
    return result;
  }

  /// Sets the use-live flag, persists it, and fetches a fix when turning it on.
  Future<void> setUseLive(bool useLive) async {
    await ref.read(locationRepositoryProvider).writeUseLiveLocation(useLive);
    if (!ref.mounted) return;
    state = state.copyWith(useLive: useLive);
    if (useLive && ref.mounted) await refreshLive();
  }

  /// Saves [location] as the single saved place and persists it.
  Future<void> saveLocation(SavedLocation location) async {
    await ref.read(locationRepositoryProvider).writeSavedLocation(location);
    state = state.copyWith(saved: location);
  }

  /// Clears the saved place (the Settings "clear" action).
  ///
  /// Since there is no saved place left, automatically switches to live GPS
  /// and requests location permission.
  Future<void> clear() async {
    await ref.read(locationRepositoryProvider).clearSavedLocation();
    state = state.copyWith(clearSaved: true);
    await setUseLive(true);
  }

  /// Explicitly requests location permission by triggering a live GPS fetch.
  Future<LocationResult> requestLocationPermission() => refreshLive();

  /// Opens device app settings so the user can grant permission if blocked.
  Future<bool> openAppSettings() =>
      ref.read(locationServiceProvider).openAppSettings();
}

/// The location state notifier.
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);

/// The coordinates the clock will actually run from (live → saved → none).
///
/// Returns `null` when there is no live fix and no saved location; the clock
/// then falls back to a midnight-anchored day (CLAUDE.md hard rule 4). Pure
/// selection over [locationProvider] via [LocationResolver].
final effectiveLocationProvider = Provider<EffectiveLocation?>((ref) {
  final location = ref.watch(locationProvider);
  return LocationResolver.resolve(
    useLive: location.useLive,
    live: location.liveResult,
    saved: location.saved,
  );
});
