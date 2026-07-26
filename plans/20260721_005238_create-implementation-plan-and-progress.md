# Plan: Create implementation_plan.md and implementation_progress.md

**Status:** completed

## What the user asked

Create two documentation files in the `docs/` folder, following the rules in
`DOCS_FOLDER_GUIDELINE.md`:

1. `docs/implementation_plan.md` — a phase-by-phase build plan.
2. `docs/implementation_progress.md` — a live checklist of what is done.

## The issue / context

- This is a greenfield project. There is **no `lib/` folder yet** — no Dart source
  has been written. The repository so far holds only docs, the guidelines submodule,
  `CLAUDE.md`, plans, and change logs.
- The `docs/` folder has the living design docs (`architecture.md`, `security.md`,
  `release_process.md`, `Sanathana_Dharma_Clock-Idea.md`) but **no build plan and no
  progress tracker**.
- The guideline (`DOCS_FOLDER_GUIDELINE.md` §6) names both `implementation_plan.md`
  and `implementation_progress.md` as recognized **point-in-time** doc types, so they
  belong as new files (not sections of an existing doc).

## Files to change (create)

| File | Kind | Purpose |
|------|------|---------|
| `docs/implementation_plan.md` | Point-in-time | Phase-by-phase build plan: one `##` per phase, each with an Objective and Action steps, plus a Definition of Done. |
| `docs/implementation_progress.md` | Point-in-time | Status overview + a detailed `- [ ]` checklist by phase, mirroring the plan. Starts all-unchecked because nothing is built yet. |

No source code is touched. No existing doc is edited.

## How the two files will be built (following the guideline)

Both files will follow the standard anatomy from `DOCS_FOLDER_GUIDELINE.md` §4:

- `# H1` title with the app name appended (`— Sanathana Dharma Clock`).
- A one-paragraph purpose line under the title.
- "Read first" relative links to `../CLAUDE.md`, `architecture.md`, and the idea doc.
- A `**Date:** 2026-07-21` line (both are point-in-time docs — §5).
- Numbered `##` sections separated by `---`, simple English, tables and checklists.

### Phases (derived from architecture.md and the idea doc)

The plan will use these phases, in build order:

1. **Project scaffold & config** — Flutter app, package id
   `in.sreerajp.sanathana_dharma_clock`, `dev`/`prod` flavors, `pubspec` deps
   (Riverpod, go_router, geolocator, shared_preferences, package_info_plus),
   analysis options, folder skeleton under `lib/`, `assets/config/app_config.json`,
   About-screen `AppConfig`/`ConfigService`.
2. **Core models** — `DharmaTime`, `SavedLocation` (immutable, JSON round-trip).
3. **Solar & time services** — `SolarCalculator` (NOAA sunrise, UTC math),
   `time_calculator.dart` (civil ↔ Ghaṭikā:Vināḍī:Prāṇa mapping, elastic span).
4. **Location** — `LocationService` (geolocator) + `LocationRepository`
   (shared_preferences), Android location permission, safe fallbacks.
5. **State layer** — Riverpod providers: prefs/config root overrides, once-per-second
   clock tick, active location, settings; day-boundary and lifecycle handling.
6. **UI — clock** — `app_theme.dart` (vermillion-on-chandan), `DharmaDialPainter`,
   `clock_screen.dart`, digital readout, go_router routes.
7. **UI — settings & about** — card-based `settings_screen.dart` (location, display,
   about cards), data-driven `about_screen.dart`.
8. **Panchang tab wiring** — keep the Panchang tab as a separate, untouched concern;
   just wire it into navigation.
9. **Tests** — sunrise math vs NOAA reference, dharma-time mapping + reverse, edge
   cases (before-sunrise anchor, polar 86,400 s span, day-boundary roll), model
   round-trip, widget tests.
10. **Release hardening** — keystore + `key.properties`, `.gitignore` entries, verify
    no `INTERNET` in merged manifest, obfuscated split-per-abi build, backups.

Each phase in `implementation_plan.md` gets an **Objective** and **Action steps**.
The plan ends with a **Definition of Done** section.

`implementation_progress.md` gets a **Status overview** (all phases "Not started")
and a **Detailed checklist** with one `- [ ]` group per phase, matching the plan.

## Out of scope

- Writing any actual Dart/Gradle/asset source (this task is docs only).
- Rewriting or editing existing docs.
- Touching anything in `docs/guidelines/` (the submodule).

## After implementing

Write a change log to `change_log/` named `<ts>_create-implementation-plan-and-progress.md`
referencing this plan.
