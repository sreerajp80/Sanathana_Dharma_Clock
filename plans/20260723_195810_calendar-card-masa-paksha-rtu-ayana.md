# Calendar card: Māsa, Pakṣa, Ṛtu, Ayana on the Panchang tab

**Status:** completed

## The issue

The Panchang tab shows the five limbs (tithi, nakṣatra, yoga, karaṇa, vāra) and the
moon times, but not the day's place in the wider calendar:

- **Māsa** — the lunar month name (e.g. Śrāvaṇa),
- **Pakṣa** — bright / dark fortnight (already computed, but only as a tithi detail line),
- **Ṛtu** — the season (e.g. Varṣā),
- **Ayana** — Uttarāyaṇa or Dakṣiṇāyana.

These fall out of math the app already has: tithi (Moon−Sun elongation) and the Sun's
sidereal longitude.

## Decisions (user-confirmed)

- **Māsa: show BOTH Amānta and Pūrṇimānta values in the card, each with a short
  note** (e.g. "Amānta — month ends at new moon; South India" / "Pūrṇimānta —
  month ends at full moon; North India"). No setting is added — the user sees
  both and understands which is which.
- **Ayana rule: nirayana.** Uttarāyaṇa when the Sun's *sidereal* longitude is in
  [270°, 360°) ∪ [0°, 90°) (Makara through Mithuna); Dakṣiṇāyana in [90°, 270°).
  This flips at Makara / Karka Saṅkrānti, like printed Panchangs.

## The math (all evaluated at the day's sunrise, like the other limbs)

### Māsa (Amānta)

1. Find the **new moon that started the current lunar month**: the most recent
   instant before (or at) sunrise where the Moon−Sun elongation crossed 0°.
   The elongation at sunrise is `E`; the crossing is about `E / 12.19` days
   earlier. Bracket it (window `[sunrise − E/11° per day − 1 d, sunrise]`) and
   bisect, exactly like the existing end-time bisection but backwards in time.
2. Take the Sun's **sidereal rāśi** (30° sign, 0 = Meṣa) at that new moon, `r`.
3. Māsa name = `masas[(r + 1) % 12]` with index 0 = Chaitra.
   (Check: Chaitra starts at a new moon with the Sun in Mīna, r = 11 → index 0. ✓)
4. **Adhika māsa**: also find the *next* new moon (after the starting one).
   If the Sun's rāśi is the same at both new moons, no saṅkrānti fell inside the
   month → prefix the name with "Adhika".

### Māsa (Pūrṇimānta)

Same month boundaries shifted by half a month: during **Kṛṣṇa pakṣa** (tithi
index 15–29) the Pūrṇimānta month is the **next** Amānta month name; during
Śukla pakṣa the two systems agree. So: compute the Amānta māsa as above, and if
the day's tithi index ≥ 15, advance the name by one month. (Adhika handling for
Pūrṇimānta follows the same shift; the plan keeps it simple: show "Adhika" only
when the underlying Amānta month is adhika.)

### Pakṣa

Already known: `PanchangNames.paksha(tithi.index)`. Reuse it — no new math.

### Ṛtu

Derived from the Amānta māsa index, two months per season:
Chaitra+Vaiśākha → Vasanta; Jyeṣṭha+Āṣāḍha → Grīṣma; Śrāvaṇa+Bhādrapada → Varṣā;
Āśvina+Kārttika → Śarad; Mārgaśīrṣa+Pauṣa → Hemanta; Māgha+Phālguna → Śiśira.
(Ṛtu always follows the Amānta month — that is the standard convention.)

### Ayana

`sunSiderealLongitudeDeg(sunrise)` — already in `LunarCalculator`. Uttarāyaṇa
when it is ≥ 270° or < 90°, else Dakṣiṇāyana.

## Files to change

| File | Change |
|------|--------|
| `lib/core/constants/panchang_names.dart` | Add the 12 māsa names (Chaitra … Phālguna), the 6 ṛtu names, the two ayana names, the "Adhika" prefix, and small index-lookup helpers (wrap, never throw). |
| `lib/models/panchang_day.dart` | Add a small immutable `CalendarInfo` class (amānta māsa name, pūrṇimānta māsa name, isAdhika, paksha, rtu, ayana) and a `calendar` field on `PanchangDay`. |
| `lib/services/panchang_calculator.dart` | Add the new-moon back-bisection and the māsa/ṛtu/ayana derivation; computes **both** māsa names and fills `calendar`. No new parameters. |
| `lib/screens/panchang_screen.dart` | New `_CalendarCard` placed right under `_DayHeaderCard`, showing: both Māsa lines with a one-line note each ("month ends at new moon — South India" / "month ends at full moon — North India"), then Pakṣa, Ṛtu, Ayana. When the two māsa names are equal (Śukla pakṣa) still show both lines, so the layout is stable and the notes stay visible. |
| `test/services/panchang_calculator_test.dart` | Tests: a known date → expected māsa/pakṣa/ṛtu/ayana (Amānta and Pūrṇimānta), an adhika-māsa date (e.g. Adhika Śrāvaṇa 2026-05/06? — pick a verified one, e.g. Adhika Jyeṣṭha 2026 does not exist; use Adhika Śrāvaṇa 2023-07-18), and the ayana boundary near Makara Saṅkrānti (mid-January). |
| `test/models/` / widget test | Small test for the new model class and, if practical, the card rendering. |

## What stays the same

- No new packages, no networking, everything computed on the device.
- No settings, prefs, providers, or repositories change at all.
- `panchangDayProvider` still recomputes only on day roll / location change.
- Fallback safety: if the new-moon bisection cannot bracket a crossing
  (should not happen, but hard rule 4), `calendar` is `null` and the card
  simply hides the māsa line rather than crashing.

## Verification

- `flutter analyze` clean, `dart format .`, `flutter test` green.
- Cross-check a few dates against a published Panchang (e.g. today,
  2026-07-23: Śrāvaṇa māsa (Amānta), Śukla pakṣa, Varṣā ṛtu, Dakṣiṇāyana).
