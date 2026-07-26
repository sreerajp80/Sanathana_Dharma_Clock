# Plan: Ask Location Permission when No Saved Location Exists

**Status:** Proposed

## Overview
The app currently displays "No location — midnight-anchored day" when there is no saved location, without automatically requesting location permission or notifying the user clearly that location permission is required to compute times relative to their current location.

This plan adds logic to automatically ask for location permission when no saved location exists, and provides a clear UI notification informing the user that location permission is required to display data relative to their current location.

---

## Technical Approach

### 1. Auto-request Location Permission when No Saved Location Exists
- In `lib/providers/location_providers.dart`:
  - In `LocationNotifier.build()`: If `saved == null` (no saved location), automatically set `useLive = true` and schedule `refreshLive()`.
  - When `refreshLive()` runs, `LocationService.getCurrentLocation()` calls `_geolocator.checkPermission()` and `_geolocator.requestPermission()`, which triggers the OS permission request.
  - In `LocationNotifier.clear()`: When the user clears a saved location, automatically enable `useLive` and trigger `refreshLive()`.
  - Add `requestLocationPermission()` helper method to re-trigger permission requests.

### 2. Location Service Settings Helper
- In `lib/services/location_service.dart`:
  - Add `openAppSettings()` method to allow navigating to Android app settings when location permission is permanently denied (`permissionDeniedForever`).

### 3. User Notification Banner & UI Updates
- Create `lib/widgets/location_permission_banner.dart`:
  - Displays a clear notification banner when `saved == null` and live location is unavailable or permission is needed/denied/blocked.
  - Notification message: *"Location permission is required to show the data with respect to current location."*
  - Action button: *"Grant Permission"* (if denied/missing) or *"Open App Settings"* (if blocked forever).
- In `lib/screens/clock_screen.dart`:
  - Show the notification banner when location permission is needed/denied or no location fix exists.
- In `lib/screens/panchang_screen.dart`:
  - Update the missing-location card to notify the user that location permission is required to show Panchang data for their current location, with a button to grant permission.
- In `lib/screens/location_settings_screen.dart`:
  - Show an "Open App Settings" action when location permission is blocked.

### 4. Unit & Widget Tests
- Update `test/providers/location_providers_test.dart` to test auto-request behavior when `saved == null`.
- Add `test/widgets/location_permission_banner_test.dart` to verify notification banner rendering and actions.

---

## Files to Modify / Create

- [MODIFY] [location_providers.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/providers/location_providers.dart)
- [MODIFY] [location_service.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/services/location_service.dart)
- [NEW] [location_permission_banner.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/widgets/location_permission_banner.dart)
- [MODIFY] [clock_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/clock_screen.dart)
- [MODIFY] [panchang_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/panchang_screen.dart)
- [MODIFY] [location_settings_screen.dart](file:///l:/Android/Sanathana_Dharma_Clock/lib/screens/location_settings_screen.dart)
- [MODIFY] [location_providers_test.dart](file:///l:/Android/Sanathana_Dharma_Clock/test/providers/location_providers_test.dart)
- [NEW] [location_permission_banner_test.dart](file:///l:/Android/Sanathana_Dharma_Clock/test/widgets/location_permission_banner_test.dart)

---

## Verification Plan

1. **Automated Tests:**
   - Run `flutter analyze` to ensure zero static analysis warnings.
   - Run `flutter test` to verify all provider, widget, and service tests pass.

2. **Manual Verification:**
   - Launch app without saved location -> verify location permission prompt appears.
   - Deny permission -> verify notification banner displays *"Location permission is required to show the data with respect to current location"*.
   - Tap "Grant Permission" -> verify location permission is requested again.
   - Grant permission -> verify clock and panchang update with current location data.
