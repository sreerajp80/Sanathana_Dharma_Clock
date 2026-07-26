/// The 7 planetary lords of the Horā (planetary hour) cycle.
///
/// A horā is 1/12 of the daytime (sunrise → sunset) or 1/12 of the night
/// (sunset → next sunrise). The first horā of the day is ruled by the weekday's
/// lord; the following horās step through the fixed [order] and repeat. Because
/// 24 mod 7 = 3, the 25th horā (next sunrise) lands on the next weekday's lord
/// by itself — the table needs no per-day correction.
///
/// This is a pure constant table with no logic beyond an index lookup, so it
/// lives in `core/constants` rather than a service (same as `MuhurtaNames`).
abstract final class HoraNames {
  HoraNames._();

  /// The fixed horā sequence: each hour's ruler, starting from the Sun. This is
  /// the classical order (the descending Chaldean order sampled every hour).
  static const List<String> order = <String>[
    'Sūrya (Sun)',
    'Śukra (Venus)',
    'Budha (Mercury)',
    'Chandra (Moon)',
    'Śani (Saturn)',
    'Guru (Jupiter)',
    'Maṅgala (Mars)',
  ];

  /// Index into [order] of the weekday's lord — the ruler of the first horā of
  /// that day. Keys are `DateTime.weekday` (1 = Monday … 7 = Sunday).
  static const Map<int, int> startIndexByWeekday = <int, int>{
    DateTime.sunday: 0, // Sūrya
    DateTime.monday: 3, // Chandra
    DateTime.tuesday: 6, // Maṅgala
    DateTime.wednesday: 2, // Budha
    DateTime.thursday: 5, // Guru
    DateTime.friday: 1, // Śukra
    DateTime.saturday: 4, // Śani
  };

  /// The ruler of horā [k] (0-based, 0–23) of the day whose
  /// `DateTime.weekday` is [weekday]. Steps through [order] from the weekday's
  /// lord. An unknown weekday falls back to Sunday's lord rather than throwing
  /// (CLAUDE.md hard rule 4).
  static String lordAt(int weekday, int k) {
    final start = startIndexByWeekday[weekday] ?? 0;
    return order[(start + k) % order.length];
  }
}
