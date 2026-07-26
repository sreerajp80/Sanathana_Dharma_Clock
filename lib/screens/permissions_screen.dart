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
                            'Location Access',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Used strictly on-device to determine local sunrise and compute accurate Sanātana Dharma time units (Vedic hours, Muhurtas, Hora, and Panchang).',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            _locationStatusText(location),
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
                          label: const Text('App Settings'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => notifier.requestLocationPermission(),
                          child: const Text('Check / Request'),
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
                            'Internet Access: Disabled',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app deliberately omits the INTERNET permission. It runs 100% offline — no personal data or location coordinates are ever sent to network servers.',
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

  String _locationStatusText(LocationState state) {
    if (state.liveResult == null) {
      return state.useLive ? 'Live mode active' : 'Using saved location';
    }
    switch (state.liveResult!.status) {
      case LocationStatus.success:
        return 'Granted & active';
      case LocationStatus.serviceDisabled:
        return 'GPS service disabled on device';
      case LocationStatus.permissionDenied:
        return 'Permission denied';
      case LocationStatus.permissionDeniedForever:
        return 'Permission blocked (allow in settings)';
      case LocationStatus.error:
        return 'Error fetching location';
    }
  }
}
