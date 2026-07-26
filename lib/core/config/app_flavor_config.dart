/// The build flavor this app was compiled for.
enum AppFlavor { dev, prod }

/// Reads the active build flavor and exposes flavor-based settings.
///
/// It resolves the flavor from two compile-time environment variables, in
/// priority order:
///   1. `APP_FLAVOR` — a custom, non-reserved name (used by desktop builds via
///      `--dart-define=APP_FLAVOR=<value>`). Not used on Android today, but the
///      two-variable pattern is kept so the class works everywhere.
///   2. `FLUTTER_APP_FLAVOR` — auto-injected by Flutter on Android/iOS when
///      `--flavor` is passed. Defaults to `prod` so an unflavored build still
///      has a deterministic value.
class AppFlavorConfig {
  AppFlavorConfig._(this.flavor);

  static const _appFlavorValue = String.fromEnvironment('APP_FLAVOR');

  static const _frameworkFlavorValue = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'prod',
  );

  static String _resolved() =>
      _appFlavorValue.isNotEmpty ? _appFlavorValue : _frameworkFlavorValue;

  static final AppFlavorConfig instance = AppFlavorConfig._(
    _parse(_resolved()),
  );

  final AppFlavor flavor;

  static AppFlavor _parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      case 'prod':
      default:
        return AppFlavor.prod;
    }
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  /// Human-readable name, matching the Android `app_name` flavor resource.
  String get appName =>
      isDev ? 'Sanathana Dharma Clock Dev' : 'Sanathana Dharma Clock';

  /// Verbose logging is on in dev, off in prod.
  bool get enableVerboseLogging => isDev;
}
