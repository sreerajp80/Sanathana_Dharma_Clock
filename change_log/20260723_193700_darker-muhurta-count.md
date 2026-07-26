# Make the Muhūrta count text darker

Implements [plans/20260723_193500_darker-muhurta-count.md](../plans/20260723_193500_darker-muhurta-count.md).

## What changed

- `lib/widgets/dharma_dial_painter.dart` — `_paintMuhurtaName`:
  - The count line ("Muhūrta 15 / 30") now uses the dark `foreground` colour
    (same as the Muhūrta name) instead of the light `muted` colour, so it is
    easy to read on the cream face.
  - Size and weight are unchanged, so the name still stands out.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — all 115 tests pass.
