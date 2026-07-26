import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/location_repository.dart';
import '../services/hora_calculator.dart';
import '../services/location_service.dart';
import '../services/lunar_calculator.dart';
import '../services/moon_rise_set_calculator.dart';
import '../services/muhurta_kala_calculator.dart';
import '../services/panchang_calculator.dart';
import '../services/solar_calculator.dart';
import '../services/time_calculator.dart';
import 'core_providers.dart';

/// Providers for the stateless services and the single repository.
///
/// These hold no state of their own — they just make the Phase 3 math and the
/// Phase 4 location layer available to the higher providers (clock, location,
/// settings) and, later, to screens. Keeping them here means a test can override
/// any one with a fake in a single line.
///
/// Direction stays `providers → services/repositories → shared_preferences`
/// (architecture §9): the repository reads [sharedPreferencesProvider]; nothing
/// here knows about `BuildContext`, routes, or UI strings.

/// The pure solar/sunrise math (NOAA formula + day resolution).
final solarCalculatorProvider = Provider<SolarCalculator>(
  (ref) => const SolarCalculator(),
);

/// The elastic-span civil ↔ dharma-time mapping.
final timeCalculatorProvider = Provider<TimeCalculator>(
  (ref) => const TimeCalculator(),
);

/// The day's named windows: the 30 muhūrtas and the daytime kālas.
final muhurtaKalaCalculatorProvider = Provider<MuhurtaKalaCalculator>(
  (ref) => const MuhurtaKalaCalculator(),
);

/// The day's 24 horās (planetary hours) and their ruling planets.
final horaCalculatorProvider = Provider<HoraCalculator>(
  (ref) => const HoraCalculator(),
);

/// The pure lunar/solar longitude math behind the Panchang.
final lunarCalculatorProvider = Provider<LunarCalculator>(
  (ref) => const LunarCalculator(),
);

/// The moonrise/moonset finder used by the Panchang.
final moonRiseSetCalculatorProvider = Provider<MoonRiseSetCalculator>(
  (ref) => MoonRiseSetCalculator(ref.watch(lunarCalculatorProvider)),
);

/// The day's five Panchang limbs (tithi, nakṣatra, yoga, karaṇa, vāra),
/// plus the day's moonrise/moonset.
final panchangCalculatorProvider = Provider<PanchangCalculator>(
  (ref) => PanchangCalculator(
    ref.watch(lunarCalculatorProvider),
    ref.watch(moonRiseSetCalculatorProvider),
  ),
);

/// Reads the device GPS position, asking permission at the point of use.
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

/// The only reader/writer of the saved location and the use-live flag in
/// `shared_preferences`.
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepository(ref.watch(sharedPreferencesProvider)),
);
