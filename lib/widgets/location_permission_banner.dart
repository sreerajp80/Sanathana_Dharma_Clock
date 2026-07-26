import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/location_providers.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

/// A notification card shown when there is no active location anchor (e.g. no
/// saved location and no live GPS fix).
///
/// It informs the user that location permission is required to display data
/// with respect to their current location, and offers quick actions to grant
/// permission, open device app settings, or pick a saved location.
class LocationPermissionBanner extends ConsumerWidget {
  const LocationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = ref.watch(effectiveLocationProvider);

    // If an effective location (live or saved) is available, no banner needed.
    if (effective != null) return const SizedBox.shrink();

    final location = ref.watch(locationProvider);
    final notifier = ref.read(locationProvider.notifier);
    final theme = Theme.of(context);

    final status = location.liveResult?.status;
    final isBlocked = status == LocationStatus.permissionDeniedForever;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: AppTheme.chandanSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.vermillion, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  color: AppTheme.vermillion,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location permission is required to show the data with respect to current location.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.vermillionDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isBlocked
                            ? 'Location permission is blocked in system settings. Grant permission in App Settings or set a location manually.'
                            : 'Without location permission, time calculations use a default midnight anchor instead of your local sunrise.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (location.isFetching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Getting location…'),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isBlocked)
                    FilledButton.icon(
                      onPressed: () => notifier.openAppSettings(),
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Open App Settings'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => notifier.requestLocationPermission(),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Grant Permission'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/settings/location'),
                    icon: const Icon(
                      Icons.edit_location_alt_outlined,
                      size: 18,
                    ),
                    label: const Text('Location Settings'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
