# Change Log — Phase 1: Project scaffold and config

**Date:** 2026-07-21
**Implements plan:** [../plans/20260721_051052_phase1-scaffold-and-config.md](../plans/20260721_051052_phase1-scaffold-and-config.md)
**Phase:** 1 of 10 (see [../docs/implementation_plan.md](../docs/implementation_plan.md))

---

## What was done

Built the running Flutter Android app skeleton with flavors, dependencies, the folder
layout, and the data-driven About config. No clock math, screens, or location yet — those
are later phases.

### Project scaffold

- Ran `flutter create --org in.sreerajp --project-name sanathana_dharma_clock
  --platforms android --android-language kotlin .` in the repo root. Existing docs, plans,
  change log, and the guidelines submodule were left untouched.
- Namespace / applicationId is `in.sreerajp.sanathana_dharma_clock`.

### Flavors and Android build config (`android/app/build.gradle.kts`)

- Added `flavorDimensions += "environment"` with two flavors:
  - `dev` — `applicationIdSuffix = ".dev"`, `versionNameSuffix = "-dev"`,
    `app_name = "Sanathana Dharma Clock Dev"`.
  - `prod` — `app_name = "Sanathana Dharma Clock"`.
- Set `minSdk = 24` and `targetSdk = 35`.
- Added a `release` signing config that reads `android/key.properties` **only if it
  exists**. No keystore exists yet (Phase 10), so release builds fall back to the debug key.
- Pointed `android:label` in `src/main/AndroidManifest.xml` at `@string/app_name` so the
  flavor name shows.

### Dependencies (`pubspec.yaml`)

- Added: `flutter_riverpod`, `go_router`, `shared_preferences`, `geolocator_android`,
  `geolocator_platform_interface`.
- Registered the asset folder `assets/config/`.
- Set the app name and a real description.

### `lib/` skeleton

- Created `core/config`, `core/constants`, `core/utils`, `models`, `services`,
  `repositories`, `providers`, `screens`, `widgets`, `theme`. Empty folders hold a
  `.gitkeep`.

### Data-driven About config

- `assets/config/app_config.json` — appName, description, version `1.0.0`, build `1`, and a
  `details` map (Author, Email, License, AI used, IDE used).
- `lib/core/config/app_config.dart` — immutable `AppConfig` with `fromJson` + `fallback`
  (per guideline section 1.4).
- `lib/core/config/config_service.dart` — `ConfigService` with `load()` and
  `loadAndVerify()`, injectable asset loader.

### Flavor config and entry point

- `lib/core/config/app_flavor_config.dart` — `AppFlavorConfig` reading `APP_FLAVOR` then
  `FLUTTER_APP_FLAVOR` (engineering standard section 5.2).
- `lib/providers/core_providers.dart` — root DI providers `sharedPreferencesProvider` and
  `appConfigProvider`, overridden in `main()`.
- `lib/main.dart` — thin entry point: ensure binding, read flavor, load prefs and config,
  wrap in `ProviderScope` with overrides, show a placeholder home screen (replaced by the
  clock in Phase 6).

### Housekeeping

- `.gitignore` — added `android/key.properties`, `android/*.jks`, `android/*.keystore`,
  and `build/symbols/`.
- Removed the default `test/widget_test.dart` (it referenced the removed `MyApp`; real
  tests come in Phase 9).

---

## Key decision / deviation from the plan: no `http`, even transitively

The approved plan listed `package_info_plus` and the `geolocator` umbrella. While wiring
them, `flutter pub deps` showed the app tree pulling in the `http` package. The hard rule in
`CLAUDE.md` says: never accept an http client, even as a transitive dependency.

Findings:

- `package_info_plus` declares `http` directly (used only by its web implementation).
- The `geolocator` umbrella also pulls `http`, via `geolocator_linux → package_info_plus`,
  because the umbrella resolves every platform implementation.

Fix (approved in direction by the user, who chose to drop `package_info_plus`):

- Dropped `package_info_plus` entirely.
- Replaced the `geolocator` umbrella with `geolocator_android` +
  `geolocator_platform_interface` (the Android app never uses the other platforms).
- Result: the dependency tree is now **http-free** (verified with `flutter pub deps`).

Consequences for later phases:

- Location access in Phase 4 uses `GeolocatorPlatform.instance.getCurrentPosition(...)`
  instead of the umbrella's `Geolocator.getCurrentPosition(...)`. Same engine on Android.
- Version/build are read from `app_config.json`, not from the platform.
  `ConfigService.loadAndVerify()` now takes optional `expectedVersion`/`expectedBuild`
  arguments (e.g. from a compile-time `--dart-define`) instead of reading `PackageInfo`.

Another small deviation: ProGuard/R8 minify and the prod-release signing guard were **not**
enabled in Phase 1 (they need a keystore and would block the scaffold build). They are
Phase 10 work.

---

## Verification

- `dart format .` — clean.
- `flutter analyze` — **No issues found.**
- `flutter build apk --flavor dev --debug` — **succeeded** (`app-dev-debug.apk`, exit 0).
  A benign, suppressed Kotlin incremental-compilation warning appeared because the pub
  cache is on `H:` while the project is on `L:` (cross-drive relative path); it did not
  affect the build.
- Offline hard rule: our `src/main/AndroidManifest.xml` (used for release) has **no**
  `INTERNET` permission. The `INTERNET` seen in the debug merged manifest comes only from
  Flutter's generated `src/debug/` and `src/profile/` manifests, which exist for hot reload
  and breakpoints and are not part of a release build. The release APK is verified in
  Phase 10.

---

## Files changed / added (main ones)

- `pubspec.yaml`, `pubspec.lock`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `.gitignore`
- `assets/config/app_config.json`
- `lib/main.dart`
- `lib/core/config/app_config.dart`
- `lib/core/config/config_service.dart`
- `lib/core/config/app_flavor_config.dart`
- `lib/providers/core_providers.dart`
- `lib/` skeleton folders with `.gitkeep`
- Plus the full Android/Flutter scaffold generated by `flutter create`.
- `docs/implementation_progress.md` updated (Phase 1 marked done).
