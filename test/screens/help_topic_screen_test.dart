import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanathana_dharma_clock/core/constants/dharma_units.dart';
import 'package:sanathana_dharma_clock/screens/help_topic_screen.dart';

void main() {
  Future<void> pumpTopic(WidgetTester tester, int index) async {
    await tester.pumpWidget(MaterialApp(home: HelpTopicScreen(index: index)));
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
}
