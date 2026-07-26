# Phase 8 — Panchang tab wiring

**Status:** completed

## What this phase is

Phase 8 of [../docs/implementation_plan.md](../docs/implementation_plan.md). The goal is
to **make the Panchang tab reachable** in the running app, as a proper separate tab, without
coupling it to the clock.

## The issue

- `PanchangScreen` and the `/panchang` route already exist, but **nothing in the UI ever
  navigates to them**. There is no tab bar. The only navigation is the Settings icon in the
  clock screen's AppBar. So the Panchang screen is dead — you cannot reach it.
- The plan (Phase 8) says to wire Panchang "into navigation as a separate tab" and to keep it
  fully independent of the clock (no shared clock state, solar formula, or dharma-time mapping).

## The plan for the fix

Add a **bottom navigation bar** with two tabs — **Clock** and **Panchang** — using
go_router's `StatefulShellRoute.indexedStack`. Settings and About stay as normal pushed
routes above the shell (unchanged), so the tab bar shows only on the two main tabs.

1. **New file `lib/screens/home_shell.dart`** — a small `StatelessWidget` that takes the
   `StatefulNavigationShell` from go_router, renders the current branch as its `body`, and a
   `NavigationBar` at the bottom with two destinations: Clock (`Icons.access_time`) and
   Panchang (`Icons.calendar_month_outlined`). Tapping a destination calls
   `shell.goBranch(index)`. This is a pure navigation shell — it imports **no** clock
   provider, solar service, or dharma model, so Panchang stays decoupled (CLAUDE.md
   architecture rule; architecture §2).

2. **Edit `lib/core/router.dart`** — wrap `/` (Clock) and `/panchang` in a
   `StatefulShellRoute.indexedStack` with two branches, one route each. Keep `/settings` and
   `/about` as top-level `GoRoute`s outside the shell (so they open full-screen, no tab bar,
   as today). Use `navigatorKey`s so the shell is stable. Keep `initialLocation: '/'`.

3. **Fill in `lib/screens/panchang_screen.dart`** — replace the "coming in a later phase"
   placeholder text with a short, honest placeholder that reads as a real (if minimal) tab:
   a heading and a plain-English note that daily Panchang details are not computed yet. Still
   **no** dependency on the clock, solar, or dharma-time code. Its own `Scaffold`/`AppBar`
   stay (the shell only adds the bottom bar). No Panchang math is added in this phase — that
   is a separate concern and out of scope here.

4. **No change to `ClockScreen`'s Settings icon** — it still opens `/settings` with
   `context.go`. (With a shell in place, `context.go('/settings')` navigates to the
   full-screen route as before.)

## Files to be changed

- `lib/core/router.dart` — add the `StatefulShellRoute` with Clock + Panchang branches.
- `lib/screens/home_shell.dart` — **new** — the bottom-nav shell widget.
- `lib/screens/panchang_screen.dart` — replace placeholder body with a cleaner placeholder.
- `docs/implementation_progress.md` — tick Phase 8, flip status to Done, add a dated note.

## Out of scope

- Any real Panchang calculation (tithi, nakshatra, yoga, karana, vara). That is a separate
  concern and not part of this phase.
- Changing the clock, settings, or about screens beyond navigation reachability.

## Verification

- `flutter analyze` clean.
- `flutter test` still green (48 tests; no test changes expected — Phase 9 adds widget tests).
- Manual check intent: app opens on Clock; the bottom bar switches between Clock and
  Panchang; Settings/About still open full-screen from the clock AppBar / settings card.

## After implementing

Write a change log to `change_log/` referencing this plan (workflow rule 2).
