import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/models/saved_location.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/providers/service_providers.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';
import 'package:sanathana_dharma_clock/widgets/location_permission_banner.dart';

class _FakeLocationService extends LocationService {
  _FakeLocationService(this._result);
  final LocationResult _result;

  @override
  Future<LocationResult> getCurrentLocation() async => _result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Widget> buildTestableWidget({
    Map<String, Object> prefs = const {},
    LocationResult live = const LocationResult.failure(
      LocationStatus.permissionDenied,
    ),
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final store = await SharedPreferences.getInstance();

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(_FakeLocationService(live)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: LocationPermissionBanner()),
      ),
    );
  }

  testWidgets('displays notification text when effective location is null', (
    tester,
  ) async {
    final widget = await buildTestableWidget();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'Location permission is required to show the data with respect to current location',
      ),
      findsOneWidget,
    );
    expect(find.text('Grant Permission'), findsOneWidget);
    expect(find.text('Location Settings'), findsOneWidget);
  });

  testWidgets('displays Open App Settings button when permission is blocked', (
    tester,
  ) async {
    final widget = await buildTestableWidget(
      live: const LocationResult.failure(
        LocationStatus.permissionDeniedForever,
      ),
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('Open App Settings'), findsOneWidget);
  });

  testWidgets('hides banner when a saved location exists and live is off', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(
          _FakeLocationService(
            const LocationResult.failure(LocationStatus.permissionDenied),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Save a location
    await container
        .read(locationProvider.notifier)
        .saveLocation(const SavedLocation(latitude: 10, longitude: 76));
    await container.read(locationProvider.notifier).setUseLive(false);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: LocationPermissionBanner()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
  });
}
