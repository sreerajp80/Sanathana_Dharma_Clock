import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'app_config.dart';

/// Loads the About-screen values from `assets/config/app_config.json`.
///
/// It always degrades to [AppConfig.fallback] on any error, so a missing or
/// malformed config never crashes the app.
///
/// Note on version checking: this app does not use `package_info_plus` (its web
/// implementation pulls in the `http` package, which the offline rule forbids as
/// a transitive dependency). So [loadAndVerify] compares the config's
/// version/build against values you pass in — for example compile-time
/// `--dart-define` values — instead of reading them from the platform. When no
/// expected values are given, the version check is skipped.
class ConfigService {
  static const String assetPath = 'assets/config/app_config.json';

  final Future<String> Function(String path) _loadAsset;

  ConfigService({Future<String> Function(String path)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  /// Reads the asset, decodes JSON, and returns [AppConfig.fallback] on any
  /// error (missing asset, bad JSON, wrong shape).
  Future<AppConfig> load() async {
    try {
      final text = await _loadAsset(assetPath);
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return AppConfig.fallback;
      return AppConfig.fromJson(decoded);
    } catch (_) {
      return AppConfig.fallback;
    }
  }

  /// Like [load], but additionally logs a non-fatal debug note if the config's
  /// version/build does not match the [expectedVersion]/[expectedBuild] you
  /// pass in. Both are optional; the check is skipped for whichever is null.
  Future<AppConfig> loadAndVerify({
    String? expectedVersion,
    String? expectedBuild,
  }) async {
    final config = await load();
    if (kDebugMode) {
      final versionMismatch =
          expectedVersion != null && expectedVersion != config.version;
      final buildMismatch =
          expectedBuild != null && expectedBuild != config.build;
      if (versionMismatch || buildMismatch) {
        debugPrint(
          'ConfigService: version/build in app_config.json '
          '(${config.version}+${config.build}) does not match the expected '
          'build (${expectedVersion ?? '?'}+${expectedBuild ?? '?'}).',
        );
      }
    }
    return config;
  }
}
