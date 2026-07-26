# Change log — Phase 8: Panchang tab wiring

**Date:** 2026-07-21
**Plan:** [../plans/20260721_192104_phase8-panchang-tab.md](../plans/20260721_192104_phase8-panchang-tab.md)
**Phase:** 8 of [../docs/implementation_plan.md](../docs/implementation_plan.md)

## What changed

The Panchang tab was previously unreachable — the `/panchang` route and screen existed, but
no UI ever navigated to them. This change makes Panchang a proper, reachable tab without
coupling it to the clock.

### Files changed

- **`lib/screens/home_shell.dart`** (new) — a pure navigation shell. It holds the go_router
  `StatefulNavigationShell`, renders the active branch as its body, and shows a bottom
  `NavigationBar` with two destinations: **Clock** and **Panchang**. Tapping a tab calls
  `shell.goBranch(...)`; tapping the current tab returns it to its first route. It imports no
  clock provider, solar service, or dharma model, so Panchang stays decoupled.
- **`lib/core/router.dart`** — wrapped `/` (Clock) and `/panchang` in a
  `StatefulShellRoute.indexedStack` with one branch each (each branch gets its own
  `navigatorKey`). `/settings` and `/about` remain top-level routes outside the shell, so
  they still open full-screen with no tab bar. `initialLocation: '/'` unchanged.
- **`lib/screens/panchang_screen.dart`** — replaced the "coming in a later phase" placeholder
  with a cleaner placeholder (icon, heading, and a plain-English note that daily Panchang
  details are not ready yet). Still no dependency on the clock, solar, or dharma-time code.
- **`docs/implementation_progress.md`** — ticked Phase 8, flipped the status overview to Done,
  updated the overall-status summary, and added a dated note.

## Not done (out of scope, by the plan)

- No real Panchang calculation (tithi, nakshatra, yoga, karana, vara) — that is a separate
  concern for later work.
- No change to the clock, settings, or about screens beyond navigation reachability.

## Verification

- `flutter analyze` — clean, no issues.
- `flutter test` — all 48 tests green (no test changes; widget tests are Phase 9).
- `dart format` applied to the changed files.

## Rule check

- Offline-only, open-source-only, location-on-device: unaffected (no new dependencies, no
  network, no location code touched).
- Panchang stays an independent concern (CLAUDE.md architecture rule; architecture §2) —
  verified: neither `HomeShell` nor `PanchangScreen` imports clock/solar/dharma code.
