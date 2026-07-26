/// Technical constants used across the app: `shared_preferences` keys and the
/// fixed numbers of the dharma-time system.
///
/// Grouped here so keys and thresholds live in one place and later phases do not
/// hard-code literals. Not instantiable.
abstract final class AppConstants {
  // --- shared_preferences keys ---

  /// The single saved location record (a JSON string).
  static const String prefSavedLocation = 'saved_location';

  /// Whether the clock uses live GPS (`true`) or the saved location (`false`).
  static const String prefUseLiveLocation = 'use_live_location';

  // --- dharma-time nesting (idea doc §1) ---

  /// A full day is 60 Ghaṭikā.
  static const int ghatikaPerDay = 60;

  /// One Ghaṭikā is 60 Vināḍī.
  static const int vinadiPerGhatika = 60;

  /// One Vināḍī is 6 Prāṇa.
  static const int pranaPerVinadi = 6;

  /// A full day is 30 Muhūrta.
  static const int muhurtaPerDay = 30;

  // --- solar thresholds ---

  /// Seconds in a civil day. Used as the fixed span fallback for a polar day
  /// with no sunrise (idea doc §6).
  static const int secondsPerDay = 86400;
}
