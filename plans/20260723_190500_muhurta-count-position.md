# Move the Muhūrta count line next to the Muhūrta name

**Status:** completed

## Issue

On the dial, the line "Muhūrta 14 / 30" is painted below the centre hub
(`center + 0.13 × radius`). The clock hands pivot at the centre, so a hand often
covers the first digit — "14" reads as "4".

## Files to change

- `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName` only.

## Fix

Place the whole block just above the central dot: the count line sits right
above the hub, and the name sits right above the count.

- Count centre: `center - Offset(0, radius * 0.11)` (just above the hub cap).
- Name centre: `center - Offset(0, radius * 0.21)` (just above the count).

Both lines then form one tight block above the hub, clear of the hand pivot.

## After

- Run `flutter analyze` and `flutter test`.
- Write the change log.
