# Release Process — Sanathana Dharma Clock

This document is the runbook for building, signing, and shipping a release of the app.
Read it before building a release, changing the version, or signing.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · [security.md](security.md) ·
[guidelines/release_process.md](guidelines/release_process.md) (the master template) ·
[guidelines/guideline.md](guidelines/guideline.md) §2 (keystore rules — source of truth) ·
[guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).

---

## 1. Release Scope

- App: Sanathana Dharma Clock
- Release profile: `public` (Google Play), starting from the first public build.
- Supported release platforms: `Android` only.
- Engineering standard profiles in force: `Core Baseline`, `Production App Extension`,
  `Sensitive Data Extension`.

---

## 2. Roles And Responsibilities

Single developer, so one person holds every role: engineering, QA, release owner, and store
upload.

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD` (e.g. `1.0.0+1`).
- Source of truth: `pubspec.yaml`.
- Keep `version` and `build` in `assets/config/app_config.json` in sync with `pubspec.yaml`
  (`ConfigService` logs a debug note if they drift — see
  [guidelines/guideline.md](guidelines/guideline.md) §1).
- Build-number increment rule: increase the `+BUILD` number on every Play Store upload.
- Git tag format: `vX.Y.Z`.

---

## 4. Branch And Merge Policy

- `main` only (single developer, trunk-based).
- Before a release: `flutter analyze` clean, `flutter test` green, `dart format` applied.

---

## 5. Environment And Flavor Matrix

| Flavor | Mode | Purpose | Example Command |
|--------|------|---------|-----------------|
| `dev` | `debug` | Local development | `flutter run --flavor dev` |
| `dev` | `release` | Release-like QA | `flutter build apk --flavor dev --release` |
| `prod` | `release` | Final release artifact | See section 8 |

> On Android, `--flavor <name>` is enough — Flutter injects `FLUTTER_APP_FLAVOR`. A bare
> `flutter run` (no flavor) will fail. See
> [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).

---

## 6. Release Build Hardening

Every prod release build MUST include these flags. Missing any is release-blocking.

### 6.1 Obfuscation And Debug Symbols

```bash
--obfuscate
--split-debug-info=build/symbols/android-prod-<version>/
```

- Archive the `build/symbols/` directory after every prod build. Keep it for the life of the
  release. **Never commit it** (it is git-ignored).
- Without the symbols, crash stack traces for that version cannot be read.

### 6.2 ProGuard / R8

Android release builds run R8. Keep `android/app/proguard-rules.pro` covering:
- Flutter engine classes: `io.flutter.**`
- The location plugin classes accessed via reflection.

Do a full release build test after adding any dependency — R8 can silently strip reflection-only
classes (symptom: works in debug, crashes in release).

### 6.3 App Size Analysis

```bash
flutter build apk --flavor prod --release --analyze-size
```

Record the output and compare with the previous release. Budgets: Android APK arm64 under 30 MB
(hard limit 50 MB); AAB download under 20 MB.

### 6.4 Debuggable Verification

Confirm `android:debuggable` is `false` (absent) in the merged release manifest.

```powershell
# PowerShell (Windows)
aapt2 dump badging build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk `
  | Select-String -Pattern debuggable
```

```bash
# bash
aapt2 dump badging build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk \
  | grep -i debuggable
```

Expected: no `application-debuggable` line.

---

## 7. Signing And Secret Handling

> Keystore location, `key.properties` naming, and the `.gitignore` rules are defined in
> [guidelines/guideline.md](guidelines/guideline.md) §2 — the source of truth. Summary below.

- Keystore file: `android/<name>.jks` (filename is your choice per app).
- Signing properties: `android/key.properties` (fixed name), pointing to the keystore:

  ```properties
  storePassword=<store password>
  keyPassword=<key password>
  keyAlias=<key alias>
  storeFile=<name>.jks
  ```

- `.gitignore` MUST include (never commit signing material):

  ```gitignore
  # Signing — never commit
  android/key.properties
  android/*.jks
  android/*.keystore
  build/symbols/
  ```

> **Keystore backup.** Keep at least two secure, offline backups of the keystore. Losing it means
> you can no longer publish updates to the same Play Store listing.

---

## 8. Release Checklist

Complete before every release.

### Code And Quality

- [ ] `dart format --output=none --set-exit-if-changed .` passed.
- [ ] `flutter analyze` passed with zero warnings.
- [ ] `flutter test` passed.
- [ ] No release-blocking bugs open.

### Performance

- [ ] Release build checked for jank on the clock screen (the dial repaints each second).
- [ ] App size analyzed and within budget (section 6.3).
- [ ] Cold startup under 2 seconds on a mid-range device.

### Security

- [ ] `--obfuscate` and `--split-debug-info` applied.
- [ ] Debug symbols archived for this version.
- [ ] ProGuard rules verified.
- [ ] `android:debuggable=false` confirmed in the merged manifest.
- [ ] Permission review: location permissions present, **no** `INTERNET` permission.
- [ ] Security checklist in [security.md](security.md) §18 completed.

### Product And Documentation

- [ ] `pubspec.yaml` version updated.
- [ ] `assets/config/app_config.json` `version`/`build` match `pubspec.yaml`.
- [ ] Release notes updated.
- [ ] Play Store metadata ready.

### Artifact Validation

- [ ] Release artifact built successfully.
- [ ] Installs and launches on a clean device.
- [ ] `prod` flavor confirmed (no dev banner).
- [ ] Version name and build number correct.

---

## 9. Android Release Steps

1. Pull the intended release commit and verify it is clean (`git status`).
2. Verify the version in `pubspec.yaml` and in `assets/config/app_config.json`.
3. Fetch dependencies: `flutter pub get`.
4. Run format, analyze, and test checks.
5. Build the Android artifacts with all hardening flags (below).
6. Run size analysis and record the output.
7. Verify `android:debuggable=false` in the merged manifest.
8. Verify naming, install, and flavor on a real or emulated device.
9. Archive debug symbols from `build/symbols/`.
10. Upload to Google Play.
11. Tag the release: `git tag v<version>` and push.

### Android Build Commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# Split APKs for direct distribution
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-<version>/ \
  --split-per-abi

# App Bundle for Google Play
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-<version>/

# Size analysis
flutter build apk --flavor prod --release --analyze-size
```

---

## 10. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Google Play | `.aab` | Public | Main channel. |
| Direct install | `.apk` (split-per-abi) | Testers | Optional, for quick sharing. |

---

## 11. Rollback And Hotfix Process

- Rollback trigger: a crash or a wrong-time bug found after release.
- Rollback method: halt the Play Store rollout / pause the phased release, then ship a hotfix.
- Hotfix: branch from the release tag, fix, bump the patch version, run the **full** checklist
  again, and archive the hotfix debug symbols.

---

## 12. Release Evidence

Record after each release:

- Size analysis output: `<location>`
- Debug symbols archive: `<secure location>`
- Built artifact: `<location>`
- Release notes: `<location>`
- Play Store rollout record: `<location>`

---

## 13. Post-Release Checks

- [ ] Post-install test on a clean device (offline app — no crash monitoring service).
- [ ] User-reported issues triaged.
- [ ] Release tag created and pushed: `git tag v<version> && git push origin v<version>`.
- [ ] Debug symbols confirmed in the secure archive.
