import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/models/saved_location.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';

void main() {
  const saved = SavedLocation(latitude: 9.93, longitude: 76.26, label: 'Kochi');
  const liveOk = LocationResult(
    status: LocationStatus.success,
    latitude: 12.97,
    longitude: 77.59,
  );
  const liveDenied = LocationResult.failure(LocationStatus.permissionDenied);

  group('LocationResolver.resolve — fallback chain', () {
    test('live wins when useLive and the fetch succeeded', () {
      final result = LocationResolver.resolve(
        useLive: true,
        live: liveOk,
        saved: saved,
      );

      expect(result, isNotNull);
      expect(result!.source, LocationSource.live);
      expect(result.latitude, liveOk.latitude);
      expect(result.longitude, liveOk.longitude);
    });

    test('falls back to saved when live off', () {
      final result = LocationResolver.resolve(
        useLive: false,
        live: liveOk,
        saved: saved,
      );

      expect(result!.source, LocationSource.saved);
      expect(result.latitude, saved.latitude);
      expect(result.longitude, saved.longitude);
    });

    test('falls back to saved when useLive but the fetch failed', () {
      final result = LocationResolver.resolve(
        useLive: true,
        live: liveDenied,
        saved: saved,
      );

      expect(result!.source, LocationSource.saved);
      expect(result.latitude, saved.latitude);
    });

    test('falls back to saved when useLive but there is no live result', () {
      final result = LocationResolver.resolve(
        useLive: true,
        live: null,
        saved: saved,
      );

      expect(result!.source, LocationSource.saved);
    });

    test('returns null when nothing is available (no anchor)', () {
      final result = LocationResolver.resolve(
        useLive: true,
        live: liveDenied,
        saved: null,
      );

      expect(result, isNull);
    });
  });
}
