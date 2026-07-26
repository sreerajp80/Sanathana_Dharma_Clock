import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/config/app_flavor_config.dart';
import 'core/config/app_localizations.dart';
import 'core/config/config_service.dart';
import 'core/router.dart';
import 'providers/core_providers.dart';
import 'providers/language_provider.dart';
import 'theme/app_theme.dart';

/// App entry point.
///
/// This is deliberately thin. It runs the startup sequence from the
/// architecture doc (section 5), then hands off to the widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the active build flavor (dev / prod).
  final flavor = AppFlavorConfig.instance;

  // Global error handlers (architecture §10). The app must not hard-crash on an
  // unexpected error; we present/log it and keep running. Verbose detail is
  // gated behind the flavor, and we never log coordinates.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (flavor.enableVerboseLogging) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    if (flavor.enableVerboseLogging) {
      debugPrint('PlatformDispatcher error: $error');
    }
    return true; // handled — do not crash the app
  };

  // Load persistence and the About config before the first frame.
  final prefs = await SharedPreferences.getInstance();
  final AppConfig config = await ConfigService().load();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appConfigProvider.overrideWithValue(config),
      ],
      child: SanathanaDharmaClockApp(flavor: flavor),
    ),
  );
}

class SanathanaDharmaClockApp extends ConsumerWidget {
  const SanathanaDharmaClockApp({super.key, required this.flavor});

  final AppFlavorConfig flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: flavor.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ml')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
