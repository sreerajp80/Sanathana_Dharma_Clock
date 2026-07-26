# Darken the centre text shades (name and count)

**Status:** completed

## Issue

The previous change swapped the count's colour to the theme foreground, but
the user wanted the same colours only darker: the count line close to black,
and the Muhūrta name a darker shade of its red-brown. Darker text stays
readable when a hand passes through it.

## Files to change

- `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName` only.

## Fix

The painter already derives light/dark shades from the passed-in colours, so
darken locally with `Color.lerp` toward black:

- Name: `Color.lerp(foreground, Colors.black, 0.35)` — the same red-brown,
  clearly darker.
- Count: `Color.lerp(foreground, Colors.black, 0.75)` — near black with a
  hint of the theme tone.

No layout, size, or draw-order changes.

## After

- Run `flutter analyze` and `flutter test`.
- Write the change log.
