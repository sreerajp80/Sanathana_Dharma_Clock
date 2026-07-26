# Phase 10 — Release hardening

**Status:** partial_completion

**Date:** 2026-07-21
**Implements:** [../docs/implementation_plan.md](../docs/implementation_plan.md) Phase 10.

---

## The issue / goal

The app is feature-complete (Phases 1–9). It has **never been built as a real signed,
obfuscated production release**. Today, release builds silently fall back to the **debug**
keystore (see [android/app/build.gradle.kts](../android/app/build.gradle.kts) lines 51–61),
R8 code shrinking is **off**, and there is **no `proguard-rules.pro`**. Phase 10 turns the
app into a proper, verified production artifact.

What is missing:

1. A **release keystore** (`android/*.jks`) and `android/key.properties` — so `prod` release
   builds are signed with the real key, not the debug key.
2. **R8 / ProGuard** enabled for the release build, with a keep-rules file covering the
   Flutter engine and the location plugin (release_process.md §6.2).
3. A **verified merged release manifest** — proof there is no `INTERNET` permission and no
   `android:debuggable` in the actual built artifact.
4. The **obfuscated, split-per-abi APK** and the **Play Store app bundle**, with debug
   symbols saved under `build/symbols/android-prod-1.0.0/`.
5. A **cold-start check** (under 2 seconds to first frame).

Already done (no change needed): [.gitignore](../.gitignore) already ignores
`android/key.properties`, `android/*.jks`, `android/*.keystore`, and `build/symbols/`
(lines 47–54). The manifest source already has no `INTERNET` and sets
`android:allowBackup="false"`.

---

## Files to change

| File | Change |
|------|--------|
| `android/sanathana_dharma_clock.jks` | **New.** The release keystore. Git-ignored. Created with `keytool`. |
| `android/key.properties` | **New.** Points the Gradle signing config at the keystore. Git-ignored. |
| `android/app/proguard-rules.pro` | **New.** R8 keep rules: `io.flutter.**` and the geolocator plugin classes. |
| `android/app/build.gradle.kts` | Enable `isMinifyEnabled` + `isShrinkResources` for the release build type and wire `proguardFiles`. |
| `docs/implementation_progress.md` | Tick Phase 10 items; add a dated note. |
| `change_log/…_phase10-release-hardening.md` | **New.** The change log after implementing. |
| `.gitignore` | **Verify only** — already correct, no edit expected. |

> The `.jks` and `key.properties` are git-ignored, so they are **not** committed. Only the
> Gradle/ProGuard/doc changes are committed.

---

## The plan for the fix

### Step 1 — Release keystore + `key.properties`

Create `android/sanathana_dharma_clock.jks` with `keytool` (RSA 2048, ~27-year validity):

```bash
keytool -genkeypair -v \
  -keystore android/sanathana_dharma_clock.jks \
  -alias sanathana \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storetype JKS
```

Then write `android/key.properties`:

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=sanathana
storeFile=sanathana_dharma_clock.jks
```

**This needs the user's decisions** (passwords, alias, the certificate name/org). See the
"Decisions needed" section below. **The two offline backups are a manual step only the user
can do** — losing this key means no more Play Store updates.

The Gradle signing block already reads `key.properties` if it exists (build.gradle.kts
lines 38–61), so once these two files exist, `prod --release` signs with the real key
automatically. No Gradle change is needed just for signing.

### Step 2 — R8 / ProGuard

Add `android/app/proguard-rules.pro`:

```proguard
# Flutter engine
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Geolocator (Android) — accessed partly via reflection
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**
```

In `android/app/build.gradle.kts`, in `buildTypes { release { … } }`, add:

```kotlin
isMinifyEnabled = true
isShrinkResources = true
proguardFiles(
    getDefaultProguardFile("proguard-android-optimize.txt"),
    "proguard-rules.pro",
)
```

Then do a **full release build** to prove R8 does not strip anything needed (the doc warns
release-only crashes come from reflection stripping).

### Step 3 — Build the release artifacts

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# Split APKs
flutter build apk --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/android-prod-1.0.0/ --split-per-abi

# Play Store bundle
flutter build appbundle --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/android-prod-1.0.0/
```

Version is `1.0.0+1` (pubspec.yaml), so symbols go under `android-prod-1.0.0/`.

### Step 4 — Verify the merged release manifest

Confirm no `INTERNET` and no `debuggable` in the **built** APK, using `aapt2` from the
Android SDK build-tools:

```bash
aapt2 dump badging build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk \
  | grep -i -E "internet|debuggable"
```

Expected: no `uses-permission … INTERNET` line and no `application-debuggable` line. I will
also unzip the APK's `AndroidManifest.xml` as a cross-check if `aapt2` is not on PATH.

### Step 5 — Cold-start check

Measure time to first frame on an emulator/device (target < 2 s). This needs a running
Android device or emulator.

### Step 6 — Update progress + change log

Tick the Phase 10 boxes in `docs/implementation_progress.md`, add a dated note, and write the
change log.

---

## Decisions (settled)

1. **Keystore:** the **user** runs `keytool` and creates `key.properties` and the two offline
   backups. I do **not** create the keystore or handle any secret. I provide the exact command.
2. **R8:** **enabled** — add `proguard-rules.pro`, turn on `isMinifyEnabled` +
   `isShrinkResources`, wire `proguardFiles`.
3. **No device in this environment:** I make the config file changes (ProGuard + Gradle + docs)
   and **stop before the build**. The keystore creation, the build, the manifest verification,
   and the cold-start check are handed to the user with exact commands.

## What I will change now (config only)

- `android/app/proguard-rules.pro` (new)
- `android/app/build.gradle.kts` (enable minify/shrink + proguardFiles)
- `docs/implementation_progress.md` (mark the done items; note remaining hand-off steps)
- the change log

## What is handed to the user (needs the keystore + a device)

- Create the keystore + `key.properties` + two offline backups.
- Run the release APK + app bundle build (with obfuscation + split-debug-info).
- Verify the built manifest (no `INTERNET`, no `debuggable`).
- Confirm cold start < 2 s.

Because of this, the plan will finish in **`partial_completion`**: all in-repo config is done,
the build/keystore steps remain for the user.

---

## Risk / safety notes

- The keystore and `key.properties` are secrets — git-ignored, never committed, never logged.
- Offline-only hard rule is re-verified on the built artifact (no `INTERNET`).
- R8 can strip reflection-only classes; mitigated by the keep rules and a full release build
  test. If a release-only crash appears, widen `proguard-rules.pro`.
- No app source (`lib/`) changes — this phase is build/release config only.
