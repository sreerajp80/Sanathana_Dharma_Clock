import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/screens/permissions_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPermissions(WidgetTester tester) async {
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
        child: const MaterialApp(home: PermissionsScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders Location Access card and Offline Privacy card', (
    tester,
  ) async {
    await pumpPermissions(tester);

    expect(find.text('Location Access'), findsOneWidget);
    expect(
      find.textContaining('Used strictly on-device to determine local sunrise'),
      findsOneWidget,
    );
    expect(find.text('Internet Access: Disabled'), findsOneWidget);
    expect(
      find.textContaining(
        'This app deliberately omits the INTERNET permission',
      ),
      findsOneWidget,
    );
  });
}
