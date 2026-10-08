import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/gen/app_localizations.dart';

/// Four-tab shell: Home · History · Insights · You.
class HydraShell extends StatelessWidget {
  const HydraShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: const Icon(Icons.water_drop),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l.navInsights,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.navYou,
          ),
        ],
      ),
    );
  }
}
