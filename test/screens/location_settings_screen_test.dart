import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/screens/location_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps [LocationSettingsScreen] over an empty mock `SharedPreferences`, so
  /// the location notifier builds against a real (but empty) store and no
  /// widget touches the real plugin on a plain render.
  Future<void> pumpLocation(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LocationSettingsScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the live toggle and empty saved state', (tester) async {
    await pumpLocation(tester);

    expect(find.text('Use live location'), findsOneWidget);
    expect(find.text('No saved location'), findsOneWidget);
  });

  testWidgets('shows saved location with label and edit button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      'saved_location':
          '{"latitude":25.3176,"longitude":82.9739,"label":"Varanasi"}',
      'use_live_location': false,
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LocationSettingsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Varanasi'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

    // Tap edit button to open edit dialog
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit location name'), findsOneWidget);
    expect(find.text('Varanasi'), findsNWidgets(2)); // label tile + text field

    // Change text and tap Save
    await tester.enterText(find.byType(TextField), 'Kashi');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Kashi'), findsOneWidget);
  });
}
