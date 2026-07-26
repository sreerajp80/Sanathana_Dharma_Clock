/// The kind of a yearly sun event, in the order they fall through a year.
///
/// The four tropical events are the equinoxes and solstices (the Sun's
/// tropical longitude crossing 0°, 90°, 180°, 270°). The two ayana starts are
/// the sidereal crossings: Uttarāyaṇa begins when the sidereal Sun enters
/// Makara (270°, Makara Saṅkrānti) and Dakṣiṇāyana when it enters Karka
/// (90°, Karka Saṅkrānti).
enum AlmanacEventKind {
  marchEquinox,
  juneSolstice,
  septemberEquinox,
  decemberSolstice,
  uttarayanaStart,
  dakshinayanaStart,
}

/// One yearly sun event: which one, and the instant it happens.
///
/// Immutable. [instantUtc] is a **UTC** instant; callers convert with
/// `.toLocal()` for display, like every other model in this app.
class AlmanacEvent {
  final AlmanacEventKind kind;
  final DateTime instantUtc;

  const AlmanacEvent({required this.kind, required this.instantUtc});
}

/// One calendar day's sunrise and sunset for the almanac table.
///
/// Immutable. [date] carries only the year/month/day of the row (a UTC
/// date-only value used as a calendar key). [sunriseUtc] / [sunsetUtc] are
/// `null` on polar dates when the event does not happen (CLAUDE.md hard
/// rule 4 — never invent one).
class AlmanacDay {
  final DateTime date;
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;

  const AlmanacDay({required this.date, this.sunriseUtc, this.sunsetUtc});

  /// Sunrise → sunset length, or `null` when either end is missing.
  Duration? get dayLength {
    final rise = sunriseUtc;
    final set = sunsetUtc;
    if (rise == null || set == null) return null;
    final length = set.difference(rise);
    return length.isNegative ? null : length;
  }
}

/// A whole year's almanac for one place: the six sun events in date order and
/// one [AlmanacDay] per calendar day.
///
/// Immutable. Computed once per year/location change — never per tick.
class AlmanacYear {
  final int year;
  final List<AlmanacEvent> events;
  final List<AlmanacDay> days;

  const AlmanacYear({
    required this.year,
    required this.events,
    required this.days,
  });
}
