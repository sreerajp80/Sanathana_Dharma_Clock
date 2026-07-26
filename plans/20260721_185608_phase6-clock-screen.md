# Phase 6 — UI: clock screen

**Status:** completed

Implements Phase 6 of [../docs/implementation_plan.md](../docs/implementation_plan.md):
the main analog dial and digital readout, the app theme, and go_router navigation.

## The issue / what is missing

Phases 1–5 built the whole non-UI stack: models, solar/time math, location, and
the Riverpod state layer (`clockProvider` emits a `ClockSnapshot` once per
second). There is still **no real UI** — `main.dart` shows a Phase 1 placeholder
screen, there is no theme, no dial, and no router. Phase 6 fills the main screen.

## Scope (Phase 6 only)

Four things from the plan:

1. `theme/app_theme.dart` — one vermillion-on-chandan `ThemeData`, contrast
   checked for WCAG AA.
2. `widgets/dharma_dial_painter.dart` — the analog face `CustomPainter`.
3. `screens/clock_screen.dart` — the dial plus the digital readout, with a
   screen-reader label.
4. `go_router` with routes `/`, `/panchang`, `/settings`, `/about`.

Out of scope (later phases): the real Settings cards and About screen (Phase 7),
the Panchang tab content (Phase 8), and widget tests (Phase 9). For this phase
the three non-clock routes get **minimal placeholder screens** only, so
navigation works.

## Design notes

**Theme (`app_theme.dart`).** A single light `ThemeData` (Material 3).
- Background / surface: chandan `#F1E4C3`.
- Primary / accent: vermillion. The pure `#E34234` on chandan measures only about
  3.0:1 contrast — below the 4.5:1 WCAG AA bar for normal text. So use a darker
  vermillion (`#B32D1F`, ≈ 5.1:1 on chandan) for text/`onSurface` and the pure
  `#E34234` only for large dial strokes and highlights where AA large (3:1) is
  enough. Constants live in the theme file as named `Color`s.
- Build the scheme with `ColorScheme.fromSeed` then override the key roles so the
  two brand colours are exact, and set `scaffoldBackgroundColor` to chandan.

**Muhūrta names.** The readout and the outer ring show the current Muhūrta's
traditional name (idea doc §5, e.g. *Brahma Muhūrta* near sunrise). The
`DharmaTime` model does not carry a name, so add a small data table
`core/constants/muhurta_names.dart` — a `const List<String>` of the 30 day-Muhūrta
names indexed 0–29, with a safe `muhurtaName(int)` lookup that clamps. This is a
pure constant table (no logic), so it belongs in `core/constants`, not a service.

**Dial painter (`dharma_dial_painter.dart`).** A `CustomPainter` that takes a
`DharmaTime` and the theme colours (passed in — the painter knows no `Theme`
lookups beyond what it is given). Drawn outer → inner:
- outer ring of 30 Muhūrta ticks, the current one highlighted;
- 60 Ghaṭikā ticks on the main dial (every 5th longer);
- three hands — Ghaṭikā (slow), Vināḍī (sweeps once per Ghaṭikā), and a smooth
  Prāṇa/fraction fast hand;
- a rim "now" marker driven by `dharma.fraction`, with sunrise fixed at the top.
- `shouldRepaint` compares the `DharmaTime` so it only repaints when the reading
  changes (once per second). Keep it cheap — no per-frame allocation of large
  objects where avoidable.

**Clock screen (`clock_screen.dart`).** A `ConsumerWidget` that watches
`clockProvider`. Shows the dial and the digital readout, honouring
`displayModeProvider` (analog only / digital only / both). The readout follows
idea doc §5:
```
Ghaṭikā 24 : Vināḍī 18 : Prāṇa 3
Muhūrta 12 / 30   —   Brahma Muhūrta
Civil 09:37:12    Sunrise 06:11
```
Civil time and sunrise are formatted with a tiny local helper (no `intl`
package — keep deps unchanged). An `AppBar` action opens Settings. The whole
clock is wrapped in a `Semantics` widget whose label is the current reading, for
screen readers. A small footer shows the anchor source (live / saved / no
location fallback) using `ClockSnapshot.source` / `isPolar`, so the user knows
when the midnight fallback is in effect.

**Router (`core/router.dart`).** A `GoRouter` with the four routes. `/` →
`ClockScreen`. The other three get placeholder screens in `lib/screens/`
(`panchang_screen.dart`, `settings_screen.dart`, `about_screen.dart`) — a simple
scaffold with a title and a "coming in a later phase" note — so links resolve
now and Phases 7–8 replace the bodies. Expose the router as a Riverpod provider
(`goRouterProvider`) or a top-level final; a plain top-level `final router` is
simplest and matches architecture §13.

**`main.dart`.** Replace the placeholder home with `MaterialApp.router`, wiring
`theme: AppTheme.light`, `routerConfig: router`, and keeping the existing
`title`, `debugShowCheckedModeBanner: false`, and the global error handlers.
Remove the `_ScaffoldPlaceholderScreen`.

## Files to change / add

**Add**
- `lib/theme/app_theme.dart` — `AppTheme.light` + brand colour constants.
- `lib/core/constants/muhurta_names.dart` — 30 Muhūrta names + safe lookup.
- `lib/widgets/dharma_dial_painter.dart` — `DharmaDialPainter` CustomPainter.
- `lib/screens/clock_screen.dart` — the main screen.
- `lib/screens/panchang_screen.dart` — placeholder (Phase 8 fills it).
- `lib/screens/settings_screen.dart` — placeholder (Phase 7 fills it).
- `lib/screens/about_screen.dart` — placeholder (Phase 7 fills it).
- `lib/core/router.dart` — the `GoRouter` with the four routes.

**Change**
- `lib/main.dart` — use `MaterialApp.router` with the theme and router; drop the
  placeholder screen.

**No dependency changes.** No new packages (offline / open-source rules hold).

## Verification

- `flutter analyze` clean (zero warnings).
- `flutter test` still green (48 tests; no test changes this phase — widget tests
  are Phase 9).
- `dart format .` applied.
- `flutter run --flavor dev` shows the ticking dial and readout (manual check;
  note it in the change log).

## After implementing

- Update [../docs/implementation_progress.md](../docs/implementation_progress.md):
  tick the Phase 6 items, flip the status row to Done, add a dated note.
- Write the change log in `change_log/`.
