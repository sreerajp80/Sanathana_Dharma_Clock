import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/core/constants/panchang_names.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/location_providers.dart';
import 'package:sanathana_dharma_clock/providers/service_providers.dart';
import 'package:sanathana_dharma_clock/screens/panchang_screen.dart';
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

  Future<void> pumpPanchang(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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
          home: const PanchangScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Every piece of text the screen has actually drawn.
  List<String> renderedText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((data) => data.isNotEmpty)
      .toList();

  /// The Latin name tables that must not reach a Malayalam screen.
  final latinNames = <String>[
    ...PanchangNames.yogas,
    ...PanchangNames.nakshatras,
    ...PanchangNames.masas,
    ...PanchangNames.rtus,
    ...PanchangNames.movableKaranas,
    ...PanchangNames.endFixedKaranas,
    PanchangNames.kimstughna,
    PanchangNames.purnima,
    PanchangNames.amavasya,
    PanchangNames.shuklaPaksha,
    PanchangNames.krishnaPaksha,
    PanchangNames.uttarayana,
    PanchangNames.dakshinayana,
  ];

  void expectNoLatinNames(WidgetTester tester) {
    final drawn = renderedText(tester);
    for (final latin in latinNames) {
      for (final text in drawn) {
        expect(
          text.contains(latin),
          isFalse,
          reason:
              'Malayalam screen still shows the Latin name "$latin" '
              'inside "$text"',
        );
      }
    }
  }

  testWidgets('English still shows the Latin Sanskrit names', (tester) async {
    await pumpPanchang(tester, const Locale('en'));

    expect(find.text('Panchang'), findsOneWidget);
    expect(find.text('Kerala Style'), findsOneWidget);

    // At least one Latin name from the tables is on screen.
    final drawn = renderedText(tester);
    expect(
      latinNames.any((latin) => drawn.any((text) => text.contains(latin))),
      isTrue,
    );
  });

  testWidgets('Malayalam Kerala tab holds no Latin Sanskrit name', (
    tester,
  ) async {
    await pumpPanchang(tester, const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    expect(find.text(ml.panchangTab), findsOneWidget);
    expect(find.text(ml.keralaStyleTab), findsOneWidget);
    expect(find.text(ml.tithiLabel), findsOneWidget);
    expect(find.text(ml.yogaLabel), findsOneWidget);
    expect(find.text(ml.karanaLabel), findsOneWidget);

    expectNoLatinNames(tester);
  });

  testWidgets('Malayalam North Indian tab holds no Latin Sanskrit name', (
    tester,
  ) async {
    await pumpPanchang(tester, const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    await tester.tap(find.text(ml.northIndianStyleTab));
    await tester.pumpAndSettle();

    expectNoLatinNames(tester);
  });

  testWidgets('the calendar card notes are Malayalam', (tester) async {
    await pumpPanchang(tester, const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    expect(find.text(ml.rtuNote), findsOneWidget);
    expect(
      find.text('The season. Each season spans two lunar months.'),
      findsNothing,
    );
  });
}
