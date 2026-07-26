import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_language.dart';
import 'core_providers.dart';

const String _languagePrefKey = 'app_language';

class LanguageModeNotifier extends Notifier<AppLanguageMode> {
  @override
  AppLanguageMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(_languagePrefKey);
    return AppLanguageMode.fromCode(savedCode);
  }

  Future<void> setLanguageMode(AppLanguageMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_languagePrefKey, mode.code);
  }
}

final languageModeProvider =
    NotifierProvider<LanguageModeNotifier, AppLanguageMode>(
      LanguageModeNotifier.new,
    );

/// Resolves active app language (English or Malayalam) based on settings and platform locale.
final appLanguageProvider = Provider<AppLanguage>((ref) {
  final mode = ref.watch(languageModeProvider);
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  return resolveAppLanguage(mode, deviceLocale);
});

/// Resolves active Locale for MaterialApp.
final localeProvider = Provider<Locale>((ref) {
  final appLanguage = ref.watch(appLanguageProvider);
  return Locale(appLanguage.code);
});
