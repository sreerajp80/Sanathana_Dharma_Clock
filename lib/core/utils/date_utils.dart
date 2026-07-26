/// Small, pure date/UTC helpers used by the solar math.
///
/// These have no Flutter or plugin dependency, so they stay trivially testable.
/// The solar formula's date arithmetic is easy to get wrong, so it lives here
/// and is tested on its own (architecture §4: `utils/` holds date/UTC helpers).
///
/// Note: this class is named [DateUtils] but imports no Flutter material, so it
/// does not collide with Flutter's own `DateUtils`. Callers use `package:`
/// imports and reference this class directly.
abstract final class DateUtils {
  /// The UTC midnight (00:00:00.000) of [instant]'s **UTC** calendar date.
  ///
  /// Used as the midnight fallback anchor for a polar day and as the base date
  /// for the sunrise math. Always returns a UTC value.
  static DateTime startOfDayUtc(DateTime instant) {
    final utc = instant.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  /// The UTC date [days] before (negative) or after (positive) [date]'s date.
  ///
  /// Keeps the result in UTC and drops any time-of-day. Used to reach
  /// yesterday's and tomorrow's dates when resolving the day span.
  static DateTime addDays(DateTime date, int days) {
    final utc = date.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day + days);
  }

  /// The Julian Day Number for the NOAA formula, taken at the UTC date's noon.
  ///
  /// Uses the standard Fliegel–Van Flandern expression. Only the year/month/day
  /// of [dateUtc] are used; the returned value is the JD at 12:00 UT that date,
  /// e.g. 2000-01-01 → 2451545.0 (the J2000.0 epoch).
  static double julianDay(DateTime dateUtc) {
    final utc = dateUtc.toUtc();
    final y = utc.year;
    final m = utc.month;
    final d = utc.day;

    // Fliegel–Van Flandern integer algorithm for the JDN at noon.
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    final jdn =
        d +
        ((153 * mm + 2) / 5).floor() +
        365 * yy +
        (yy / 4).floor() -
        (yy / 100).floor() +
        (yy / 400).floor() -
        32045;
    return jdn.toDouble();
  }
}
