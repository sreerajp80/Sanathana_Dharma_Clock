/// Whether a time window is traditionally favourable, unfavourable, or plain.
enum WindowKind { auspicious, inauspicious, neutral }

/// Which window this is, independent of any language.
///
/// [name] holds the canonical Sanskrit/English wording, which is fixed at build
/// time in the service layer. A screen needs the language-free key as well, so
/// it can show the name in the user's language: [muhurta] together with
/// `MuhurtaWindow.index` picks one of the 30 muhūrta names, and the other
/// values name a single fixed window.
enum WindowLabel { muhurta, abhijit, rahuKala, yamagandaKala, gulikaKala }

/// One named time window of the day: a muhūrta or a kāla.
///
/// Immutable, like every model (CLAUDE.md architecture rule). [start] and [end]
/// are **UTC** instants; screens convert with `.toLocal()` for display, the same
/// convention as `SolarDay.sunrise`. No logic beyond a containment check.
class MuhurtaWindow {
  /// Canonical display name, e.g. `Rudra`, `Rāhu Kālam`, `Abhijit Muhūrta`.
  /// Screens showing a translated interface use [label] and [index] instead.
  final String name;

  /// Language-free key for [name], so a screen can translate it.
  final WindowLabel label;

  /// The 0–29 muhūrta number when [label] is `WindowLabel.muhurta`; `0` for
  /// the kāla windows, which have no number.
  final int index;

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
    this.label = WindowLabel.muhurta,
    this.index = 0,
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
          label == other.label &&
          index == other.index &&
          kind == other.kind &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(name, label, index, kind, start, end);

  @override
  String toString() => 'MuhurtaWindow($name, $kind, $start – $end)';
}
