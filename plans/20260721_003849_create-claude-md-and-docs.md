# Create CLAUDE.md and starter docs for Sanathana Dharma Clock

**Status:** completed

## What the issue is

- The project has a `docs/` folder, the guidelines submodule, and an idea document, but it has
  **no `CLAUDE.md`** and **no filled-in blueprint docs**.
- Two guideline files were provided:
  - `CLAUDE_MD_GUIDELINE.md` — how to write a project `CLAUDE.md`.
  - `DOCS_FOLDER_GUIDELINE.md` — how to create files under `docs/`.
- I must create the project `CLAUDE.md` and the starter docs the way those guidelines say.

## Decisions (from the guidelines)

- **Profile: Thin.** The project already has a `docs/` set, ships to Android, and is medium-sized.
  So `CLAUDE.md` stays short and points to `docs/` files (CLAUDE_MD_GUIDELINE §1).
- **Blueprints filled locally; references linked** (DOCS_FOLDER_GUIDELINE §2):
  - Fill in locally: `docs/architecture.md`, `docs/security.md`.
  - Link to submodule (do not copy): `flutter_project_engineering_standard.md`,
    `flutter_build_flavors_guide.md`, `release_process.md`, `guideline.md`.
- The existing `docs/Sanathana_Dharma_Clock-Idea.md` is left as-is (DOCS §3 says do not rename an
  existing file just for style); `CLAUDE.md` and `architecture.md` will link to it.

## Confirmed decisions (from user)

- **State management: Riverpod. Navigation: go_router.**
- **Org id / namespace / Android applicationId: all `in.sreerajp.sanathana_dharma_clock`.**
- **Create `docs/release_process.md` locally now.**

## Files to be created

1. `CLAUDE.md` (project root) — Thin profile, section order per CLAUDE_MD_GUIDELINE §2, with the
   mandatory Workflow and Communication (simple English) sections inline.
2. `docs/architecture.md` — filled-in architecture blueprint for THIS app: layered `lib/` layout
   (config / models / providers / repositories / screens / services / widgets), the
   sunrise→dharma-time flow, the SolarCalculator / LocationService / time_calculator design,
   the DharmaDialPainter, theme (vermillion on chandan), and the Panchang tab boundary.
   State = Riverpod, navigation = go_router.
3. `docs/security.md` — filled-in security blueprint: offline-first stance, location-permission
   handling (live vs saved), no-secrets-logging, `shared_preferences` data inventory,
   minimal-permissions and manifest rules.
4. `docs/release_process.md` — filled-in release runbook: versioning, keystore signing,
   `key.properties`, Android APK (split-per-abi) + Play Store bundle build commands, verify,
   backup checklist.
5. `plans/` and `change_log/` already exist.

## Plan for the work

1. Write `docs/architecture.md` from the submodule `architecture.md` template, filled with the
   idea doc's design (units, mapping, services, painter, theme, settings cards).
2. Write `docs/security.md` from the submodule `security.md` template, focused on location
   permission, offline stance, and local storage.
3. Write `CLAUDE.md` (Thin) with: identity table (Flutter 3.41.9 / Dart 3.11.5, Android, offline,
   `shared_preferences`, org id placeholder), doc-references table, hard rules, architecture
   summary + link, build/run commands, flavors, signing (link), security summary + link, code
   style, testing, dependency constraints, project tree, and the two mandatory sections.
4. Every cross-link uses relative paths; simple English throughout.

## Open questions

- **Package / org id** for the identity table — I will use a placeholder `in.sreerajp.sanathana_dharma_clock`
  unless you give the real one.
- **State management / navigation** — the idea doc does not name them. I will assume
  **Provider + ChangeNotifier** and **named routes** (common in your reference apps) and mark
  them as assumptions to confirm. Tell me if you use Riverpod / go_router instead.
- Should I also create a local `docs/release_process.md` now, or link to the submodule template
  until you do a release? (Plan currently links only.)
