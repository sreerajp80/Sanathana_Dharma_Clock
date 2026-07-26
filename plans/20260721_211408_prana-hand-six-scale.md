# Plan — Make the Prāṇa fast hand read as 6 Prāṇa (≈ 24 civil seconds)

**Status:** approval_pending

## My understanding of the request

"In the Civil clock 24 seconds should be shown at 6 Prāṇa."

I read this as: the fast **Prāṇa hand** on the dial should be readable so that
**one full indication = 6 Prāṇa = about 24 civil seconds**. Today the fast hand
sweeps the main **0–60 numbered face** once per Vināḍī, so when the digital
reading says *Prāṇa 5* the hand sits near the **"50–55" mark**. Both are correct,
but they *look* like they disagree, because a 6-count value (Prāṇa 0–5) is being
shown against a 60-count scale.

> Note on timing: the day is **elastic** (sunrise to sunrise), so one Vināḍī is
> *about* 24 s — exactly 24 s only when the day span is exactly 86,400 s, a little
> more or less in other seasons. This matches the design doc
> (`docs/Sanathana_Dharma_Clock-Idea.md` §2). The plan keeps this elastic
> behaviour: the fast hand completes 6 Prāṇa per Vināḍī, which is ~24 civil
> seconds on a normal day. If you instead want the fast hand pinned to **exactly**
> 24 civil seconds regardless of season, say so — that is a different design and I
> will adjust the plan.

## The issue

- `lib/widgets/dharma_dial_painter.dart` draws the fast hand with
  `fastAngle = 2π · pranaFraction` on top of the same face that is numbered
  0–60 for Ghaṭikā. There is **no 6-mark Prāṇa scale**, so the hand cannot be
  read as "Prāṇa 0–5".
- Result: the fast hand and the digital *Prāṇa* value look like they do not match
  (off by a factor of 10 on the 0–60 numbers).

The underlying math is already correct and stays unchanged
(`lib/services/time_calculator.dart`): 1 Vināḍī = 6 Prāṇa, 1 Prāṇa = span/21600
(≈ 4 s). No change to the unit definitions.

## The fix

Add a small dedicated **Prāṇa sub-dial** for the fast hand, like the little
seconds sub-dial on a chronograph watch, so 6 Prāṇa reads clearly:

1. Draw a small circle inside the main face (centred, in the lower half so it does
   not sit under the centre cap), with **6 tick marks** labelled/spaced 0–5 for
   Prāṇa, `0` at the top of the sub-dial.
2. Move the smooth fast hand into this sub-dial. It keeps its smooth
   `pranaFraction` motion, so it still moves every tick, but now **one full turn
   of the sub-dial = 6 Prāṇa = one Vināḍī (~24 s)**. The hand crossing each of the
   6 marks corresponds exactly to the digital *Prāṇa* value ticking 0 → 5.
3. Keep the Ghaṭikā (slow) and Vināḍī (medium) hands exactly as they are on the
   main 0–60 face — they already read correctly.
4. Update the on-dial legend text if needed so the fast hand is clearly the
   "Prāṇa" sub-dial (the legend already says "Prāṇa · 4 seconds", which stays
   true).

### Why a sub-dial instead of 6 marks on the main face

The main face is numbered 0–60 and is shared by the Ghaṭikā and Vināḍī hands.
Adding a second, 6-count scale on the same ring would clash with those numbers and
confuse the reading. A separate small sub-dial is the standard analog-clock way to
show a different-count hand (seconds) without disturbing the main scale.

## Files to change

| File | Change |
|------|--------|
| `lib/widgets/dharma_dial_painter.dart` | Add a 6-mark Prāṇa sub-dial; move the fast hand into it; keep the other two hands and all math untouched. |
| `test/widgets/` (add or update a painter test if one exists) | Add a light test that the painter builds for a known reading; no math change to assert. |

I will **not** touch:
- `lib/services/time_calculator.dart` — the math is correct and confirmed.
- `lib/core/constants/app_constants.dart` — unit counts stay (6 Prāṇa/Vināḍī).
- `docs/` guidelines submodule.

## Checks before finishing

- `flutter analyze` clean.
- `flutter test` passes.
- `dart format .`.
- Visually: with the digital reading at *Prāṇa 5*, the sub-dial hand sits at the
  5-of-6 mark, and one full sub-dial turn takes ~24 civil seconds.

## After implementing

Write a change log to `change_log/` referencing this plan.

## Open question for you

Is my understanding right — a **6-mark Prāṇa sub-dial** where a full turn = 6
Prāṇa ≈ 24 s (elastic), math unchanged? Or did you mean something else by
"in the Civil clock"? Please approve or correct before I start.
