import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';

/// Root dependency-injection providers.
///
/// Both are provided by overriding them in the root `ProviderScope` in
/// `main.dart` after the async values are loaded. Reading either without an
/// override is a programming error and throws. Later phases build the clock,
/// location, and settings providers on top of these.

/// The single [SharedPreferences] instance, loaded once at startup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main().',
  );
});

/// The About-screen config, loaded once at startup.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main().');
});
