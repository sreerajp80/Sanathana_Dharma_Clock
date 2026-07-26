# Plan — Make the dial hands move and add numbers to the dial

**Status:** completed

## The issue

Two problems on the clock screen ([lib/screens/clock_screen.dart](../lib/screens/clock_screen.dart),
[lib/widgets/dharma_dial_painter.dart](../lib/widgets/dharma_dial_painter.dart)):

1. **Hands look frozen.** The hands repaint every second, but the numbers behind them
   barely change, so nothing visibly moves.
   - The **Ghaṭikā** hand is stepped to a whole Ghaṭikā, so it only jumps once every
     ~24 minutes.
   - The **Vināḍī** hand uses the *integer* `dharma.vinadi`, so it jumps once every
     ~24 seconds instead of sweeping.
   - The **fast hand** (meant to be the smooth "second hand") is driven by
     `dharma.fraction`, which is progress through the **whole day**. That is one full
     turn per 24 hours — about 0.004° per second, far too slow to see. The intended
     "fast" hand is wired to the slowest value in the app.

2. **No numbers on the dial.** The painter draws only tick marks and never draws any
   text, so the rings of ticks have no labels and are hard to read.

## The fix (high level)

- Give each hand a smooth, continuously-changing angle, matching a normal analog clock:
  - **Ghaṭikā** hand → smooth over the whole day (the slow "hour" hand).
  - **Vināḍī** hand → smooth, one turn per Ghaṭikā (~24 min) — the "minute" hand.
  - **Fast (Prāṇa)** hand → smooth, one turn per Vināḍī (~24 s) — the "second" hand,
    which will clearly move every tick.
- Keep the unit math in the calculator, not the widget (architecture rule: widgets must
  not know the formula). To do that, add two continuous progress values to `DharmaTime`
  and compute them in `TimeCalculator`. The painter just maps each value to an angle.
- Add **Ghaṭikā number labels** at every 5th tick (0, 5, 10, … 55) just inside the
  Ghaṭikā ring, with `0` at the top (sunrise) going clockwise — like the numbers on a
  normal clock. (Not labelling all 30 Muhūrta, to avoid clutter.)

## Files to change

| File | Change |
|------|--------|
| [lib/models/dharma_time.dart](../lib/models/dharma_time.dart) | Add two fields: `vinadiFraction` (0..1 through the current Ghaṭikā) and `pranaFraction` (0..1 through the current Vināḍī). Update the constructor, `==`, `hashCode`, and doc comments. |
| [lib/services/time_calculator.dart](../lib/services/time_calculator.dart) | Compute the two new fractions from values already calculated (`afterGhatika / ghatikaLen` and `afterVinadi / vinadiLen`) and pass them into `DharmaTime`. |
| [lib/widgets/dharma_dial_painter.dart](../lib/widgets/dharma_dial_painter.dart) | Rewire the three hands to use continuous angles (Ghaṭikā → `fraction`, Vināḍī → `vinadiFraction`, fast → `pranaFraction`). Add a new step that paints Ghaṭikā numbers at every 5th tick using `TextPainter`. |
| [test/services/time_calculator_test.dart](../test/services/time_calculator_test.dart) | Add assertions for the two new fractions at known instants (e.g. at sunrise both are 0.0; mid-Ghaṭikā and mid-Vināḍī give expected values). Existing tests keep working — they call `toDharmaTime`, not the constructor. |

No other file constructs `DharmaTime` directly (only `TimeCalculator` does), so adding
required fields does not break other code or tests.

## Detail of the changes

### 1. `DharmaTime` (model)
Add:
- `final double vinadiFraction;` — progress 0.0–1.0 through the current Ghaṭikā. Drives
  the Vināḍī hand (one full turn per Ghaṭikā).
- `final double pranaFraction;` — progress 0.0–1.0 through the current Vināḍī. Drives the
  fast hand (one full turn per Vināḍī, ~24 s).

Both are added to the constructor (as `required`), to `operator ==`, and to `hashCode`.

### 2. `TimeCalculator.toDharmaTime`
It already computes `afterGhatika` (micros into the current Ghaṭikā) and `afterVinadi`
(micros into the current Vināḍī), plus `ghatikaLen` and `vinadiLen`. Add:
```dart
final vinadiFraction = (afterGhatika / ghatikaLen).clamp(0.0, 1.0);
final pranaFraction  = (afterVinadi / vinadiLen).clamp(0.0, 1.0);
```
and pass them into the returned `DharmaTime`. The existing reverse mapping
(`toCivilTime`) is unchanged.

### 3. `DharmaDialPainter`
- **Ghaṭikā hand** — angle `2π · dharma.fraction` (smooth whole-day creep), keep it the
  thick, shorter hand.
- **Vināḍī hand** — angle `2π · dharma.vinadiFraction` (was `2π · vinadi/60`).
- **Fast hand** — angle `2π · dharma.pranaFraction` (was `2π · dharma.fraction`).
- The rim "now" marker keeps using `dharma.fraction` (correct — it marks the position in
  the whole day).
- **New `_paintGhatikaNumbers` step**, called from `paint`. For `i` in 0, 5, 10 … 55:
  compute the tick angle, place a `TextPainter` (digits as text) at a radius just inside
  the Ghaṭikā ticks, centred on the point, coloured with `foreground`, font size
  ~`radius · 0.08`. `0` sits at the top (sunrise).

### 4. Tests
Add to `time_calculator_test.dart`:
- At sunrise: `vinadiFraction == 0.0` and `pranaFraction == 0.0`.
- At a chosen instant mid-Ghaṭikā / mid-Vināḍī: the fractions are close to the expected
  value (using a tolerance for the elastic span).

## Checks after the change
- `dart format .`
- `flutter analyze` — must be clean.
- `flutter test` — all pass.
- Manual run (`flutter run --flavor dev`): the fast hand visibly ticks each second, the
  Vināḍī hand creeps, and Ghaṭikā numbers show on the dial.

## Out of scope
- No change to the digital readout, colours, layout, or the solar/sunrise math.
- Not labelling the Muhūrta ring (kept clean); can be a later change if wanted.
