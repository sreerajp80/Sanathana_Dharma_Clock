import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/constants/app_constants.dart';
import 'package:sanathana_dharma_clock/models/saved_location.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/providers/service_providers.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';

/// A [LocationService] that returns a fixed result without touching the plugin.
class _FakeLocationService extends LocationService {
  _FakeLocationService(this._result);

  final LocationResult _result;

  @override
  Future<LocationResult> getCurrentLocation() async => _result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> containerWith({
    Map<String, Object> prefs = const {},
    LocationResult live = const LocationResult.failure(LocationStatus.error),
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final store = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(_FakeLocationService(live)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  String savedJson(double lat, double lon, String label) => jsonEncode(
    SavedLocation(latitude: lat, longitude: lon, label: label).toJson(),
  );

  group('effectiveLocationProvider — resolve chain', () {
    test(
      'returns null when there is no live fix and no saved location',
      () async {
        final container = await containerWith();
        expect(container.read(effectiveLocationProvider), isNull);
      },
    );

    test('uses the saved location when live is off', () async {
      final container = await containerWith(
        prefs: {
          AppConstants.prefSavedLocation: savedJson(9.93, 76.26, 'Kochi'),
        },
      );

      final effective = container.read(effectiveLocationProvider);
      expect(effective, isNotNull);
      expect(effective!.source, LocationSource.saved);
      expect(effective.latitude, 9.93);
      expect(effective.longitude, 76.26);
    });

    test('fetches a live fix on startup when use-live was left on', () async {
      // useLive persisted true from a previous run, no saved location. The
      // notifier must fetch on build so the clock does not show "No location".
      final container = await containerWith(
        prefs: {AppConstants.prefUseLiveLocation: true},
        live: const LocationResult(
          status: LocationStatus.success,
          latitude: 12.97,
          longitude: 77.59,
        ),
      );

      // Build the notifier and let the scheduled microtask fetch run.
      container.read(locationProvider);
      await Future<void>.delayed(Duration.zero);

      final effective = container.read(effectiveLocationProvider);
      expect(effective, isNotNull);
      expect(effective!.source, LocationSource.live);
      expect(effective.latitude, 12.97);
    });

    test('prefers the live fix over saved when use-live is on', () async {
      final container = await containerWith(
        prefs: {
          AppConstants.prefSavedLocation: savedJson(9.93, 76.26, 'Kochi'),
        },
        live: const LocationResult(
          status: LocationStatus.success,
          latitude: 12.97,
          longitude: 77.59,
        ),
      );

      await container.read(locationProvider.notifier).setUseLive(true);

      final effective = container.read(effectiveLocationProvider);
      expect(effective!.source, LocationSource.live);
      expect(effective.latitude, 12.97);
      expect(effective.longitude, 77.59);
    });

    test('falls back to saved when the live fix fails', () async {
      final container = await containerWith(
        prefs: {
          AppConstants.prefSavedLocation: savedJson(9.93, 76.26, 'Kochi'),
        },
        live: const LocationResult.failure(LocationStatus.permissionDenied),
      );

      await container.read(locationProvider.notifier).setUseLive(true);

      final effective = container.read(effectiveLocationProvider);
      expect(effective!.source, LocationSource.saved);
    });
  });

  group('LocationNotifier', () {
    test('setUseLive persists the flag', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(store),
          locationServiceProvider.overrideWithValue(
            _FakeLocationService(
              const LocationResult.failure(LocationStatus.error),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationProvider.notifier).setUseLive(true);

      expect(container.read(locationProvider).useLive, isTrue);
      expect(store.getBool(AppConstants.prefUseLiveLocation), isTrue);
    });

    test('saveLocation stores the record and updates state', () async {
      final container = await containerWith();
      const place = SavedLocation(latitude: 1, longitude: 2, label: 'Test');

      await container.read(locationProvider.notifier).saveLocation(place);

      expect(container.read(locationProvider).saved, place);
      expect(
        container.read(effectiveLocationProvider)!.source,
        LocationSource.saved,
      );
    });

    test(
      'fetches live location on startup when saved location is null',
      () async {
        final container = await containerWith(
          live: const LocationResult(
            status: LocationStatus.success,
            latitude: 12.97,
            longitude: 77.59,
          ),
        );

        container.read(locationProvider);
        await Future<void>.delayed(Duration.zero);

        final state = container.read(locationProvider);
        expect(state.useLive, isTrue);
        expect(container.read(effectiveLocationProvider)?.latitude, 12.97);
      },
    );

    test(
      'clear removes saved record and switches to live location mode',
      () async {
        final container = await containerWith(
          prefs: {AppConstants.prefSavedLocation: savedJson(1, 2, 'X')},
          live: const LocationResult(
            status: LocationStatus.success,
            latitude: 13.08,
            longitude: 80.27,
          ),
        );

        await container.read(locationProvider.notifier).clear();
        await Future<void>.delayed(Duration.zero);

        expect(container.read(locationProvider).saved, isNull);
        expect(container.read(locationProvider).useLive, isTrue);
        expect(container.read(effectiveLocationProvider)?.latitude, 13.08);
      },
    );
  });
}
