# Sanathana Dharma Clock — Design Idea

A real, readable clock that keeps time in the Sanātana Dharma (Vedic) system,
yet always tells you the correct time of day. It starts the day at **local
sunrise** (the traditional *ahorātra*) and divides that day into elastic units
that scale with the real length of the day.

## 1. The time units

The four units nest cleanly and fill one whole day:

- 1 day = 30 Muhūrta = 60 Ghaṭikā
- 1 Muhūrta = 2 Ghaṭikā (48 min = 2 × 24 min)
- 1 Ghaṭikā = 60 Vināḍī (24 min → 24 s each)
- 1 Vināḍī = 6 Prāṇa (24 s → 4 s each)
- 1 day = 21,600 Prāṇa × 4 s = 86,400 s = 24 h

So the clock can be read as **Ghaṭikā : Vināḍī : Prāṇa**, just like
Hour : Minute : Second, but in base 60 / 60 / 6. It is fully reversible: any
Ghaṭikā:Vināḍī:Prāṇa reading maps back to an exact civil time.

## 2. Chosen model — Sunrise, proportional (Design C)

The traditional day (*ahorātra*) runs from **local sunrise to the next local
sunrise**. That whole span is split into exactly **60 Ghaṭikā** (= 30 Muhūrta).

Because the real span is rarely exactly 24 h, each Ghaṭikā is *elastic* — close
to 24 minutes, but a little longer in one season and shorter in another. Every
smaller unit scales inside it:

```
1 Ghaṭikā = span / 60
1 Vināḍī  = Ghaṭikā / 60
1 Prāṇa   = Vināḍī / 6
```

This is the model most faithful to the classical texts, and it never has a
mid-day jump.

## 3. Inputs the clock needs

To find sunrise we need three things:

1. **Latitude & longitude** — from device GPS, or a city the user picks once.
2. **The date** — from the system clock.
3. **A sunrise algorithm** — the standard NOAA / solar-position formula
   (Julian date → solar declination → hour angle → sunrise/sunset). Pure math,
   no internet needed.

We compute **two** sunrises — today's and tomorrow's — and the gap between them
is the day span.

### Location handling

The clock works from a location in one of two ways, chosen by the user:

- **Saved location** — the user fetches their location once, then **saves** it.
  From then on the clock runs from that saved latitude & longitude, even with
  location services turned off. This is the default, offline-friendly mode.
- **Live location** — if the user enables location, the app fetches the current
  device location and uses that instead of the saved one.

Rules:

1. On first run, prompt the user to fetch and save a location (or pick a city).
2. If a saved location exists, use it whenever live location is off or
   unavailable.
3. If the user enables live location, fetch the current position and use it; keep
   the saved location as a fallback.
4. The user can re-fetch and overwrite the saved location at any time.
5. Persist the saved location on the device (e.g. `shared_preferences`) so it
   survives app restarts.

## 4. Core mapping

```
sr_today    = sunrise for current date at (lat, lon)
sr_tomorrow = sunrise for next date
span        = sr_tomorrow - sr_today          // seconds, ~86400 ± a few hundred

s = now - sr_today                            // seconds since today's sunrise
if s < 0:  use yesterday's sunrise instead    // we're before today's sunrise

ghatikaLen = span / 60
frac = s / span                               // 0..1 through the dharma day

G = floor(s / ghatikaLen)                      // 0..59  Ghaṭikā
r = s - G * ghatikaLen
V = floor(r / (ghatikaLen / 60))               // 0..59  Vināḍī
r = r - V * (ghatikaLen / 60)
P = floor(r / (ghatikaLen / 360))              // 0..5   Prāṇa
M = floor(G / 2)                               // 0..29  Muhūrta
```

Civil time and dharma time are always shown together, so the clock stays
"correct for the day."

## 5. Display — analog dial + digital readout

**Analog dial** (outer → inner):

- Outer ring: 30 Muhūrta marks; the current one highlighted, with its
  traditional name (e.g. *Brahma Muhūrta* near sunrise).
- Main dial: 60 Ghaṭikā marks; a slow hand points to the current Ghaṭikā.
- Middle hand: Vināḍī (0–59), sweeps once per Ghaṭikā.
- Fast hand: Prāṇa + fraction, the smooth "second hand."
- A sun/moon marker on the rim shows sunrise (top) and where "now" sits — an
  instant read of day vs night.

**Digital readout** underneath:

```
Ghaṭikā 24 : Vināḍī 18 : Prāṇa 3
Muhūrta 12 / 30   —   Brahma Muhūrta
Civil 09:37:12    Sunrise 06:11
```

## 6. Edge cases

- **No location / permission denied** → fall back to a saved city, or to a plain
  midnight-anchored day, so the clock still runs.
- **Polar regions / no sunrise on a date** → detect it and use a fixed 86,400 s
  span for that day.
- **Day boundary** → when `now` passes the next sunrise, roll the anchor
  forward. Recompute sunrises once per day, not every tick.
- **DST / time zones** → do all math in UTC; convert to local only for display.

## 7. How it maps to the current code

- Extend `models/dharma_time.dart` with `ghatikaLen`, `span`, `sunrise`.
- Rewrite `services/time_calculator.dart` to take sunrise + span instead of
  dividing from midnight.
- Add a `SolarCalculator` service for the sunrise math.
- Add a `location` plugin (e.g. `geolocator`) + Android location permission.
- Add a `LocationService` that fetches live location and saves/loads the chosen
  location via `shared_preferences`.
- Add a `DharmaDialPainter` `CustomPainter` for the analog face (sibling to the
  existing `widgets/moon_phase_painter.dart`).
- The Panchang tab is untouched — it is a separate concern.

New dependencies: a location plugin, `shared_preferences` for the saved
location, and Android location permission. The solar math is written directly,
no package needed.

## 8. UI & theme

- **Modern UI** — clean, minimal, card-based layout with rounded corners, soft
  shadows, and generous spacing.
- **Colour theme** — *vermillion* (sindūr) foreground on a *chandan*
  (sandalwood) background:
  - **Foreground / accent** — vermillion (a warm red-orange, ≈ `#E34234`), used
    for text, clock hands, active highlights, and icons.
  - **Background** — chandan / sandalwood (a soft pale tan, ≈ `#F1E4C3`), used
    for the page and card surfaces.
- Applied consistently across the clock, Panchang, and Settings screens through a
  single Flutter `ThemeData`.

## 9. Settings page

A dedicated Settings screen built from **cards, one card per section**. Each
card groups related settings under a clear heading.

- **Location card** — fetch / save location, toggle live vs saved location,
  show the current saved location.
- **Display card** — analog / digital / both, and any format options.
- **About card** — shows app details (name, version, author, etc.) **read from a
  file** (e.g. a bundled `about.json` or `pubspec` values) rather than
  hard-coded, so it stays easy to update.
- Further settings are added as new section cards in the appropriate place.

## 10. Technical environment

Built and tested against the following toolchain:

- **Flutter** 3.41.9 • channel stable
  - Framework revision `00b0c91f06` • 2026-04-29
  - Engine hash `9161402dc0e134b3fb5adee5046b6e84b1a5e1c1` (revision `42d3d75a56`) • 2026-04-28
- **Dart** 3.11.5
- **DevTools** 2.54.2
