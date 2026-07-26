/// One horā (planetary hour) of the day: its ruling planet and its span.
///
/// Immutable, like every model (CLAUDE.md architecture rule). [start] and [end]
/// are **UTC** instants; screens convert with `.toLocal()` for display, the
/// same convention as `MuhurtaWindow`. No logic beyond a containment check.
class HoraWindow {
  /// Display name of the ruling planet, e.g. `Śukra (Venus)`.
  final String lord;

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
          isDay == other.isDay &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(lord, isDay, start, end);

  @override
  String toString() =>
      'HoraWindow($lord, ${isDay ? 'day' : 'night'}, $start – $end)';
}
