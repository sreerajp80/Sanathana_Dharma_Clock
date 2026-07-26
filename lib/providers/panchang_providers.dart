import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/panchang_day.dart';
import 'clock_providers.dart';
import 'location_providers.dart';
import 'service_providers.dart';

/// The day's Panchang, ready for the Panchang tab.
///
/// Mirrors `horaDayProvider`: it watches only the clock's anchor sunrise/span
/// (via `select`), not the ticking snapshot — so it recomputes once per
/// day-boundary roll or location change, never per second (architecture §19).
///
/// The value is **`null`** when there is no real sunrise to anchor to (no
/// location, or a polar/fallback day) — no fake Panchang is invented
/// (CLAUDE.md hard rule 4); the screen shows a friendly message instead.
final panchangDayProvider = Provider<PanchangDay?>((ref) {
  final calculator = ref.watch(panchangCalculatorProvider);

  // The clock's resolved day: these change only on a day roll or a location
  // change, so this provider stays quiet between them.
  final sunriseLocal = ref.watch(clockProvider.select((s) => s.dharma.sunrise));
  final span = ref.watch(clockProvider.select((s) => s.dharma.span));
  final isPolar = ref.watch(clockProvider.select((s) => s.isPolar));

  final location = ref.watch(effectiveLocationProvider);
  if (isPolar || location == null) return null;

  final sunriseUtc = sunriseLocal.toUtc();
  return calculator.panchangFor(
    sunrise: sunriseUtc,
    // The clock's day already ends at the next sunrise: anchor + span.
    nextSunrise: sunriseUtc.add(span),
    // Vāra is named after the local calendar weekday of the anchor day.
    weekday: sunriseLocal.weekday,
    // Only the moonrise/moonset times depend on the place.
    latitudeDeg: location.latitude,
    longitudeDeg: location.longitude,
  );
});
