import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_language.dart';
import '../core/config/app_localizations.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_card.dart';

/// The Settings screen — a menu of tappable cards: **Language**, **Location**,
/// **Permissions**, **Help**, and **About**.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentMode = ref.read(languageModeProvider);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguageMode.values.map((mode) {
              String label;
              switch (mode) {
                case AppLanguageMode.system:
                  label = l10n.systemDefault;
                  break;
                case AppLanguageMode.english:
                  label = l10n.english;
                  break;
                case AppLanguageMode.malayalam:
                  label = l10n.malayalam;
                  break;
              }

              final isSelected = mode == currentMode;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppTheme.vermillion : null,
                ),
                title: Text(label),
                onTap: () {
                  ref.read(languageModeProvider.notifier).setLanguageMode(mode);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(languageModeProvider);

    String currentLanguageSubtitle;
    switch (mode) {
      case AppLanguageMode.system:
        currentLanguageSubtitle = l10n.systemDefault;
        break;
      case AppLanguageMode.english:
        currentLanguageSubtitle = l10n.english;
        break;
      case AppLanguageMode.malayalam:
        currentLanguageSubtitle = l10n.malayalam;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            NavCard(
              icon: Icons.language_outlined,
              title: l10n.languageTitle,
              subtitle: currentLanguageSubtitle,
              onTap: () => _showLanguageDialog(context, ref),
            ),
            NavCard(
              icon: Icons.place_outlined,
              title: l10n.locationTitle,
              subtitle: l10n.locationCardSubtitle,
              onTap: () => context.push('/settings/location'),
            ),
            NavCard(
              icon: Icons.shield_outlined,
              title: l10n.permissionsTitle,
              subtitle: l10n.permissionsCardSubtitle,
              onTap: () => context.push('/settings/permissions'),
            ),
            NavCard(
              icon: Icons.help_outline,
              title: l10n.helpTitle,
              subtitle: l10n.helpCardSubtitle,
              onTap: () => context.push('/settings/help'),
            ),
            NavCard(
              icon: Icons.info_outline,
              iconColor: AppTheme.vermillion,
              title: l10n.aboutTitle,
              subtitle: l10n.aboutCardSubtitle,
              onTap: () => context.push('/about'),
            ),
          ],
        ),
      ),
    );
  }
}
