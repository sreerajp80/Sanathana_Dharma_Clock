import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_localizations.dart';

/// The bottom-nav shell that hosts the five main tabs: **Clock**,
/// **Muhurta**, **Hora**, **Panchang**, and **Almanac**.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  /// The go_router shell that tracks which tab (branch) is active.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.access_time_outlined),
            selectedIcon: const Icon(Icons.access_time_filled),
            label: l10n.clockTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timelapse_outlined),
            selectedIcon: const Icon(Icons.timelapse),
            label: l10n.muhurtaTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_twilight_outlined),
            selectedIcon: const Icon(Icons.wb_twilight),
            label: l10n.horaTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.panchangTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.almanacTab,
          ),
        ],
      ),
    );
  }
}
