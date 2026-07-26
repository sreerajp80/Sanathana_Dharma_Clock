# Paint the Muhūrta text on top of the hands

Implements [plans/20260723_192000_muhurta-text-on-top.md](../plans/20260723_192000_muhurta-text-on-top.md).

## What changed

- `lib/widgets/dharma_dial_painter.dart`:
  - In `paint`, moved the `_paintMuhurtaName(...)` call to after
    `_paintHands(...)`. The name and count now draw on top of the hands, so
    a hand pointing near the 0 mark can no longer hide the text.
  - Updated the `_paintMuhurtaName` doc comment to describe the new order.
  - No size, position, or math changes — draw order only.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — all 115 tests pass.
