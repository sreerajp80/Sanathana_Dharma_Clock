import 'package:flutter/material.dart';

/// The language mode requested by the user in Settings.
enum AppLanguageMode {
  /// Follow system device language (Malayalam if device locale is 'ml', else English).
  system('system'),

  /// Force English interface.
  english('en'),

  /// Force Malayalam interface.
  malayalam('ml');

  final String code;

  const AppLanguageMode(this.code);

  static AppLanguageMode fromCode(String? code) {
    switch (code) {
      case 'en':
        return AppLanguageMode.english;
      case 'ml':
        return AppLanguageMode.malayalam;
      case 'system':
      default:
        return AppLanguageMode.system;
    }
  }
}

/// The effective language active in the app.
enum AppLanguage {
  english('en'),
  malayalam('ml');

  final String code;
  const AppLanguage(this.code);

  bool get isMalayalam => this == AppLanguage.malayalam;
}

/// Resolves effective [AppLanguage] given an [AppLanguageMode] and [deviceLocale].
AppLanguage resolveAppLanguage(AppLanguageMode mode, Locale? deviceLocale) {
  switch (mode) {
    case AppLanguageMode.english:
      return AppLanguage.english;
    case AppLanguageMode.malayalam:
      return AppLanguage.malayalam;
    case AppLanguageMode.system:
      if (deviceLocale != null && deviceLocale.languageCode == 'ml') {
        return AppLanguage.malayalam;
      }
      return AppLanguage.english;
  }
}
