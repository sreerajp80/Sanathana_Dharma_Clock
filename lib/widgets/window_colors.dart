import 'package:flutter/material.dart';

import '../models/muhurta_window.dart';
import '../theme/app_theme.dart';

/// The display colour for a named window, shared by the Muhurta & Kalas tab
/// and the clock dial's arcs so the two always agree.
///
/// Pure UI mapping (label/kind → colour) with no business logic, so it lives
/// in the widgets layer. It reads the language-free [MuhurtaWindow.label], so
/// the colours stay the same in every language.
Color windowColor(MuhurtaWindow window) {
  switch (window.label) {
    case WindowLabel.rahuKala:
      return AppTheme.rahuKalam;
    case WindowLabel.yamagandaKala:
      return AppTheme.yamaganda;
    case WindowLabel.gulikaKala:
      return AppTheme.gulikaKalam;
    case WindowLabel.muhurta:
    case WindowLabel.abhijit:
      return window.kind == WindowKind.auspicious
          ? AppTheme.auspicious
          : AppTheme.muted;
  }
}
