# Darken the centre text shades (name and count)

Implements [plans/20260723_194500_darken-center-text-shades.md](../plans/20260723_194500_darken-center-text-shades.md).

## What changed

- `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName`:
  - The Muhūrta name now paints in `Color.lerp(foreground, black, 0.35)` —
    the same red-brown, clearly darker.
  - The count line now paints in `Color.lerp(foreground, black, 0.75)` —
    near black.
  - This replaces the earlier plain-foreground count colour. Darker text
    stays readable when a hand passes through it.
  - No layout, size, or draw-order changes.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — all 115 tests pass.
