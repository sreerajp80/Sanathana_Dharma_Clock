# Calendar card: Māsa, Pakṣa, Ṛtu, Ayana on the Panchang tab

Implements plan `plans/20260723_195810_calendar-card-masa-paksha-rtu-ayana.md`.

## What changed

- **`lib/core/constants/panchang_names.dart`** — added the 12 māsa names
  (Chaitra … Phālguna), the 6 ṛtu names (with a plain-English word each,
  e.g. "Varṣā (monsoon)"), the two ayana names, the "Adhika" prefix, and
  wrap-safe lookup helpers (`masa`, `rtuOfMasa`).
- **`lib/models/panchang_day.dart`** — new immutable `CalendarInfo` class
  (amānta māsa, pūrṇimānta māsa, isAdhika, pakṣa, ṛtu, ayana) and a nullable
  `calendar` field on `PanchangDay`.
- **`lib/services/panchang_calculator.dart`** — new calendar math:
  - Finds the new moon that started the month by walking back day-by-day
    until the elongation jumps, then bisecting (same style as the limb end
    times). Same walk forward finds the month's ending new moon.
  - Amānta māsa = Sun's sidereal sign at the starting new moon + 1
    (0 = Chaitra). Adhika when the sign is the same at both new moons.
  - Pūrṇimānta māsa = one month ahead during Kṛṣṇa pakṣa, same otherwise.
  - Ṛtu from the amānta month (two months per season); Ayana by the nirayana
    rule (sidereal Sun ≥ 270° or < 90° → Uttarāyaṇa).
  - If a bounding new moon cannot be found, `calendar` is `null` — no fake
    value (hard rule 4).
- **`lib/screens/panchang_screen.dart`** — new `_CalendarCard` under the day
  header. Shows **both** māsa systems, each with a one-line note ("ends at
  the new moon — South India" / "ends at the full moon — North India"), then
  Pakṣa, Ṛtu, and Ayana, each with a short plain-English note. Hidden when
  `calendar` is `null`.
- **`test/services/panchang_calculator_test.dart`** — new tests against
  documented dates: Adhika Śrāvaṇa (2023-08-01), nija Śrāvaṇa (2023-08-25),
  Āśvina at Navaratri (2023-10-16) with Śarad ṛtu, the pūrṇimānta one-month
  shift in Kṛṣṇa pakṣa (2023-10-05), and the ayana flip at Makara Saṅkrānti
  (Jan 10 vs Jan 20). Plus māsa/ṛtu table tests.

## Notes

- Per a mid-plan user update, **no setting was added** — both māsa systems
  are always shown with an explaining note, instead of an Amānta/Pūrṇimānta
  switch. No prefs, providers, or repositories were touched.
- All offline, no new packages.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 122 tests pass (including the new calendar tests).
- `dart format .` — no changes needed.
