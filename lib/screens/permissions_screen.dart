import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_localizations.dart';
import '../providers/location_providers.dart';
import '../services/location_service.dart';

/// The **Permissions** screen — lists all device permissions used by the app.
class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final notifier = ref.read(locationProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.permissionsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.locationAccessTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.locationAccessBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          l10n.statusLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            _locationStatusText(location, l10n),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => notifier.openAppSettings(),
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          label: Text(l10n.appSettings),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => notifier.requestLocationPermission(),
                          child: Text(l10n.checkOrRequest),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi_off_outlined, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.internetDisabledTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.internetDisabledBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _locationStatusText(LocationState state, AppLocalizations l10n) {
    if (state.liveResult == null) {
      return state.useLive ? l10n.liveModeActive : l10n.usingSavedLocation;
    }
    switch (state.liveResult!.status) {
      case LocationStatus.success:
        return l10n.grantedAndActive;
      case LocationStatus.serviceDisabled:
        return l10n.gpsDisabled;
      case LocationStatus.permissionDenied:
        return l10n.permissionDenied;
      case LocationStatus.permissionDeniedForever:
        return l10n.permissionBlocked;
      case LocationStatus.error:
        return l10n.errorFetchingLocation;
    }
  }
}
