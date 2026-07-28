import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/screens/location_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Wraps [child] in a `MaterialApp` running in [locale], with the app's own
  /// localization delegate installed.
  Widget wrap(Widget child, Locale locale) => MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ml')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );

  /// Pumps [LocationSettingsScreen] over an empty mock `SharedPreferences`, so
  /// the location notifier builds against a real (but empty) store and no
  /// widget touches the real plugin on a plain render.
  Future<void> pumpLocation(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
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
        child: wrap(const LocationSettingsScreen(), locale),
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
        child: wrap(const LocationSettingsScreen(), const Locale('en')),
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

  testWidgets('Malayalam shows the whole page in Malayalam', (tester) async {
    await pumpLocation(tester, locale: const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    expect(find.text(ml.locationTitle), findsOneWidget);
    expect(find.text(ml.useLiveLocation), findsOneWidget);
    expect(find.text(ml.useLiveLocationHelp), findsOneWidget);
    expect(find.text(ml.noSavedLocation), findsOneWidget);
    expect(find.text(ml.noSavedLocationHelp), findsOneWidget);
    expect(find.text(ml.saveCurrentLocation), findsOneWidget);

    // The English wording must be gone.
    expect(find.text('Use live location'), findsNothing);
    expect(find.text('No saved location'), findsNothing);
    expect(find.text('Save current location'), findsNothing);
  });

  testWidgets('the name dialog is Malayalam too', (tester) async {
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
        child: wrap(const LocationSettingsScreen(), const Locale('ml')),
      ),
    );
    await tester.pump();

    final ml = AppLocalizations(const Locale('ml'));

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text(ml.editLocationName), findsOneWidget);
    expect(find.text(ml.locationNameLabel), findsOneWidget);
    expect(find.text(ml.cancel), findsOneWidget);
    expect(find.text(ml.save), findsOneWidget);

    expect(find.text('Edit location name'), findsNothing);
    expect(find.text('Save'), findsNothing);
  });
}
