# Moved the clock up and separated the dial arc colours

Implements: `plans/20260723_071550_clock-up-and-arc-colors.md`

## What changed

1. `lib/screens/clock_screen.dart` — the clock column now aligns to the top
   (`MainAxisAlignment.start` instead of `center`). The big empty gap between
   the app bar and the location header is gone; the existing 24 px screen
   padding keeps a small breathing space.

2. `lib/theme/app_theme.dart` — new window arc colours so the four arcs are
   easy to tell apart:
   - Rāhu Kālam: deep red `0xFF8E1600` → deep purple `0xFF6A1B9A`.
   - Gulika Kālam: slate blue-grey `0xFF546E7A` → strong blue `0xFF1565C0`.
   - Abhijit Muhūrta (deep green) and Yamagaṇḍa (burnt orange) unchanged.

   The dial arcs, the legend dots, and the Muhurta & Kalas tab tags all share
   one colour map (`windowColor()`), so they all updated together.

## Checks

- `flutter analyze`: no issues.
- `flutter test`: all 83 tests passed.
