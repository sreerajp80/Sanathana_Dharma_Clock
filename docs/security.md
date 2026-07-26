# Security — Sanathana Dharma Clock

This document covers the security design of the app. Read it before touching permissions,
logging, storage, or the Android manifest.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · [architecture.md](architecture.md) ·
[guidelines/security.md](guidelines/security.md) (the master template) and
[guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md).

The app is small and offline. Its only sensitive data is the user's **location**. This file is
kept short and focused on that.

---

## 1. Security Scope

- App: Sanathana Dharma Clock
- Data sensitivity level: `moderate` (device location only)
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Sensitive Data Extension` (location)
- Platforms in scope: `Android`

---

## 2. Security Objectives

- Keep the user's location on the device only. Never send it anywhere.
- Prevent accidental disclosure of location through logs, backups, or exports.
- Ask for location permission only at the point of use, with a clear reason.
- Keep the app fully offline — no `INTERNET` permission at all.

---

## 3. Threat Model Summary

### In Scope Threats

- Location leaking into logs during development.
- Location being copied off the device by an automatic cloud backup.
- Reverse engineering of the app logic from the release binary.

### Out Of Scope Threats

- Fully compromised or rooted device.
- Physical hardware attacks.
- Nation-state adversaries.

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| Saved location | `lat 9.93, lon 76.26, "Kochi"` | `shared_preferences` (local) | Excluded from cloud backup; never logged at info+. |
| Live location | Current GPS fix | In memory during a tick | Not persisted unless the user saves it; never logged. |

There are no secrets, tokens, passwords, or accounts in this app.

---

## 5. Storage Model

### At Rest

- Primary local storage: `shared_preferences` — one small JSON record (saved location + display
  settings).
- Secure key storage: N/A — no secrets to store.
- Backup behavior: exclude the app's `shared_preferences` from Android auto-backup so location
  does not leave the device (see §10).

### In Memory

- Live location is held only while computing the current reading; it is short-lived.

### In Transit

- Network use: `none`. The app is fully offline.

---

## 6. Cryptography Design

N/A — the app stores no secrets and does not encrypt data. Location is not high-sensitivity data
that requires encryption at rest for this app's threat model. If a future feature stores more
personal data, revisit this section and the sensitivity level.

---

## 7. Authentication And Access Control

N/A — no accounts, no app lock, no protected routes.

---

## 8. Binary Protections

### 8.1 Obfuscation

All prod release builds MUST be compiled with:

```bash
--obfuscate --split-debug-info=build/symbols/android-prod-<version>/
```

Symbols MUST be archived for the life of the release, and MUST NOT be committed to source control.

### 8.2 R8 / ProGuard

Android release builds run R8. Keep `android/app/proguard-rules.pro` covering Flutter engine
classes and any plugin (the location plugin) accessed via reflection. See
[guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).

### 8.3 Debuggable Flag

Verify `android:debuggable=false` in the merged release manifest before every release.

---

## 9. Logging And Telemetry Policy

### Never Log

- Exact latitude/longitude at `info` level or above.
- Any full location record.

### Allowed Diagnostic Context

- Operation name (e.g. "computed sunrise").
- Whether a location was found (yes/no), not the coordinates.
- Error category, not raw values.

### Logging Controls

- Verbose logging gate: `AppFlavorConfig.enableVerboseLogging` (dev only).
- Log level in production: `info` and above.
- In dev, if coordinates must be printed for debugging, round them heavily or mark clearly and
  never ship such a log statement in a release build.

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: prefer `false`, or use `android:fullBackupContent` /
  `android:dataExtractionRules` to exclude the `shared_preferences` file so the saved location is
  not uploaded to a cloud backup.
- `android:debuggable`: MUST be `false` in release builds.
- Screenshot protection (`FLAG_SECURE`): not required — the clock shows no secrets.
- Root detection: not required.

---

## 11. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| `ACCESS_COARSE_LOCATION` / `ACCESS_FINE_LOCATION` | Find sunrise for the user's place. | When the user taps "use live location" or first fetches a location. | Fall back to the saved location, or a midnight-anchored day. The clock still runs. |

Rules:
- Request only these permissions. Do **not** add `INTERNET` — the app is offline.
- Verify `INTERNET` is absent from the merged release manifest.
- Location is a dangerous permission — request it at the point of use with a short reason, never
  at startup.

---

## 12. OWASP Mobile Top 10 Compliance

Review before every release. Most items are N/A because the app is offline with no secrets.

| ID | Risk | Control | Status |
|----|------|---------|--------|
| M1 | Improper Credential Usage | No secrets in the app | `n/a` |
| M2 | Inadequate Supply Chain Security | `pubspec.lock` committed; dependency audit; licenses open source | `verify each release` |
| M3 | Insecure Authentication | No auth | `n/a` |
| M4 | Insufficient Input/Output Validation | GPS and prefs values validated before use | `verify each release` |
| M5 | Insecure Communication | No network traffic (offline) | `verify manifest` |
| M6 | Inadequate Privacy Controls | Location kept local; not in logs; excluded from backup | `verify each release` |
| M7 | Insufficient Binary Protections | `--obfuscate`; `android:debuggable=false`; ProGuard | `verify each release` |
| M8 | Security Misconfiguration | Only location permission; no `INTERNET`; backup config explicit | `verify each release` |
| M9 | Insecure Data Storage | Only a location record in prefs; no secrets | `verify` |
| M10 | Insufficient Cryptography | No cryptography used | `n/a` |

---

## 13. Data Retention And Purge Policy

| Data Type | Retention | Deletion Trigger |
|-----------|-----------|------------------|
| Saved location | Until the user changes or clears it | User re-fetches / clears, or app uninstall |
| Display settings | Until changed | User change, or app uninstall |

- Settings SHOULD offer a "Clear saved location" action that removes the location record from
  `shared_preferences`.
- On uninstall, Android removes app data by default (verify backup config so nothing lingers in
  the cloud).

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: no in-app backup.
- Export supported: no.
- The only recovery need is re-fetching a location, which is a one-tap action.

---

## 15. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| Location not logged | Unit / review | Grep release build for coordinate logging; none allowed. |
| Prefs content | Unit | Only the location + settings record is written; no secrets. |
| Permission audit | Release build verification | Merged manifest has location perms and **no** `INTERNET`. |
| Obfuscation | Release build verification | `--obfuscate` present in release commands. |
| Debuggable | Release build verification | `android:debuggable=false` confirmed. |

---

## 16. Incident Response Notes

- Triage owner: the app developer.
- Because the app is offline and stores no secrets, the main incident type would be an
  accidental permission or a location leak in logs. Fix by patch release.
- Patch release process: [release_process.md](release_process.md).

---

## 17. Open Risks And Future Hardening

- Risk: a future online feature would change this whole model.
  Hardening: if network is ever added, redo the threat model, add TLS rules, and reconsider
  encrypting the stored location.

---

## 18. Security Review Checklist

Complete before every release.

- [ ] Threat model still matches the app (still offline, location only).
- [ ] Sensitive data inventory current.
- [ ] No log statement prints exact coordinates at info+.
- [ ] Backup config excludes the location record.
- [ ] Permissions reviewed — location only, **no** `INTERNET` in the merged manifest.
- [ ] `--obfuscate` and `--split-debug-info` in all release builds.
- [ ] Debug symbols archived for this version.
- [ ] `android:debuggable=false` verified.
- [ ] ProGuard rules verified.
- [ ] OWASP table (section 12) reviewed and signed off.
