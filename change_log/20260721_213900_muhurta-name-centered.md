# Centre the Muhūrta name on the dial and enlarge it

Implements [plans/20260721_213705_muhurta-name-centered.md](../plans/20260721_213705_muhurta-name-centered.md).

## What changed

### `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName`

- Moved the text block to the middle of the dial: the name line now sits
  0.13 × radius **above** the centre hub, and the "Muhūrta N / 30" line
  0.13 × radius **below** it, so the block is visually centred with the hub cap
  between the two lines. (Before, both lines sat 0.30 × radius below centre,
  near the "30" number.)
- Raised the name font from 0.075 to 0.11 × radius, and the count line from
  0.055 to 0.065 × radius.
- Kept the overflow guard (long names shrink to fit 0.6 × diameter) and the
  paint order (text before hands, so the hands sweep over it).

## Checks

- `dart format` — no changes needed.
- `flutter analyze` — no issues.
- `flutter test` — all 78 tests pass.
