# Change log: "Muhurta & Kalas" tab + dial arcs

**Implements plan:** [plans/20260723_063734_muhurta-kalas-tab.md](../plans/20260723_063734_muhurta-kalas-tab.md)

## What was added

A new bottom tab **Muhurta & Kalas** and colored window arcs on the clock dial.

### New files

| File | What it is |
|------|-----------|
| `lib/models/muhurta_window.dart` | Immutable window: name, kind (auspicious / inauspicious / neutral), UTC start/end, and a `contains(instant)` check. |
| `lib/services/muhurta_kala_calculator.dart` | Pure service. `muhurtaList` splits the elastic sunrise-to-sunrise day into the 30 named muhūrtas (names from `MuhurtaNames`; Brahma Muhūrta tagged auspicious). `kalaWindows` splits the sunrise→sunset daytime into Abhijit Muhūrta (8th of 15) and the three kālas (Rāhu, Yamagaṇḍa, Gulika) from the standard weekday tables. Returns an empty list instead of fake windows when the daytime is not positive. |
| `lib/providers/muhurta_providers.dart` | `muhurtaDayProvider` derives the day's windows from the clock's anchor day + effective location. Watches only the anchor sunrise/span via `select`, so it recomputes once per day roll or location change — never per second. Kālas are empty when there is no location or no sunset (polar). |
| `lib/screens/muhurta_screen.dart` | The tab: a "Kālas & special windows" section (cards with colour dot, tag, start–end, "Now" chip) and the full 30-muhūrta list (highlighted current row, auto-scrolled into view on open; minute-precision highlight so it does not rebuild every second). Friendly fallback messages when no sunset / no anchor. |
| `lib/widgets/window_colors.dart` | Shared window → colour mapping so the tab and the dial always agree. |
| `test/services/muhurta_kala_calculator_test.dart` | 13 tests: the 30 windows tile the span with no gaps; Brahma tag; fixed-day fallback; all 7 weekday kāla tables; Abhijit 11:36–12:24 on a 06–18 day; inverted daytime returns nothing; `contains` bounds. |

### Changed files

| File | Change |
|------|--------|
| `lib/services/solar_calculator.dart` | Added `sunsetUtc`. Sunrise and sunset now share one private NOAA computation (`_solarEventUtc`); they differ only in the sign of the hour angle. |
| `test/services/solar_calculator_test.dart` | Sunset reference tests (London solstice ≈ 20:21 UTC, equator equinox ≈ 18:00), polar null, and sunset-after-sunrise. |
| `lib/providers/service_providers.dart` | Registered `muhurtaKalaCalculatorProvider`. |
| `lib/core/router.dart` | Third shell branch `/muhurta`. |
| `lib/screens/home_shell.dart` | Third bottom-nav destination "Muhurta". |
| `lib/theme/app_theme.dart` | Window colours: green (auspicious), deep red (Rāhu), burnt orange (Yamagaṇḍa), slate blue-grey (Gulika). |
| `lib/widgets/dharma_dial_painter.dart` | New `DialArc` value class and optional `arcs` input; arcs are stroked on a thin band just inside the Muhūrta ring, under ticks and hands. `shouldRepaint` compares the arc list. The painter still never sees times or kāla rules. |
| `lib/screens/clock_screen.dart` | The dial widget converts the special windows into day-fraction arcs and passes them to the painter; a small colour-dot legend appears above the hand legend when arcs are shown. |
| `docs/architecture.md` | New model, service, screen, and the `/muhurta` route added to §4, §11, §13. |

## Checks

- `flutter analyze` — no issues.
- `flutter test` — all 83 tests pass.
- `dart format .` — applied.

## Notes

- Everything is pure on-device arithmetic — still fully offline.
- Hard rule 4 holds: no location / polar day → the muhūrta list uses the clock's
  own fallback day and is labelled approximate; the kāla section shows a message
  and the dial shows no arcs. Nothing crashes and no fake times are shown.
- Abhijit is defined on the daytime (D/15), so its times differ slightly from
  the 8th row of the 30-slice ahorātra list — this is by design and noted in the
  plan.
