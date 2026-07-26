# Make the Muhūrta count text darker

**Status:** completed

## Issue

On the dial, the count line ("Muhūrta 15 / 30") is painted in the theme's
muted colour. It looks too light against the cream face and is hard to read.

## Files to change

- `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName` only.

## Fix

Paint the count line with the same `foreground` colour used for the Muhūrta
name (the dark red-brown), instead of `muted`. Keep its smaller size and
weight so the name still stands out as the main line.

## After

- Run `flutter analyze` and `flutter test`.
- Write the change log.
