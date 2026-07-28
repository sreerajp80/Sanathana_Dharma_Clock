import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/core/constants/dharma_units.dart';
import 'package:sanathana_dharma_clock/screens/help_topic_screen.dart';

void main() {
  Future<void> pumpTopic(
    WidgetTester tester,
    int index, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ml')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HelpTopicScreen(index: index),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the chosen unit detail', (tester) async {
    // Index 1 is Vināḍī in DharmaUnits.all.
    await pumpTopic(tester, 1);

    expect(find.text(DharmaUnits.vinadi.name), findsWidgets);
    expect(find.text(DharmaUnits.vinadi.description), findsOneWidget);
  });

  testWidgets('falls back to the first unit for an out-of-range index', (
    tester,
  ) async {
    await pumpTopic(tester, 99);

    expect(find.text(DharmaUnits.all.first.description), findsOneWidget);
  });

  testWidgets('shows the Malayalam text when the language is Malayalam', (
    tester,
  ) async {
    // Index 4 is Horā — the longest description in the table.
    await pumpTopic(tester, 4, locale: const Locale('ml'));

    expect(find.text(DharmaUnits.hora.nameMl), findsWidgets);
    expect(find.text(DharmaUnits.hora.descriptionMl), findsOneWidget);
    expect(
      find.text('${DharmaUnits.hora.approxMl}, ${DharmaUnits.hora.countMl}'),
      findsOneWidget,
    );
    expect(find.text(DharmaUnits.hora.description), findsNothing);
  });
}
