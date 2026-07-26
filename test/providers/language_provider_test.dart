import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanathana_dharma_clock/core/config/app_language.dart';
import 'package:sanathana_dharma_clock/providers/core_providers.dart';
import 'package:sanathana_dharma_clock/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('languageProvider & resolveAppLanguage', () {
    test('AppLanguageMode fallback and resolution', () {
      expect(AppLanguageMode.fromCode(null), AppLanguageMode.system);
      expect(AppLanguageMode.fromCode('en'), AppLanguageMode.english);
      expect(AppLanguageMode.fromCode('ml'), AppLanguageMode.malayalam);

      expect(
        resolveAppLanguage(AppLanguageMode.english, const Locale('ml')),
        AppLanguage.english,
      );
      expect(
        resolveAppLanguage(AppLanguageMode.malayalam, const Locale('en')),
        AppLanguage.malayalam,
      );
      expect(
        resolveAppLanguage(AppLanguageMode.system, const Locale('ml')),
        AppLanguage.malayalam,
      );
      expect(
        resolveAppLanguage(AppLanguageMode.system, const Locale('en')),
        AppLanguage.english,
      );
    });

    testWidgets('languageModeProvider saves preference to SharedPreferences', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(languageModeProvider), AppLanguageMode.system);

      await container
          .read(languageModeProvider.notifier)
          .setLanguageMode(AppLanguageMode.malayalam);

      expect(container.read(languageModeProvider), AppLanguageMode.malayalam);
      expect(prefs.getString('app_language'), 'ml');
    });
  });
}
