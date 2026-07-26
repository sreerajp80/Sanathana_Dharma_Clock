# 3D dial look + Muhūrta name in the dial centre

Implements [plans/20260721_213142_dial-3d-and-muhurta-name.md](../plans/20260721_213142_dial-3d-and-muhurta-name.md).

## What changed

### `lib/widgets/dharma_dial_painter.dart`

Gave the dial depth using plain canvas work (no new packages):

- A soft blurred drop shadow under the disc, offset down-right, so the dial lifts
  off the page.
- The face is now a radial gradient lit from the top-left instead of a flat
  background.
- The flat rim stroke became a bevelled bezel: a thick sweep-gradient ring
  (light at top-left, dark at bottom-right), a thin white catch-light on its
  inner edge, and a blurred inner shadow so the face looks recessed.
- Each hand now casts a blurred shadow, offset a little more for the faster
  hands so they read as sitting higher above the face.
- The flat centre dot became a gradient hub cap with a highlight, an edge ring,
  and its own small shadow.
- The sunrise dot and the "now" marker now ride the bezel (radius 0.955); the
  "now" bead got a gradient and a shadow to match. The small extra dot that sat
  outside the Muhūrta ring was dropped — the bezel now occupies that space, and
  the highlighted (thicker, accent-coloured) Muhūrta tick still marks the
  current Muhūrta.
- Tick rings, numbers, and hand lengths moved slightly inward to make room for
  the bezel.

New constructor parameters:

- `muhurtaName` — the current Muhūrta's name, painted below the centre cap
  (where classic faces carry the maker's name), with "Muhūrta N / 30" in
  smaller muted text under it. The text is drawn before the hands, so the hands
  sweep over it. Long names are shrunk to fit a max width of 0.6 × diameter so
  they never overflow.
- `faceColor` — the face disc colour; the face gradient is derived from it.

Both are included in `shouldRepaint`. All light/dark shades are computed from
the passed-in colours, so the painter still knows nothing about the theme class.

### `lib/screens/clock_screen.dart`

`_Dial` now passes `muhurtaName: MuhurtaNames.at(...)` and
`faceColor: AppTheme.chandanSurface` to the painter.

## Checks

- `dart format` — no changes needed.
- `flutter analyze` — no issues.
- `flutter test` — all 78 tests pass. No test changes were needed: the clock
  screen smoke test only checks the painter type, not its constructor.
