# Change log: Fill in the Panchang tab

Implements plan `plans/20260723_075550_panchang-tab-content.md`.

## What changed

New files:

- `lib/core/constants/panchang_names.dart` — name tables: 30 tithis (with
  pakṣa), 27 nakṣatras, 27 yogas, the 60-slot karaṇa order (Kiṁstughna at
  slot 0, the movable seven cycling slots 1–56, the closing fixed three at
  57–59), and the 7 vāras. Index lookups wrap instead of throwing.
- `lib/services/lunar_calculator.dart` — pure offline math: the Moon's
  ecliptic longitude (truncated Meeus ch. 47 — mean elements, the ~32 largest
  periodic terms, the three additive terms), the Sun's apparent longitude
  (same terms the NOAA sunrise math uses), a shared single-term nutation so
  it cancels in the Moon−Sun difference, and the Lahiri ayanāṁśa (linear
  approximation, ≈ 24.2° in 2026). All instants UTC.
- `lib/services/panchang_calculator.dart` — turns one dharma day
  (sunrise → next sunrise) into a `PanchangDay`: each limb is the one in
  force at sunrise; its end time is found by bisection (the driving angles
  grow monotonically, ≤ ~16°/day, so the crossing is unique). A limb ending
  after the next sunrise gets a `null` end; a non-positive span returns
  `null` (hard rule 4).
- `lib/models/panchang_day.dart` — immutable `PanchangLimb` (index, name,
  detail, nullable UTC end) and `PanchangDay` (sunrise + vāra + four limbs).
- `lib/providers/panchang_providers.dart` — `panchangDayProvider`, mirroring
  `horaDayProvider`: watches only the clock's anchor sunrise/span via
  `select`, so it recomputes once per day roll or location change, never per
  tick. `null` when there is no real sunrise.
- `test/services/lunar_calculator_test.dart` — Moon longitude vs Meeus
  example 47.a (1992-04-12), Sun longitude vs example 25.a (1992-10-13),
  ayanāṁśa range, elongation ≈ 0 at the 2026-08-12 solar eclipse, and the
  ~12.2°/day tithi rate.
- `test/services/panchang_calculator_test.dart` — the eclipse day at Ujjain
  gives Amāvāsyā at sunrise ending within an hour of the conjunction; limb
  indices agree with the raw angles; every reported end time lands on its
  boundary; the null-end and null-day fallbacks; the karaṇa/tithi name
  tables.

Changed files:

- `lib/screens/panchang_screen.dart` — the placeholder became the real tab:
  a header card naming the dharma day and its sunrise, then five cards
  (Vāra, Tithi, Nakṣatra, Yoga, Karaṇa) each with the name, an "until HH:MM"
  end line (date-marked when it falls on the next calendar day, or worded as
  "runs past the next sunrise"), and a one-line plain-English meaning.
  Friendly message when there is no sunrise anchor. The widget reads only
  the provider — no math in the UI.
- `lib/providers/service_providers.dart` — added `lunarCalculatorProvider`
  and `panchangCalculatorProvider`.
- `docs/architecture.md` — the "no Panchang calculation" non-goal now states
  the tab's separation rule instead; layout lists the new files.
- `docs/implementation_progress.md` — dated entry for this work.

## Notes

- Accuracy: the truncated series is good to roughly an arc-minute, which
  moves an end time by a minute or two — fine for a Panchang display. Times
  are computed in UT (no ΔT step), consistent with the sunrise math.
- No new dependencies; still fully offline (hard rule 1).
- `flutter analyze` clean, `dart format .` applied, **108 tests green**
  (was 70 + the muhūrta/hora suites).
