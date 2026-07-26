# Move clock up + make the dial arc colours easy to tell apart

**Status:** completed

## Issue

1. On the Clock tab there is a large empty gap between the app bar and the
   location header. The clock content is vertically centred, so on a tall
   screen everything sits low. The user wants the clock moved up.
2. The four window arc colours on the dial are hard to tell apart:
   - Abhijit Muhūrta (deep green `0xFF2E7D32`) vs Gulika Kālam
     (slate blue-grey `0xFF546E7A`) look alike as thin arcs.
   - Rāhu Kālam (deep red `0xFF8E1600`) vs Yamagaṇḍa (burnt orange
     `0xFFE65100`) also look alike, and the red blends with the vermillion
     dial rim.

## Files to change

| File | Change |
|------|--------|
| `lib/screens/clock_screen.dart` | Align the column to the top instead of centring it, so the clock moves up. |
| `lib/theme/app_theme.dart` | New, clearly separated arc colours (see below). |

No other file needs a change — the dial painter, the arc legend, and the
Muhurta tab all read colours through `windowColor()` / `AppTheme`, so they
update together automatically.

## Fix

### 1. Move the clock up

In `ClockScreen`, change the column's `mainAxisAlignment` from `center` to
`start`. The existing `padding: EdgeInsets.all(24)` keeps a small breathing
gap under the app bar. Nothing else moves.

### 2. New arc colours

Pick four colours far apart in hue, all dark enough to read on the cream
dial face:

| Window | Now | New | Why |
|--------|-----|-----|-----|
| Abhijit Muhūrta | deep green `0xFF2E7D32` | keep `0xFF2E7D32` | Green = auspicious; stays. |
| Gulika Kālam | slate blue-grey `0xFF546E7A` | strong blue `0xFF1565C0` | Clearly blue now — no longer reads as a dull green/grey next to Abhijit. |
| Rāhu Kālam | deep red `0xFF8E1600` | deep purple `0xFF6A1B9A` | Moves it away from both Yamagaṇḍa's orange and the vermillion rim. |
| Yamagaṇḍa | burnt orange `0xFFE65100` | keep `0xFFE65100` | Orange stays; it is distinct once Rāhu is purple. |

Result: green / blue / purple / orange — the four most separable hues on
the warm dial background. Doc comments in `app_theme.dart` updated to match.

## Tests

- `flutter analyze` and `flutter test` after the change (no test asserts
  these colour values or the alignment, so no test edits expected).
