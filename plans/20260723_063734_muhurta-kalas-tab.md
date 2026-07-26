# Plan: "Muhurta & Kalas" tab

**Status:** completed

## What the user asked for

A new bottom tab called **Muhurta & Kalas**. For today it shows, in civil time:

1. **All 30 muhūrtas of the day** — start and end of each, with its traditional
   name (the names already exist in `MuhurtaNames`). The current muhūrta is
   highlighted. This uses the app's own elastic day model: each muhūrta is
   `span / 30` of the sunrise-to-sunrise day, exactly matching what the clock and
   dial already show. **Brahma Muhūrta** appears naturally in this list (index 28,
   the pre-dawn one) — it gets an "auspicious" tag so people who want to wake for
   it can find it fast.
2. **Special windows** (these need sunset, computed from the daytime
   sunrise → sunset):
   - **Abhijit Muhūrta** — auspicious. The 8th of the 15 day-muhūrtas:
     `[sunrise + 7·D/15, sunrise + 8·D/15]` where `D = sunset − sunrise`. Shown
     as its own entry because it is defined on the *daytime*, not the 30-slice
     ahorātra, so its times differ slightly from the list above.
   - **Rāhu Kālam**, **Yamagaṇḍa**, **Gulika Kālam** — inauspicious. Each is
     1/8th of the daytime; which eighth depends on the weekday.

3. **Colored arcs on the clock dial** — Rāhu Kālam, Yamagaṇḍa, and Gulika drawn
   as red-toned segments, and Abhijit as a green/gold segment, on the dial face
   itself, so the windows are visible on the clock at a glance.

## The issue

The app has no sunset math and no notion of these windows. `SolarCalculator` only
computes sunrise. There are only two tabs (Clock, Panchang).

## The math (pure arithmetic, offline)

**The 30 muhūrtas:** muhūrta `i` (0–29) runs
`[sunrise + i·span/30, sunrise + (i+1)·span/30]`, where `sunrise` and `span` come
from the already-existing `SolarCalculator.resolveDay` (the same values the clock
ticks on). Names come from `MuhurtaNames.at(i)`. No new solar math needed here.

**The kālas:** let `D = sunset − sunrise` (today's daytime). Split `D` into 8
equal parts, numbered 1–8 from sunrise. The weekday decides which part each kāla
takes (standard tables):

| Weekday | Rāhu | Yamagaṇḍa | Gulika |
|---------|------|-----------|--------|
| Sunday | 8 | 5 | 7 |
| Monday | 2 | 4 | 6 |
| Tuesday | 7 | 3 | 5 |
| Wednesday | 5 | 2 | 4 |
| Thursday | 6 | 1 | 3 |
| Friday | 4 | 7 | 2 |
| Saturday | 3 | 6 | 1 |

- **Abhijit**: `[sunrise + 7·D/15, sunrise + 8·D/15]` (the 8th of 15 day-muhūrtas).
- Weekday = the local calendar weekday of the anchoring sunrise.

**The dial arcs:** the dial already maps day-fraction `f` (0..1 from sunrise) to
angle `2π·f` clockwise from the top. Each window becomes an arc from
`fStart = (start − sunrise) / span` to `fEnd = (end − sunrise) / span`. The
screen computes these fractions; the painter just receives a list of
`(startFraction, endFraction, color)` and strokes each arc on a thin band just
inside the Muhūrta ring. The painter stays a dumb renderer (architecture §9) —
it never sees `DateTime`s or the kāla rules. No arcs are passed on polar /
no-sunset days, so the dial simply draws none.

**Fallbacks (hard rule 4 — never crash):**
- No location / polar day: the 30-muhūrta list still works (it only needs the
  clock's own fallback day: midnight anchor, fixed span) but is labelled
  "approximate — no sunrise anchor".
- No sunset (polar): the kāla + Abhijit section shows a friendly message
  ("These windows need a sunrise and sunset…") instead of times. No fake windows
  are invented.

## Files to change

| File | Change |
|------|--------|
| `lib/services/solar_calculator.dart` | Add `sunsetUtc(dateUtc, lat, lon)` — same NOAA math, mirror of `sunriseUtc` (`720 − 4·(longitude − haDeg) − eqOfTime`). Small private refactor so sunrise/sunset share the common terms. |
| `lib/models/muhurta_window.dart` | **New.** Immutable model: `name`, `kind` (auspicious / inauspicious), `start`, `end` (UTC `DateTime`s). |
| `lib/services/muhurta_kala_calculator.dart` | **New.** Pure service with two jobs: (a) given the day's anchor sunrise + span, return the 30 muhūrta windows with their names; (b) given sunrise + sunset + weekday, return Abhijit and the three kāla windows. Holds the weekday tables. No plugins, no UI. |
| `lib/providers/muhurta_providers.dart` | **New.** A provider that takes the effective location + the clock's current day, calls `SolarCalculator` and `MuhurtaKalaCalculator`, and exposes the day's muhūrta list and kāla windows (kālas `null` when no sunset). Recomputed when the location changes or the date rolls (watches the clock's day, not every tick). |
| `lib/screens/muhurta_screen.dart` | **New.** The tab UI: a "Kālas & special windows" section on top (Abhijit, Rāhu, Yamagaṇḍa, Gulika — auspicious/inauspicious tags), then the full 30-row muhūrta list (name + start–end). The row containing "now" is highlighted, and the list auto-scrolls to it on open. Fallback messages as above. |
| `lib/core/router.dart` | Add a third shell branch `/muhurta` → `MuhurtaScreen`. |
| `lib/screens/home_shell.dart` | Add the third `NavigationDestination` ("Muhurta"). |
| `lib/widgets/dharma_dial_painter.dart` | Add an optional `List<DialArc>` input (`startFraction`, `endFraction`, `color` — a tiny value class next to the painter). Paint the arcs as a thin stroked band just inside the Muhūrta ring, under the ticks and hands. Include arcs in `shouldRepaint`. |
| `lib/screens/clock_screen.dart` | Watch the new muhūrta provider, convert the four special windows (Abhijit + three kālas) to day fractions, pick their colours from the theme, and pass them to the painter. Add a small legend line under the dial (colour dot + name) so the arcs are readable. |
| `test/services/muhurta_kala_calculator_test.dart` | **New.** Table test: fixed sunrise/sunset (e.g. 06:00–18:00) → exact expected kāla windows for each weekday; Abhijit midpoint; 30-muhūrta list covers the full span with no gaps and matches `MuhurtaNames` order. |
| `test/services/solar_calculator_test.dart` | Add sunset cases (known lat/lon/date → expected sunset; polar date → `null`). |
| `docs/architecture.md` | Add the new service, model, provider, screen, and the third tab to the relevant sections. |

## Order of work

1. `sunsetUtc` in `SolarCalculator` + tests.
2. `MuhurtaWindow` model + `MuhurtaKalaCalculator` + tests.
3. Provider.
4. Screen + router + shell tab.
5. Dial arcs: painter change + clock-screen wiring + legend.
6. `flutter analyze` + `flutter test` clean; update `docs/architecture.md`; write the change log.

## Out of scope

- Any Panchang-tab change (it stays untouched).
- Other muhūrtas/kālas (Dur Muhūrta, Varjyam, etc.) — can be added later.
