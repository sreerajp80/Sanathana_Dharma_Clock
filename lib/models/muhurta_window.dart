/// Whether a time window is traditionally favourable, unfavourable, or plain.
enum WindowKind { auspicious, inauspicious, neutral }

/// One named time window of the day: a muhūrta or a kāla.
///
/// Immutable, like every model (CLAUDE.md architecture rule). [start] and [end]
/// are **UTC** instants; screens convert with `.toLocal()` for display, the same
/// convention as `SolarDay.sunrise`. No logic beyond a containment check.
class MuhurtaWindow {
  /// Display name, e.g. `Rudra`, `Rāhu Kālam`, `Abhijit Muhūrta`.
  final String name;

  /// Favourable / unfavourable / plain — drives tags and arc colours.
  final WindowKind kind;

  /// Window start (UTC, inclusive).
  final DateTime start;

  /// Window end (UTC, exclusive).
  final DateTime end;

  const MuhurtaWindow({
    required this.name,
    required this.kind,
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
      other is MuhurtaWindow &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          kind == other.kind &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(name, kind, start, end);

  @override
  String toString() => 'MuhurtaWindow($name, $kind, $start – $end)';
}
