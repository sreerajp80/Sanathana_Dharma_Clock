import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/providers/clock_providers.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/providers/service_providers.dart';
import 'package:sanathana_dharma_clock/screens/clock_screen.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';
import 'package:sanathana_dharma_clock/widgets/dharma_dial_painter.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationResult.failure(LocationStatus.error);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A fixed instant and a saved Kochi location, the same fake-clock seam the
  // provider tests use, so the clock computes a real, deterministic snapshot.
  final fixedNow = DateTime(2026, 3, 20, 12);
  const kochi = EffectiveLocation(
    latitude: 9.93,
    longitude: 76.26,
    source: LocationSource.saved,
  );

  /// Pumps [ClockScreen] with the clock driven off [fixedNow] and [location].
  Future<void> pumpClock(
    WidgetTester tester, {
    EffectiveLocation? location = kochi,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
          nowProvider.overrideWithValue(() => fixedNow),
          effectiveLocationProvider.overrideWithValue(location),
        ],
        child: const MaterialApp(home: ClockScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  bool hasDial(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .any((paint) => paint.painter is DharmaDialPainter);

  testWidgets('always shows both the readout and the dial', (tester) async {
    await pumpClock(tester);

    // 'Ghaṭikā' now appears in both the readout and the dial legend.
    expect(find.textContaining('Ghaṭikā'), findsWidgets);
    // The ': Vināḍī' formatting is unique to the readout, so it proves it shows.
    expect(find.textContaining(': Vināḍī'), findsOneWidget);
    expect(hasDial(tester), isTrue);
  });

  testWidgets('saved location shows the label and coordinates at the top', (
    tester,
  ) async {
    await pumpClock(tester);

    expect(find.text('Saved location'), findsOneWidget);
    // Coordinates are shown to 4 decimals (9.93 → 9.9300, 76.26 → 76.2600).
    expect(find.text('9.9300, 76.2600'), findsOneWidget);
  });

  testWidgets('no location shows the midnight-anchored message', (
    tester,
  ) async {
    await pumpClock(tester, location: null);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('midnight-anchored day'), findsWidgets);
  });
}
