import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_localizations.dart';
import '../models/saved_location.dart';
import '../providers/location_providers.dart';
import '../services/location_service.dart';

/// The **Location** settings page — live/saved toggle, save current, and the
/// saved place.
class LocationSettingsScreen extends ConsumerWidget {
  const LocationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final notifier = ref.read(locationProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.locationTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            SwitchListTile(
              title: Text(l10n.useLiveLocation),
              subtitle: Text(l10n.useLiveLocationHelp),
              value: location.useLive,
              onChanged: location.isFetching
                  ? null
                  : (value) => notifier.setUseLive(value),
            ),
            if (location.isFetching)
              ListTile(
                leading: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text(l10n.gettingCurrentLocation),
              )
            else if (location.liveResult != null &&
                !location.liveResult!.isSuccess)
              ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(_statusMessage(location.liveResult!.status, l10n)),
                trailing:
                    location.liveResult!.status ==
                        LocationStatus.permissionDeniedForever
                    ? TextButton(
                        onPressed: () => notifier.openAppSettings(),
                        child: Text(l10n.openSettings),
                      )
                    : null,
              ),
            _SavedLocationTile(
              saved: location.saved,
              onEditName: location.saved == null
                  ? null
                  : () => _editSavedName(context, ref, location.saved!),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: location.isFetching
                          ? null
                          : () => _saveCurrent(context, ref),
                      icon: const Icon(Icons.my_location),
                      label: Text(l10n.saveCurrentLocation),
                    ),
                  ),
                  if (location.saved != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => notifier.clear(),
                      child: Text(l10n.clear),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetches a live fix and, on success, asks for a name before saving as the saved location.
  ///
  /// Reports the outcome with a [SnackBar] using the status category only —
  /// never the coordinates (security.md §9).
  Future<void> _saveCurrent(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(locationProvider.notifier);
    final currentLocationState = ref.read(locationProvider);
    final l10n = AppLocalizations.of(context);
    final result = await notifier.refreshLive();

    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_statusMessage(result.status, l10n))),
        );
      return;
    }

    final name = await _showNameDialog(
      context,
      initialValue: currentLocationState.saved?.label ?? '',
    );
    if (name == null || !context.mounted) return;

    await notifier.saveLocation(
      SavedLocation(
        latitude: result.latitude!,
        longitude: result.longitude!,
        label: name.trim(),
      ),
    );

    if (!context.mounted) return;
    final message = name.trim().isEmpty
        ? l10n.savedCurrentLocation
        : l10n.savedNamedLocation(name.trim());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Prompts to edit the name of an existing saved location.
  Future<void> _editSavedName(
    BuildContext context,
    WidgetRef ref,
    SavedLocation currentSaved,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await _showNameDialog(
      context,
      initialValue: currentSaved.label,
    );
    if (name == null || !context.mounted) return;

    final updatedLabel = name.trim();
    await ref
        .read(locationProvider.notifier)
        .saveLocation(
          SavedLocation(
            latitude: currentSaved.latitude,
            longitude: currentSaved.longitude,
            label: updatedLabel,
          ),
        );

    if (!context.mounted) return;
    final message = updatedLabel.isEmpty
        ? l10n.updatedLocation
        : l10n.updatedLocationName(updatedLabel);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a dialog asking for a location name.
  Future<String?> _showNameDialog(
    BuildContext context, {
    String initialValue = '',
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(
            initialValue.isEmpty
                ? l10n.nameThisLocation
                : l10n.editLocationName,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l10n.locationNameHint,
              labelText: l10n.locationNameLabel,
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  /// A plain-language reason for a failed live fetch, in the active language.
  /// Never includes coordinates.
  String _statusMessage(LocationStatus status, AppLocalizations l10n) {
    switch (status) {
      case LocationStatus.success:
        return l10n.statusGotLocation;
      case LocationStatus.serviceDisabled:
        return l10n.statusServiceDisabled;
      case LocationStatus.permissionDenied:
        return l10n.statusPermissionDenied;
      case LocationStatus.permissionDeniedForever:
        return l10n.statusPermissionBlocked;
      case LocationStatus.error:
        return l10n.statusError;
    }
  }
}

/// Shows the current saved place (label + coordinates) or "No saved location".
///
/// Coordinates are shown **on screen** for the user; this is allowed. Only
/// logging or sending them is forbidden (security.md §9).
class _SavedLocationTile extends StatelessWidget {
  const _SavedLocationTile({required this.saved, this.onEditName});

  final SavedLocation? saved;
  final VoidCallback? onEditName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (saved == null) {
      return ListTile(
        leading: const Icon(Icons.location_off_outlined),
        title: Text(l10n.noSavedLocation),
        subtitle: Text(l10n.noSavedLocationHelp),
      );
    }

    final label = saved!.label.isEmpty ? l10n.unnamedPlace : saved!.label;
    final coords =
        '${saved!.latitude.toStringAsFixed(4)}, '
        '${saved!.longitude.toStringAsFixed(4)}';

    return ListTile(
      leading: const Icon(Icons.place_outlined),
      title: Text(label),
      subtitle: Text(coords),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        tooltip: l10n.editLocationName,
        onPressed: onEditName,
      ),
    );
  }
}
