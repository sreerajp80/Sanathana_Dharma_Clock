import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/muhurta_window.dart';
import 'clock_providers.dart';
import 'location_providers.dart';
import 'service_providers.dart';

/// The day's named windows, ready for the Muhurta & Kalas tab and the dial arcs.
///
/// Immutable. [muhurtas] always has 30 entries (the fallback day still splits
/// into 30). [kalas] holds Abhijit + the three kālas, or is **empty** when no
/// sunset exists (no location, or a polar date) — no fake windows are invented
/// (CLAUDE.md hard rule 4). [isApproximate] is `true` when the day itself was
/// the midnight-anchored fallback, so the UI can label the list as approximate.
class MuhurtaDay {
  final List<MuhurtaWindow> muhurtas;
  final List<MuhurtaWindow> kalas;
  final bool isApproximate;

  const MuhurtaDay({
    required this.muhurtas,
    required this.kalas,
    required this.isApproximate,
  });
}

/// Derives [MuhurtaDay] from the clock's current day and the effective location.
///
/// It watches only the clock's anchor sunrise/span (via `select`), not the
/// ticking snapshot — so it recomputes once per day-boundary roll or location
/// change, never per second (architecture §19). The sunset needed by the kālas
/// is computed here, once, from the anchor date.
final muhurtaDayProvider = Provider<MuhurtaDay>((ref) {
  final calculator = ref.watch(muhurtaKalaCalculatorProvider);

  // The clock's resolved day: these change only on a day roll or a location
  // change, so this provider stays quiet between them.
  final sunriseLocal = ref.watch(clockProvider.select((s) => s.dharma.sunrise));
  final span = ref.watch(clockProvider.select((s) => s.dharma.span));
  final isPolar = ref.watch(clockProvider.select((s) => s.isPolar));

  final sunriseUtc = sunriseLocal.toUtc();
  final muhurtas = calculator.muhurtaList(sunrise: sunriseUtc, span: span);

  // The kālas need a real daytime (sunrise → sunset). Without a location or on
  // a polar/fallback day there is none — return no kāla windows.
  final location = ref.watch(effectiveLocationProvider);
  var kalas = const <MuhurtaWindow>[];
  if (!isPolar && location != null) {
    final sunset = ref
        .read(solarCalculatorProvider)
        .sunsetUtc(sunriseUtc, location.latitude, location.longitude);
    if (sunset != null && sunset.isAfter(sunriseUtc)) {
      kalas = calculator.kalaWindows(
        sunrise: sunriseUtc,
        sunset: sunset,
        // The tables are keyed by the local calendar weekday of the anchor day.
        weekday: sunriseLocal.weekday,
      );
    }
  }

  return MuhurtaDay(muhurtas: muhurtas, kalas: kalas, isApproximate: isPolar);
});
