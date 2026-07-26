import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';
import '../core/constants/dharma_units.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_card.dart';

/// The **Help** page — a short intro, one tappable card per dharma time unit.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final units = DharmaUnits.all;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                'The clock reads Ghaṭikā : Vināḍī : Prāṇa, like '
                'Hour : Minute : Second. The day starts at local sunrise. '
                'Tap a unit below to learn more.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            for (var i = 0; i < units.length; i++)
              NavCard(
                icon: Icons.schedule,
                iconColor: theme.colorScheme.primary,
                title: units[i].name,
                subtitle: '${units[i].approx}, ${units[i].count}',
                onTap: () => context.push('/settings/help/$i'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
              child: Text(
                'These lengths are approximate — the day flexes a little with '
                'the season, so each unit stretches or shrinks to fit it.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
