import 'package:flutter/material.dart';

/// The single source of truth for the app's look: vermillion (sindūr) on chandan
/// (sandalwood), applied through one Material 3 [ThemeData] (architecture §16,
/// idea doc §8).
///
/// Contrast note (WCAG AA): the pure vermillion `#E34234` on the chandan
/// background measures only about 3:1 — fine for large shapes but below the 4.5:1
/// bar for normal text. So text and icons use the darker [vermillionDark]
/// (≈ 5:1 on chandan), while the bright [vermillion] is reserved for the big dial
/// strokes and highlights where AA-large (3:1) is enough.
abstract final class AppTheme {
  AppTheme._();

  /// Chandan / sandalwood — the page and card background.
  static const Color chandan = Color(0xFFF1E4C3);

  /// A slightly deeper chandan for cards, so surfaces read apart from the page.
  static const Color chandanSurface = Color(0xFFF7EED6);

  /// Bright vermillion — dial strokes, hands, and active highlights (large only).
  static const Color vermillion = Color(0xFFE34234);

  /// Darker vermillion — text and icons, meeting AA for normal text on chandan.
  static const Color vermillionDark = Color(0xFFB32D1F);

  /// A muted brown-red for secondary text and faint dial ticks.
  static const Color muted = Color(0xFF7A4A3A);

  // --- window colours: the dial arcs and the Muhurta & Kalas tab tags ---

  /// Deep green — auspicious windows (Abhijit, Brahma Muhūrta).
  static const Color auspicious = Color(0xFF2E7D32);

  /// Deep purple — Rāhu Kālam (far from Yamagaṇḍa's orange and the
  /// vermillion rim, so the arcs never blend).
  static const Color rahuKalam = Color(0xFF6A1B9A);

  /// Burnt orange — Yamagaṇḍa.
  static const Color yamaganda = Color(0xFFE65100);

  /// Strong blue — Gulika Kālam (clearly blue next to Abhijit's green).
  static const Color gulikaKalam = Color(0xFF1565C0);

  /// The single light theme used across every screen.
  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: vermillion,
      brightness: Brightness.light,
    );

    final scheme = base.copyWith(
      primary: vermillionDark,
      onPrimary: chandan,
      secondary: vermillion,
      surface: chandan,
      onSurface: vermillionDark,
      surfaceContainerHighest: chandanSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: chandan,
      appBarTheme: const AppBarTheme(
        backgroundColor: chandan,
        foregroundColor: vermillionDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: chandanSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: vermillionDark,
        displayColor: vermillionDark,
      ),
    );
  }
}
