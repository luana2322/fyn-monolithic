import 'package:flutter/material.dart';

/// Global color system inspired by Reply (Reply Blue / Reply Orange).
class AppColors {
  // Core palette
  static const Color primary = Color(0xFF344955); // Reply Blue 700
  static const Color primaryDark = Color(0xFF23323D);
  static const Color primaryLight = Color(0xFF4F6572);

  static const Color secondary = Color(0xFFF9AA33); // Reply Orange 500
  static const Color secondaryDark = Color(0xFFCC861E);
  static const Color secondaryLight = Color(0xFFFFC76A);

  // Surfaces / background
  static const Color background = Color(0xFFF2F2F2);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFF8F8F8);

  // Text
  static const Color primaryText = Color(0xFF1F2933);
  static const Color secondaryText = Color(0xFF6B7B8C);
  static const Color muted = Color(0xFF9AA5B1);

  // Borders / dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE5E7EB);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
}

