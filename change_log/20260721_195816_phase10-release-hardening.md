# Change log — Phase 10 release hardening (config)

**Date:** 2026-07-21
**Implements (partly):** [../plans/20260721_195816_phase10-release-hardening.md](../plans/20260721_195816_phase10-release-hardening.md)
**Plan status:** partial_completion

---

## What changed

This change does the in-repo half of Phase 10 — the release build configuration. The
keystore and the actual build need the developer's secrets and an Android device, so they
are handed off (see "Handed to the developer" below).

### 1. R8 / ProGuard enabled for the release build

- **New file** `android/app/proguard-rules.pro` — keep rules so R8 does not strip
  reflection-only classes:
  - `io.flutter.**` and `io.flutter.plugins.**` (Flutter engine)
  - `com.baseflow.geolocator.**` (the location plugin)
  - annotations and `native` method names
- **Edited** `android/app/build.gradle.kts`, `buildTypes { release { … } }`: added
  `isMinifyEnabled = true`, `isShrinkResources = true`, and `proguardFiles(...)` pointing at
  the default optimized ProGuard file plus `proguard-rules.pro`.

  This matches `docs/release_process.md` §6.2. The signing block was already wired in an
  earlier phase to read `android/key.properties` when it exists, so no signing change was
  needed here.

### 2. `.gitignore` re-verified (no change)

`.gitignore` already ignores `android/key.properties`, `android/*.jks`, `android/*.keystore`,
and `build/symbols/` (from Phase 1). Confirmed correct; no edit made.

### 3. Docs

- `docs/implementation_progress.md` — overall status, the status table (Phase 10 → in
  progress), the Phase 10 checklist (config items ticked, developer items marked), and a
  dated note.

No `lib/` source changed. `flutter analyze` clean; `flutter test` green (70 tests).

---

## Handed to the developer (needs keystore + device)

These finish Phase 10. Run from the repo root.

1. **Create the release keystore** (then make two offline backups; never commit it):

   ```bash
   keytool -genkeypair -v \
     -keystore android/sanathana_dharma_clock.jks \
     -alias sanathana \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -storetype JKS
   ```

   Then create `android/key.properties`:

   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=sanathana
   storeFile=sanathana_dharma_clock.jks
   ```

2. **Build the release artifacts** (version is `1.0.0`):

   ```bash
   flutter pub get
   flutter build apk --flavor prod --release --obfuscate \
     --split-debug-info=build/symbols/android-prod-1.0.0/ --split-per-abi

   flutter build appbundle --flavor prod --release --obfuscate \
     --split-debug-info=build/symbols/android-prod-1.0.0/
   ```

   Archive `build/symbols/android-prod-1.0.0/` — without it, crash traces for 1.0.0 are
   unreadable. Watch the build for R8 stripping; if a release-only crash appears, widen
   `android/app/proguard-rules.pro`.

3. **Verify the built manifest** (no `INTERNET`, no `debuggable`). `aapt2` lives in the
   Android SDK `build-tools/<version>/`:

   ```bash
   aapt2 dump badging \
     build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk \
     | grep -i -E "internet|debuggable"
   ```

   Expect no output. Cross-check with the size report:

   ```bash
   flutter build apk --flavor prod --release --analyze-size
   ```

4. **Cold-start check** — install on a mid-range device/emulator and confirm time to first
   frame is under 2 seconds.

When these pass, tick the remaining Phase 10 boxes in
`docs/implementation_progress.md` and flip the plan status to `completed`.
