# Almanac tab (yearly view) + shorter bottom tab bar

**Status:** completed

## The issue

1. The app has no yearly view. The user wants a yearly almanac for the saved
   location: sunrise/sunset for every day, plus the year's solstices, equinoxes,
   and ayana changes. All of it can be computed once per year — nothing needs a
   live tick.
2. The bottom tab bar is taller than needed. With a fifth tab coming, a shorter
   bar keeps more room for content.

Placement decision (user chose): a **fifth bottom tab** named "Almanac".

## What the almanac shows

For the saved location and a chosen year (default: current year, with back/next
arrows to change the year):

- **Year events card** at the top, in date order:
  - March equinox, June solstice, September equinox, December solstice
    (tropical sun longitude crossing 0° / 90° / 180° / 270°).
  - Uttarāyaṇa start (sidereal sun crossing 270°, Makara Saṅkrānti) and
    Dakṣiṇāyana start (sidereal sun crossing 90°, Karka Saṅkrānti).
  - Each with its local date and time, and a one-line plain-word note.
- **Monthly sunrise/sunset list**: twelve expandable month sections; each day
  row shows date, sunrise, sunset, and day length. Polar gaps (no sunrise or
  no sunset) show a dash. The current day is highlighted.

All times are computed in UTC and converted to local only for display, matching
the existing services.

## The math (all already in the app — no new packages)

- Sunrise/sunset per day: `SolarCalculator.sunriseUtc` / `sunsetUtc`.
- Sun tropical longitude: `LunarCalculator.sunLongitudeDeg`.
- Sun sidereal longitude: `LunarCalculator.sunSiderealLongitudeDeg`.
- Crossing instants are found by scanning the year day-by-day for the target
  longitude being crossed, then bisecting the bracketing day down to the
  minute. Six events per year, so this is cheap.

The whole year is computed **once** when the year (or location) changes, in a
provider — never per tick (CLAUDE.md "recompute sunrises once per day" spirit).

## Files to change

| File | Change |
|------|--------|
| `lib/services/almanac_calculator.dart` | **New.** Pure service: given lat/lon and a year, returns the year's events (equinoxes, solstices, ayana starts) and the per-day sunrise/sunset table. Depends only on `SolarCalculator` and `LunarCalculator`. |
| `lib/models/almanac_year.dart` | **New.** Immutable models: `AlmanacYear`, `AlmanacEvent` (kind, UTC instant), `AlmanacDay` (date, sunrise?, sunset?). |
| `lib/providers/almanac_providers.dart` | **New.** `almanacYearProvider` — selected-year state + a computed `AlmanacYear` for the effective location; recomputes only when year or location changes. |
| `lib/screens/almanac_screen.dart` | **New.** The tab UI: year selector, events card, month sections with day rows. No math in the widget. |
| `lib/core/router.dart` | Add a fifth `StatefulShellBranch` with route `/almanac`. |
| `lib/screens/home_shell.dart` | Add the "Almanac" destination (icon: `Icons.menu_book_outlined` / `menu_book`); set `NavigationBar` `height: 64` and `labelBehavior: alwaysShow` to shorten the bar (default is 80). |
| `test/services/almanac_calculator_test.dart` | **New.** Tests: 2026 June solstice ≈ Jun 21, December solstice ≈ Dec 21, equinoxes ≈ Mar 20 / Sep 22–23; Makara Saṅkrānti ≈ mid-January; a known sunrise/sunset day row; a polar date yields null sunrise. |

## The plan for the fix

1. Add the models (`almanac_year.dart`).
2. Add `AlmanacCalculator` with the year scan + bisection for the six events
   and the day-table builder.
3. Add the provider file wiring it to the effective location.
4. Add `AlmanacScreen` and register the tab (router + home shell), and set the
   navigation-bar height to 64 in the same edit.
5. Add the service tests.
6. Run `dart format .`, `flutter analyze`, `flutter test`.
7. Write the change log.
