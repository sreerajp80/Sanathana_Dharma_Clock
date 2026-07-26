# Change log — Dial hands now move and the dial shows numbers

Implements plan
[plans/20260721_201759_dial-hands-and-numbers.md](../plans/20260721_201759_dial-hands-and-numbers.md).

## Why

On the clock screen the hands looked frozen and the dial had no numbers:
- The Ghaṭikā hand jumped once every ~24 min, the Vināḍī hand once every ~24 s, and the
  "fast" hand was tied to whole-day progress (one turn per 24 h), so none of them
  appeared to move.
- The painter drew only tick marks, so the rings had no labels.

## What changed

**[lib/models/dharma_time.dart](../lib/models/dharma_time.dart)**
- Added two fields: `vinadiFraction` (0.0–1.0 progress through the current Ghaṭikā) and
  `pranaFraction` (0.0–1.0 progress through the current Vināḍī).
- Updated the constructor, `operator ==`, and `hashCode` to include them.

**[lib/services/time_calculator.dart](../lib/services/time_calculator.dart)**
- `toDharmaTime` now computes `vinadiFraction = afterGhatika / ghatikaLen` and
  `pranaFraction = afterVinadi / vinadiLen` (both clamped to 0..1) and passes them into
  `DharmaTime`. The reverse mapping (`toCivilTime`) is unchanged.

**[lib/widgets/dharma_dial_painter.dart](../lib/widgets/dharma_dial_painter.dart)**
- Rewired the three hands to smooth, continuous angles:
  - Ghaṭikā (slow "hour" hand) → `2π · fraction`.
  - Vināḍī ("minute" hand) → `2π · vinadiFraction` (one turn per Ghaṭikā, ~24 min).
  - Fast ("second" hand) → `2π · pranaFraction` (one turn per Vināḍī, ~24 s), so it now
    visibly moves every tick.
- Added `_paintGhatikaNumbers`: draws Ghaṭikā labels at every 5th tick (0, 5, 10 … 55)
  just inside the Ghaṭikā ring, with `0` at the top (sunrise) growing clockwise, using
  `TextPainter`.
- The rim "now" marker still uses `fraction` (unchanged — it marks the whole-day
  position).

**[test/services/time_calculator_test.dart](../test/services/time_calculator_test.dart)**
- Added a group asserting the new fractions: both are 0 at sunrise, `vinadiFraction` is
  0.5 half-way through a Ghaṭikā, and `pranaFraction` is 0.5 half-way through a Vināḍī.

## Checks

- `dart format .` — no files changed.
- `flutter analyze` — no issues.
- `flutter test` — all 73 tests pass.

## Not done (out of scope)

- The Muhūrta ring is still unlabelled (kept clean to avoid clutter).
- No manual on-device run was performed in this environment; the motion and numbers were
  verified through the code and unit tests.
