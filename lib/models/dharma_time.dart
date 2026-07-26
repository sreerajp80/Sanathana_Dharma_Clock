/// One immutable reading of the clock in the Sanātana Dharma (Vedic) system.
///
/// The day runs from local sunrise to the next local sunrise (the *ahorātra*)
/// and is split into 60 elastic Ghaṭikā (= 30 Muhūrta). See the idea doc §1 and
/// §4 for the unit nesting and the mapping.
///
/// This type holds data only — the mapping from civil time to these units lives
/// in the Phase 3 `TimeCalculator`. A new reading is computed each tick; it is
/// never mutated in place.
class DharmaTime {
  /// The Ghaṭikā, 0–59.
  final int ghatika;

  /// The Vināḍī, 0–59.
  final int vinadi;

  /// The Prāṇa, 0–5.
  final int prana;

  /// The Muhūrta, 0–29 (equals `ghatika ~/ 2`).
  final int muhurta;

  /// Progress through the whole dharma day, 0.0–1.0. Used for the slow Ghaṭikā
  /// hand and the "now" marker on the rim.
  final double fraction;

  /// Progress through the current Ghaṭikā, 0.0–1.0. Drives the Vināḍī hand, so
  /// it sweeps once per Ghaṭikā (~24 min) instead of jumping between ticks.
  final double vinadiFraction;

  /// Progress through the current Vināḍī, 0.0–1.0. Drives the smooth fast hand,
  /// so it turns once per Vināḍī (~24 s) and visibly moves every tick.
  final double pranaFraction;

  /// The sunrise-to-next-sunrise length of this dharma day. Close to 24 h but
  /// elastic across the seasons.
  final Duration span;

  /// The length of one Ghaṭikā (`span / 60`), kept so the dial need not
  /// recompute it.
  final Duration ghatikaLen;

  /// Today's anchoring sunrise, in local time, for the "Sunrise 06:11" readout.
  final DateTime sunrise;

  const DharmaTime({
    required this.ghatika,
    required this.vinadi,
    required this.prana,
    required this.muhurta,
    required this.fraction,
    required this.vinadiFraction,
    required this.pranaFraction,
    required this.span,
    required this.ghatikaLen,
    required this.sunrise,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DharmaTime &&
          runtimeType == other.runtimeType &&
          ghatika == other.ghatika &&
          vinadi == other.vinadi &&
          prana == other.prana &&
          muhurta == other.muhurta &&
          fraction == other.fraction &&
          vinadiFraction == other.vinadiFraction &&
          pranaFraction == other.pranaFraction &&
          span == other.span &&
          ghatikaLen == other.ghatikaLen &&
          sunrise == other.sunrise;

  @override
  int get hashCode => Object.hash(
    ghatika,
    vinadi,
    prana,
    muhurta,
    fraction,
    vinadiFraction,
    pranaFraction,
    span,
    ghatikaLen,
    sunrise,
  );

  @override
  String toString() => 'Gh $ghatika : Vi $vinadi : Pr $prana (M$muhurta)';
}
