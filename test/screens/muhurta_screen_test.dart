import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/providers/clock_providers.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/providers/service_providers.dart';
import 'package:sanathana_dharma_clock/screens/muhurta_screen.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationResult.failure(LocationStatus.error);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The same fixed instant and saved Kochi location the clock test uses, so the
  // windows are real and deterministic.
  final fixedNow = DateTime(2026, 3, 20, 12);
  const kochi = EffectiveLocation(
    latitude: 9.93,
    longitude: 76.26,
    source: LocationSource.saved,
  );

  Future<void> pumpMuhurta(WidgetTester tester, Locale locale) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
          nowProvider.overrideWithValue(() => fixedNow),
          effectiveLocationProvider.overrideWithValue(kochi),
        ],
        child: MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ml')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MuhurtaScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('English shows the English section titles and kāla names', (
    tester,
  ) async {
    await pumpMuhurta(tester, const Locale('en'));

    expect(find.text('Kālas & special windows'), findsOneWidget);
    expect(find.text('The 30 Muhūrtas'), findsOneWidget);
    expect(find.text('Rāhu Kālam'), findsOneWidget);
  });

  testWidgets('Malayalam shows Malayalam titles, kāla and muhūrta names', (
    tester,
  ) async {
    await pumpMuhurta(tester, const Locale('ml'));

    expect(find.text('കാലങ്ങളും പ്രത്യേക സമയങ്ങളും'), findsOneWidget);
    expect(find.text('30 മുഹൂർത്തങ്ങൾ'), findsOneWidget);
    expect(find.text('രാഹു കാലം'), findsOneWidget);
    // The first muhūrta of the day, from the Malayalam name table.
    expect(find.text('രുദ്രൻ'), findsOneWidget);

    // No English wording is left behind.
    expect(find.text('Kālas & special windows'), findsNothing);
    expect(find.text('Rāhu Kālam'), findsNothing);
  });
}
