# Paint the Muhūrta text on top of the hands

**Status:** completed

## Issue

The dial paints the Muhūrta name and count first, then the hands over them.
When a hand points near the 0 mark (straight up), it crosses the text block —
for example around the start of the dharma day, when the Ghaṭikā hand lies
right across the name and count.

## Files to change

- `lib/widgets/dharma_dial_painter.dart` — the `paint` method's call order and
  the doc comments that describe it.

## Fix

Reorder the painting so the text is always on top:

1. In `paint`, move the `_paintMuhurtaName(...)` call (line 108) to after
   `_paintHands(...)` (line 109). The centre cap is drawn inside
   `_paintHands` and sits at the pivot, below the text block, so it is not
   affected.
2. Update the doc comments that say the text is "painted before the hands so
   they sweep over it" to say the text is painted after the hands so it is
   always readable.

No math, layout, or size changes — only the draw order.

## After

- Run `flutter analyze` and `flutter test`.
- Write the change log.
