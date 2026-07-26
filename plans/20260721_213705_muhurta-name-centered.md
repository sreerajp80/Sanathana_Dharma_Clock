# Centre the Muhūrta name on the dial and enlarge it

**Status:** completed

## Files to change

- `lib/widgets/dharma_dial_painter.dart` — text position and sizes only.

## The issue

After the 3D-dial change, the Muhūrta name sits 0.30 × radius *below* the centre,
near the "30" number — not in the centre as asked. The font is also too small.

## The plan

- Move the text block to the middle of the dial: the name line sits just **above**
  the centre hub and the "Muhūrta N / 30" line just **below** it, so the block is
  visually centred on the dial with the hub cap between the two lines. (Putting the
  name exactly on the centre point would hide its middle letters under the hub cap
  and the hands' pivot.)
- Raise the name font from 0.075 × radius to **0.11 × radius** (bold), and the
  count line from 0.055 to **0.065 × radius**.
- Keep the overflow guard: long names still shrink to fit 0.6 × diameter.
- Text stays painted before the hands, so the hands sweep over it.

## Checks

- `flutter analyze`, `flutter test`, `dart format` — all clean.
