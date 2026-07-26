import 'package:flutter/material.dart';

import '../models/muhurta_window.dart';
import '../theme/app_theme.dart';

/// The display colour for a named window, shared by the Muhurta & Kalas tab
/// and the clock dial's arcs so the two always agree.
///
/// Pure UI mapping (name/kind → colour) with no business logic, so it lives in
/// the widgets layer.
Color windowColor(MuhurtaWindow window) {
  switch (window.name) {
    case 'Rāhu Kālam':
      return AppTheme.rahuKalam;
    case 'Yamagaṇḍa':
      return AppTheme.yamaganda;
    case 'Gulika Kālam':
      return AppTheme.gulikaKalam;
    default:
      return window.kind == WindowKind.auspicious
          ? AppTheme.auspicious
          : AppTheme.muted;
  }
}
