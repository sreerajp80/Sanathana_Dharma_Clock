import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/core/config/app_config.dart';
import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/screens/about_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A config that carries both languages, like the real asset does.
  const bilingual = AppConfig(
    appName: 'Sanathana Dharma Clock',
    description: 'Keeps time in the Vedic system.',
    version: '2.8.5',
    build: '19',
    details: {'Author': 'Sreeraj P'},
    descriptionMl: 'വൈദിക സമ്പ്രദായത്തിൽ സമയം കാണിക്കുന്നു.',
    detailsMl: {'രചയിതാവ്': 'Sreeraj P'},
  );

  /// A config with no Malayalam block, to prove the English fallback.
  const englishOnly = AppConfig(
    appName: 'Sanathana Dharma Clock',
    description: 'Keeps time in the Vedic system.',
    version: '2.8.5',
    build: '19',
    details: {'Author': 'Sreeraj P'},
  );

  Future<void> pumpAbout(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    AppConfig config = bilingual,
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(config)],
        child: MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ml')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('English shows the English config text and version line', (
    tester,
  ) async {
    await pumpAbout(tester);

    expect(find.text('About'), findsOneWidget);
    expect(find.text(bilingual.description), findsOneWidget);
    expect(find.text('Version 2.8.5 (build 19)'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
  });

  testWidgets('Malayalam shows the Malayalam config text', (tester) async {
    await pumpAbout(tester, locale: const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    expect(find.text(ml.aboutTitle), findsOneWidget);
    expect(find.text(bilingual.descriptionMl), findsOneWidget);
    expect(find.text(ml.versionLine('2.8.5', '19')), findsOneWidget);
    expect(find.text('രചയിതാവ്'), findsOneWidget);

    // The English text and label must be gone.
    expect(find.text(bilingual.description), findsNothing);
    expect(find.text('Version 2.8.5 (build 19)'), findsNothing);
    expect(find.text('Author'), findsNothing);
  });

  testWidgets('a config with no Malayalam block falls back to English', (
    tester,
  ) async {
    await pumpAbout(tester, locale: const Locale('ml'), config: englishOnly);

    // The screen must still show something rather than go blank.
    expect(find.text(englishOnly.description), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
  });

  test('AppConfig reads and falls back per language', () {
    expect(bilingual.descriptionFor(false), bilingual.description);
    expect(bilingual.descriptionFor(true), bilingual.descriptionMl);
    expect(bilingual.detailsFor(true), bilingual.detailsMl);

    expect(englishOnly.descriptionFor(true), englishOnly.description);
    expect(englishOnly.detailsFor(true), englishOnly.details);
  });

  test('AppConfig.fromJson reads the Malayalam block when present', () {
    final config = AppConfig.fromJson(const {
      'appName': 'X',
      'description': 'en',
      'descriptionMl': 'ml',
      'version': '1.0.0',
      'build': '1',
      'details': {'A': 'B'},
      'detailsMl': {'ക': 'ഖ'},
    });

    expect(config.descriptionMl, 'ml');
    expect(config.detailsMl, {'ക': 'ഖ'});
    expect(config.descriptionFor(true), 'ml');
  });

  test('AppConfig.fromJson survives a config with no Malayalam block', () {
    final config = AppConfig.fromJson(const {
      'appName': 'X',
      'description': 'en',
      'version': '1.0.0',
      'build': '1',
    });

    expect(config.descriptionMl, isEmpty);
    expect(config.detailsMl, isEmpty);
    expect(config.descriptionFor(true), 'en');
  });
}
