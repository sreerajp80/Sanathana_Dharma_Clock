# 3D dial look + Muhūrta name in the dial centre

**Status:** completed

## Files to change

- `lib/widgets/dharma_dial_painter.dart` — all the drawing changes.
- `lib/screens/clock_screen.dart` — pass the current Muhūrta name into the painter.
- `test/widgets/` — update/add a smoke test if the painter's constructor changes.

## The issue

1. The dial is flat: plain stroke circles and lines with no depth. The user wants a
   more 3D look.
2. The current Muhūrta name is only shown in the text readout below the dial. The user
   wants it shown in the centre of the dial itself.

## The plan

### 1. 3D face (all inside `DharmaDialPainter`, pure canvas — no new packages)

- **Face disc with a radial gradient.** Fill the dial with a subtle radial gradient
  (lighter chandan at the top-left "light source", slightly deeper toward the rim).
  Colours are derived from the passed-in colours plus a new `faceColor` parameter
  (chandan surface), so the painter still knows nothing about the theme class.
- **Drop shadow under the dial.** A soft blurred dark circle offset slightly down-right
  behind the face (using `MaskFilter.blur`), so the dial appears lifted off the page.
- **Bevelled rim.** Replace the single flat rim stroke with a `SweepGradient`-based ring
  (light at top-left, dark at bottom-right) drawn as a thick stroke, plus a thin inner
  highlight ring. This reads as a raised metal/wood bezel.
- **Inner shadow at the rim.** A thin blurred dark ring just inside the bezel so the
  face looks slightly recessed inside it.
- **Hands with shadows.** Draw each hand twice: first a blurred, semi-transparent dark
  copy offset a few pixels down-right, then the real hand on top. Taller hands
  (the fast hand) get a slightly bigger offset, as if higher above the face.
- **Centre cap with depth.** Replace the flat centre dot with a small radial-gradient
  cap (highlight at top-left, darker edge) and a tiny rim, like a real clock's hub.
- All shadow/highlight colours are computed from the existing passed-in colours
  (via `Color.withValues` / lighten-darken helpers), so contrast rules stay intact.

### 2. Muhūrta name in the centre

- Add a `muhurtaName` string parameter to `DharmaDialPainter` (and include it in
  `shouldRepaint`). `ClockScreen`'s `_Dial` passes `MuhurtaNames.at(d.muhurta)` —
  the painter stays dumb about the name table.
- Paint the name **below the centre cap** (around 0.30–0.38 of the radius down from
  centre), where classic clock faces put their maker's name. Centred, small
  (~0.07 × radius font), in the `foreground` colour, with the Muhūrta number under it
  in the `muted` colour (e.g. "Muhūrta 14 / 30" style, small).
- Draw the text **before the hands**, so hands sweep over it like a real clock.
- Long names ("Dyumadgadyuti", "Ahir Budhnya") are laid out with a max width of about
  0.6 × diameter and scaled down if needed, so they never overflow the dial.

### 3. Checks

- `flutter analyze` clean, `dart format .`.
- `flutter test` — update the widget smoke test for the new constructor parameter.
- Visual check on the running app.

## Out of scope

- No change to the clock math, providers, models, or the legend.
- No new packages.
