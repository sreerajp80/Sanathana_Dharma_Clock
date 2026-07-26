# Change log — Create CLAUDE.md and starter docs

Implements plan: `plans/20260721_003849_create-claude-md-and-docs.md`

## What was created

Following the two provided guideline files (`CLAUDE_MD_GUIDELINE.md` and
`DOCS_FOLDER_GUIDELINE.md`) and the submodule templates, four new files were written:

1. **`CLAUDE.md`** (project root) — Thin profile. Sections in the canonical order: identity table,
   doc-references table, hard rules, architecture rules, build/run commands, flavors, signing,
   security rules, code style, testing, dependency constraints, project tree, and the mandatory
   Workflow and Communication (simple English) sections inline, plus an Always/Never list.

2. **`docs/architecture.md`** — filled-in architecture blueprint for this app: Tier 1 layer-first
   `lib/` layout, sunrise→dharma-time flow, `SolarCalculator` / `time_calculator` /
   `LocationService` design, `DharmaDialPainter`, vermillion-on-chandan theme, offline behavior,
   Riverpod state, go_router navigation, edge-case handling, and testing focus. No database
   (marked N/A) — `shared_preferences` only.

3. **`docs/security.md`** — filled-in security blueprint, kept short and focused on the app's one
   piece of sensitive data (device location): offline stance, location-permission handling,
   no-secrets-logging, backup exclusion, minimal permissions, and an OWASP table with most items
   marked N/A.

4. **`docs/release_process.md`** — Android release runbook: versioning, keystore signing (pointing
   to the guideline as source of truth), hardening flags, APK split-per-abi + Play Store bundle
   commands, checklist, rollback, and post-release checks.

## Decisions applied (confirmed by user)

- State management: **Riverpod**. Navigation: **go_router**.
- Org id / namespace / Android applicationId: all **`in.sreerajp.sanathana_dharma_clock`**.
- A local `docs/release_process.md` was created now (not just linked).

## Notes

- Reference docs (engineering standard, build flavors, keystore rules in `guideline.md`) are
  **linked** to the submodule, not copied, per DOCS_FOLDER_GUIDELINE §2.
- The existing `docs/Sanathana_Dharma_Clock-Idea.md` was left unchanged (not renamed) and is
  linked from `CLAUDE.md` and `architecture.md`.
- A few identity-table values are marked "confirm" (minSdk/targetSdk, orientation) — they need a
  real value before the first release.
- Files were not committed to git (no commit was requested).
