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
import 'package:sanathana_dharma_clock/screens/hora_screen.dart';
import 'package:sanathana_dharma_clock/services/location_resolver.dart';
import 'package:sanathana_dharma_clock/services/location_service.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationResult.failure(LocationStatus.error);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime(2026, 3, 20, 12);
  const kochi = EffectiveLocation(
    latitude: 9.93,
    longitude: 76.26,
    source: LocationSource.saved,
  );

  Future<void> pumpHora(WidgetTester tester, Locale locale) async {
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
          home: const HoraScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('English shows the English section titles and planet names', (
    tester,
  ) async {
    await pumpHora(tester, const Locale('en'));

    expect(find.text('Day horās'), findsOneWidget);
    expect(find.text('Night horās'), findsOneWidget);
    expect(find.textContaining('Śukra (Venus)'), findsWidgets);
  });

  testWidgets('Malayalam shows Malayalam titles and planet names', (
    tester,
  ) async {
    await pumpHora(tester, const Locale('ml'));

    expect(find.text('പകൽ ഹോരകൾ'), findsOneWidget);
    expect(find.text('രാത്രി ഹോരകൾ'), findsOneWidget);
    expect(find.text('ശുക്രൻ'), findsWidgets);

    expect(find.text('Day horās'), findsNothing);
    expect(find.textContaining('Śukra (Venus)'), findsNothing);
  });
}
