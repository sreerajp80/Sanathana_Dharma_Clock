import 'package:flutter/material.dart';

import '../core/config/app_localizations.dart';
import '../core/constants/dharma_units.dart';
import '../theme/app_theme.dart';

/// The detail page for one dharma time unit, reached from the Help page.
///
/// One reusable screen for every topic: the unit is chosen by its position in
/// [DharmaUnits.all], passed as [index]. All text is read from the shared
/// [DharmaUnits] table in the active language — no data of its own. If [index]
/// is out of range it falls back safely to the first unit (Ghaṭikā).
class HelpTopicScreen extends StatelessWidget {
  const HelpTopicScreen({super.key, required this.index});

  /// The unit's position in [DharmaUnits.all].
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final units = DharmaUnits.all;
    final unit = (index >= 0 && index < units.length)
        ? units[index]
        : units.first;
    final name = unit.nameFor(l10n.isMl);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${unit.approxFor(l10n.isMl)}, ${unit.countFor(l10n.isMl)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              unit.descriptionFor(l10n.isMl),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
