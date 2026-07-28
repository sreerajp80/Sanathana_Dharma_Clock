/// One horā (planetary hour) of the day: its ruling planet and its span.
///
/// Immutable, like every model (CLAUDE.md architecture rule). [start] and [end]
/// are **UTC** instants; screens convert with `.toLocal()` for display, the
/// same convention as `MuhurtaWindow`. No logic beyond a containment check.
class HoraWindow {
  /// Canonical display name of the ruling planet, e.g. `Śukra (Venus)`.
  /// Screens showing a translated interface use [lordIndex] instead.
  final String lord;

  /// Language-free key for [lord]: its position (0–6) in `HoraNames.order`, so
  /// a screen can show the planet's name in the user's language.
  final int lordIndex;

  /// `true` for a day horā (sunrise → sunset), `false` for a night horā
  /// (sunset → next sunrise).
  final bool isDay;

  /// Window start (UTC, inclusive).
  final DateTime start;

  /// Window end (UTC, exclusive).
  final DateTime end;

  const HoraWindow({
    required this.lord,
    required this.isDay,
    required this.start,
    required this.end,
    this.lordIndex = 0,
  });

  /// `true` when [instant] falls inside `[start, end)`.
  bool contains(DateTime instant) {
    final utc = instant.toUtc();
    return !utc.isBefore(start) && utc.isBefore(end);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoraWindow &&
          runtimeType == other.runtimeType &&
          lord == other.lord &&
          lordIndex == other.lordIndex &&
          isDay == other.isDay &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(lord, lordIndex, isDay, start, end);

  @override
  String toString() =>
      'HoraWindow($lord, ${isDay ? 'day' : 'night'}, $start – $end)';
}
