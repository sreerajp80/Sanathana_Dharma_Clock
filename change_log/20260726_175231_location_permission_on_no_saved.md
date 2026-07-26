# Change Log: Ask Location Permission when No Saved Location Exists

**Date:** 2026-07-26
**Plan Reference:** [plans/20260726_175113_location_permission_on_no_saved.md](file:///l:/Android/Sanathana_Dharma_Clock/plans/20260726_175113_location_permission_on_no_saved.md)

## Summary of Changes

1. **Auto-request Location Permission when No Saved Location Exists:**
   - Updated `LocationNotifier.build()` in [location_providers.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/providers/location_providers.dart) to automatically set `useLive = true` and schedule `refreshLive()` when `saved == null`.
   - Updated `LocationNotifier.clear()` to switch to live GPS and request location permission when the user clears a saved location.
   - Added `requestLocationPermission()` and `openAppSettings()` to `LocationNotifier` with `ref.mounted` safety guards.

2. **Added Location Service Settings Helper:**
   - Added `openAppSettings()` in [location_service.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/services/location_service.dart) wrapping `GeolocatorPlatform.instance.openAppSettings()`.

3. **User Notification Banner Component:**
   - Created [location_permission_banner.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/widgets/location_permission_banner.dart) displaying the exact prompt requirement:
     *"Location permission is required to show the data with respect to current location."*
   - Offers action buttons for *"Grant Permission"* (or *"Open App Settings"* when permanently blocked) and *"Location Settings"*.

4. **Screen Updates:**
   - Added `LocationPermissionBanner` to [clock_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/clock_screen.dart).
   - Replaced empty location placeholder card in [panchang_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/panchang_screen.dart) with `LocationPermissionBanner`.
   - Added *"Open Settings"* button to [location_settings_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/location_settings_screen.dart) when location permission is blocked.

5. **Tests:**
   - Updated [location_providers_test.dart](file:///l:/Android/Sanathana_Dharma_Clock/test/providers/location_providers_test.dart) and [clock_screen_test.dart](file:///l:/Android/Sanathana_Dharma_Clock/test/screens/clock_screen_test.dart).
   - Created [location_permission_banner_test.dart](file:///l:/Android/Sanathana_Dharma_Clock/test/widgets/location_permission_banner_test.dart) for widget testing.

---

## Verification

- `flutter analyze` — Passed with 0 warnings.
- `flutter test` — All 136 unit and widget tests passed cleanly.
