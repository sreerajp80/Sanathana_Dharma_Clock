import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanathana_dharma_clock/core/config/app_localizations.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/screens/permissions_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPermissions(
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
        child: MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ml')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const PermissionsScreen(),
        ),
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

  testWidgets('Malayalam shows the whole screen in Malayalam', (tester) async {
    await pumpPermissions(tester, locale: const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    expect(find.text(ml.permissionsTitle), findsOneWidget);
    expect(find.text(ml.locationAccessTitle), findsOneWidget);
    expect(find.text(ml.locationAccessBody), findsOneWidget);
    expect(find.text(ml.statusLabel), findsOneWidget);
    expect(find.text(ml.internetDisabledTitle), findsOneWidget);
    expect(find.text(ml.internetDisabledBody), findsOneWidget);
    expect(find.text(ml.appSettings), findsOneWidget);
    expect(find.text(ml.checkOrRequest), findsOneWidget);

    // None of the English wording is left behind.
    expect(find.text('Location Access'), findsNothing);
    expect(find.text('Internet Access: Disabled'), findsNothing);
    expect(find.text('Status: '), findsNothing);
    expect(find.text('App Settings'), findsNothing);
  });

  testWidgets('the status value itself is localized', (tester) async {
    await pumpPermissions(tester, locale: const Locale('ml'));
    final ml = AppLocalizations(const Locale('ml'));

    // With no live fix yet the screen shows one of the two "no result" values.
    expect(
      find.text(ml.liveModeActive).evaluate().isNotEmpty ||
          find.text(ml.usingSavedLocation).evaluate().isNotEmpty,
      isTrue,
    );
    expect(find.text('Live mode active'), findsNothing);
    expect(find.text('Using saved location'), findsNothing);
  });
}
