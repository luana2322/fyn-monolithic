import 'package:flutter/material.dart';

/// Modern dating app color system with light and dark mode support.
/// Designed for emotional, friendly, and premium dating experience.
class DatingColors {
  // ============================================
  // LIGHT MODE COLORS
  // ============================================
  
  // Light mode backgrounds
  static const Color lightBackground = Color(0xFFF8F9FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  
  // Light mode navigation (same as surface for clean look)
  static const Color lightNavBackground = Color(0xFFFFFFFF);
  static const Color lightNavBorder = Color(0xFFE5E7EB);
  
  // Light mode text
  static const Color lightPrimaryText = Color(0xFF1F2937);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightMutedText = Color(0xFF9CA3AF);
  
  // Light mode borders
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);
  
  // ============================================
  // DARK MODE COLORS
  // ============================================
  
  // Dark mode backgrounds - improved contrast
  static const Color darkBackground = Color(0xFF18191A);  // Facebook-style dark bg
  static const Color darkSurface = Color(0xFF242526);      // Elevated card bg
  static const Color darkSurfaceElevated = Color(0xFF3A3B3C); // Input/button bg
  
  // Dark mode navigation
  static const Color darkNavBackground = Color(0xFF242526);
  static const Color darkNavBorder = Color(0xFF3A3B3C);
  
  // Dark mode text
  static const Color darkPrimaryText = Color(0xFFE4E6EB);
  static const Color darkSecondaryText = Color(0xFFB0B3B8);
  static const Color darkMutedText = Color(0xFF8A8D91);
  
  // Dark mode borders
  static const Color darkBorder = Color(0xFF3E4042);
  static const Color darkDivider = Color(0xFF3E4042);
  
  // ============================================
  // ACCENT COLORS (Same for both modes)
  // ============================================
  
  /// Primary accent - Rose/Pink for like, match, love actions
  static const Color rose = Color(0xFFF43F5E);
  static const Color roseLight = Color(0xFFFDA4AF);
  static const Color roseDark = Color(0xFFE11D48);
  
  /// Secondary accent - Indigo for secondary actions
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight = Color(0xFFA5B4FC);
  static const Color indigoDark = Color(0xFF4F46E5);
  
  /// Super Like - Gold/Amber
  static const Color superLike = Color(0xFFF59E0B);
  static const Color superLikeLight = Color(0xFFFCD34D);
  
  /// Nope - Gray
  static const Color nope = Color(0xFF6B7280);
  
  /// Online indicator
  static const Color online = Color(0xFF10B981);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // ============================================
  // FEED SPECIFIC COLORS (Neutral, calm)
  // ============================================
  
  /// Neutral icon color for feed actions (not liked state)
  static const Color feedIconDefault = Color(0xFF6B7280);
  static const Color feedIconDefaultDark = Color(0xFF9CA3AF);
  
  /// Link/hashtag color
  static const Color link = Color(0xFF2563EB);
  
  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get background color based on brightness
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? darkBackground : lightBackground;
  
  /// Get surface color based on brightness
  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;
  
  /// Get elevated surface color based on brightness
  static Color surfaceElevated(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurfaceElevated : lightSurfaceElevated;
  
  /// Get primary text color based on brightness
  static Color primaryText(Brightness brightness) =>
      brightness == Brightness.dark ? darkPrimaryText : lightPrimaryText;
  
  /// Get secondary text color based on brightness
  static Color secondaryText(Brightness brightness) =>
      brightness == Brightness.dark ? darkSecondaryText : lightSecondaryText;
  
  /// Get border color based on brightness
  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : lightBorder;
  
  /// Get divider color based on brightness
  static Color divider(Brightness brightness) =>
      brightness == Brightness.dark ? darkDivider : lightDivider;
}

/// Extension to easily access dating colors from BuildContext
extension DatingColorsExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get backgroundColor => DatingColors.background(Theme.of(this).brightness);
  Color get surfaceColor => DatingColors.surface(Theme.of(this).brightness);
  Color get primaryTextColor => DatingColors.primaryText(Theme.of(this).brightness);
  Color get secondaryTextColor => DatingColors.secondaryText(Theme.of(this).brightness);
  Color get borderColor => DatingColors.border(Theme.of(this).brightness);
}
