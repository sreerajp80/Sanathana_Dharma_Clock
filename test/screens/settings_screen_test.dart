import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /// Pumps [SettingsScreen] on a tall surface so every card in the lazy
  /// [ListView] is built.
  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the five navigation cards including Language',
      (tester) async {
    await pumpSettings(tester);

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('each card has a chevron for navigation', (tester) async {
    await pumpSettings(tester);

    expect(find.byIcon(Icons.chevron_right), findsNWidgets(5));
  });
}
