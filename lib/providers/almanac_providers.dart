import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/almanac_year.dart';
import '../services/almanac_calculator.dart';
import 'location_providers.dart';
import 'service_providers.dart';

/// The yearly-almanac math service (stateless, like the other calculators).
final almanacCalculatorProvider = Provider<AlmanacCalculator>(
  (ref) => AlmanacCalculator(
    ref.watch(solarCalculatorProvider),
    ref.watch(lunarCalculatorProvider),
  ),
);

/// The year the Almanac tab is showing. Starts at the current year; the
/// screen's back/next arrows move it.
class AlmanacYearNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().year;

  void previous() => state = state - 1;
  void next() => state = state + 1;
}

/// The selected almanac year.
final selectedAlmanacYearProvider = NotifierProvider<AlmanacYearNotifier, int>(
  AlmanacYearNotifier.new,
);

/// The computed almanac for the selected year at the effective location.
///
/// Recomputes only when the year or the location changes — never per tick
/// (plan 20260723_181354). `null` when there is no location at all; the
/// screen shows a friendly message instead (CLAUDE.md hard rule 4).
final almanacYearProvider = Provider<AlmanacYear?>((ref) {
  final location = ref.watch(effectiveLocationProvider);
  if (location == null) return null;

  final year = ref.watch(selectedAlmanacYearProvider);
  return ref
      .watch(almanacCalculatorProvider)
      .almanacFor(
        year: year,
        latitudeDeg: location.latitude,
        longitudeDeg: location.longitude,
      );
});
