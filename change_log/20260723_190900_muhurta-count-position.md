# Move the Muhūrta count line above the central dot

Implements [plans/20260723_190500_muhurta-count-position.md](../plans/20260723_190500_muhurta-count-position.md).

## What changed

- `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName`:
  - Before, the count line ("Muhūrta 14 / 30") was painted below the dial
    centre, where the hands pivot. A hand often hid the first digit, so
    "14" read as "4".
  - Now the whole block sits just above the central dot: the count line at
    `center − 0.11 × radius` and the Muhūrta name at `center − 0.21 × radius`.
    Nothing is painted below the centre any more.
  - Updated the method's doc comment to match.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — all 115 tests pass.
