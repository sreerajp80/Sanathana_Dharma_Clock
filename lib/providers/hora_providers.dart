import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hora_window.dart';
import 'clock_providers.dart';
import 'location_providers.dart';
import 'service_providers.dart';

/// The day's 24 horās, ready for the Hora tab.
///
/// Mirrors `muhurtaDayProvider`: it watches only the clock's anchor
/// sunrise/span (via `select`), not the ticking snapshot — so it recomputes
/// once per day-boundary roll or location change, never per second
/// (architecture §19). The sunset the horās need is computed here, once, from
/// the anchor date.
///
/// The list is **empty** when no real sunset exists (no location, or a
/// polar/fallback day) — no fake windows are invented (CLAUDE.md hard rule 4);
/// the screen shows a friendly message instead.
final horaDayProvider = Provider<List<HoraWindow>>((ref) {
  final calculator = ref.watch(horaCalculatorProvider);

  // The clock's resolved day: these change only on a day roll or a location
  // change, so this provider stays quiet between them.
  final sunriseLocal = ref.watch(clockProvider.select((s) => s.dharma.sunrise));
  final span = ref.watch(clockProvider.select((s) => s.dharma.span));
  final isPolar = ref.watch(clockProvider.select((s) => s.isPolar));

  final location = ref.watch(effectiveLocationProvider);
  if (isPolar || location == null) return const [];

  final sunriseUtc = sunriseLocal.toUtc();
  final sunset = ref
      .read(solarCalculatorProvider)
      .sunsetUtc(sunriseUtc, location.latitude, location.longitude);
  if (sunset == null || !sunset.isAfter(sunriseUtc)) return const [];

  return calculator.horaList(
    sunrise: sunriseUtc,
    sunset: sunset,
    // The clock's day already ends at the next sunrise: anchor + span.
    nextSunrise: sunriseUtc.add(span),
    // The lord table is keyed by the local calendar weekday of the anchor day.
    weekday: sunriseLocal.weekday,
  );
});
