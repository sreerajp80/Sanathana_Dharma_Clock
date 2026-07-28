import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/core/constants/dharma_units.dart';
import 'package:sanathana_dharma_clock/screens/help_screen.dart';
import 'package:sanathana_dharma_clock/screens/help_topic_screen.dart';

void main() {
  /// A minimal router with just the Help page and its topic detail route, so
  /// tapping a topic card can be followed to the detail page.
  GoRouter buildRouter() => GoRouter(
    initialLocation: '/settings/help',
    routes: [
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/settings/help/:index',
        builder: (context, state) => HelpTopicScreen(
          index: int.tryParse(state.pathParameters['index'] ?? '') ?? 0,
        ),
      ),
    ],
  );

  Future<void> pumpHelp(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: buildRouter(),
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ml')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
    await tester.pump();
  }

  testWidgets('lists a card for every dharma unit', (tester) async {
    await pumpHelp(tester);

    for (final unit in DharmaUnits.all) {
      expect(find.text(unit.name), findsOneWidget);
    }
  });

  testWidgets('tapping a topic opens its detail page', (tester) async {
    await pumpHelp(tester);

    await tester.tap(find.text(DharmaUnits.ghatika.name));
    await tester.pumpAndSettle();

    // The detail page shows the full description of the tapped unit.
    expect(find.text(DharmaUnits.ghatika.description), findsOneWidget);
  });

  testWidgets('Malayalam shows the Malayalam cards and intro', (tester) async {
    await pumpHelp(tester, locale: const Locale('ml'));

    for (final unit in DharmaUnits.all) {
      expect(find.text(unit.nameMl), findsOneWidget);
      expect(find.text(unit.name), findsNothing);
    }
    expect(
      find.text(AppLocalizations(const Locale('ml')).helpIntro),
      findsOneWidget,
    );
    expect(
      find.text(AppLocalizations(const Locale('ml')).helpApproxNote),
      findsOneWidget,
    );
  });

  testWidgets('Malayalam detail page opens with Malayalam text', (
    tester,
  ) async {
    await pumpHelp(tester, locale: const Locale('ml'));

    await tester.tap(find.text(DharmaUnits.ghatika.nameMl));
    await tester.pumpAndSettle();

    expect(find.text(DharmaUnits.ghatika.descriptionMl), findsOneWidget);
    expect(find.text(DharmaUnits.ghatika.description), findsNothing);
  });
}
