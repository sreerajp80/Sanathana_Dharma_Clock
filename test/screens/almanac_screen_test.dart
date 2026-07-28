import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/providers/service_providers.dart';
import 'package:sanathana_dharma_clock/screens/almanac_screen.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationResult.failure(LocationStatus.error);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kochi = EffectiveLocation(
    latitude: 9.93,
    longitude: 76.26,
    source: LocationSource.saved,
  );

  Future<void> pumpAlmanac(WidgetTester tester, Locale locale) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
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
          home: const AlmanacScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// The month sections sit below the events card, so the list has to be
  /// scrolled before the first month tile is built.
  Future<void> scrollTo(WidgetTester tester, Finder target) =>
      tester.scrollUntilVisible(target, 200);

  testWidgets('English shows English events, months and column labels', (
    tester,
  ) async {
    await pumpAlmanac(tester, const Locale('en'));

    expect(find.text('Sun events of the year'), findsOneWidget);
    expect(find.text('March equinox'), findsOneWidget);

    await scrollTo(tester, find.text('January'));
    expect(find.text('January'), findsOneWidget);
  });

  testWidgets('Malayalam shows Malayalam events, months and column labels', (
    tester,
  ) async {
    await pumpAlmanac(tester, const Locale('ml'));

    expect(find.text('വർഷത്തിലെ സൂര്യ സംഭവങ്ങൾ'), findsOneWidget);
    expect(find.text('മാർച്ച് വിഷുവം'), findsOneWidget);
    expect(find.text('Sun events of the year'), findsNothing);
    expect(find.text('March equinox'), findsNothing);

    await scrollTo(tester, find.text('ജനുവരി'));
    expect(find.text('ജനുവരി'), findsOneWidget);
    expect(find.text('January'), findsNothing);
  });
}
