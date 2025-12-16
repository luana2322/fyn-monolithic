import 'package:flutter/material.dart';
import '../../theme/dating_colors.dart';

/// Typography system for the dating-social app.
/// Uses Inter as primary font with SF Pro (iOS) and Roboto (Android) fallbacks.
/// 
/// Design principles:
/// - Clean, rounded sans-serif
/// - Friendly and emotional, not technical
/// - Optimized for mobile reading
class AppTypography {
  // Font family
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = ['SF Pro', 'Roboto', 'sans-serif'];
  
  // ============================================
  // TYPOGRAPHY TOKENS
  // ============================================
  
  /// Username style - visual focus, prominent
  /// 20-22px, weight 600, tracking -0.2
  static TextStyle username(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Section labels (Today, Yesterday, etc.)
  /// 14px, weight 500, color muted
  static TextStyle sectionLabel(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? DatingColors.darkSecondaryText : DatingColors.lightSecondaryText,
  );
  
  /// Post content - readable for long sessions
  /// 15-16px, weight 400, line height 1.5-1.6
  static TextStyle postContent(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Meta text (ID, views, time)
  /// 12-13px, weight 400, muted color
  static TextStyle metaText(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: isDark ? DatingColors.darkSecondaryText : DatingColors.lightSecondaryText,
  );
  
  /// Chip/tag text
  /// 13px, weight 500
  static TextStyle chipText(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Action button text
  /// 14px, weight 500
  static TextStyle actionText(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? DatingColors.darkSecondaryText : DatingColors.lightSecondaryText,
  );
  
  /// Badge text (notifications, counts)
  /// 10px, weight 700
  static TextStyle badgeText() => const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  // ============================================
  // HEADING STYLES
  // ============================================
  
  /// Large heading
  static TextStyle headingLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Medium heading
  static TextStyle headingMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Small heading / title
  static TextStyle headingSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  // ============================================
  // BODY STYLES
  // ============================================
  
  /// Body large
  static TextStyle bodyLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Body medium
  static TextStyle bodyMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
  );
  
  /// Body small
  static TextStyle bodySmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: isDark ? DatingColors.darkSecondaryText : DatingColors.lightSecondaryText,
  );
  
  // ============================================
  // INTERACTIVE STYLES
  // ============================================
  
  /// Button text
  static TextStyle buttonText() => const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  
  /// Link text
  static const TextStyle linkText = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DatingColors.link,
  );
  
  // ============================================
  // FLUTTER TEXTTHEME GENERATION
  // ============================================
  
  /// Generate complete TextTheme for light mode
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: headingLarge(false),
    displayMedium: headingMedium(false),
    displaySmall: headingSmall(false),
    headlineLarge: headingLarge(false),
    headlineMedium: headingMedium(false),
    headlineSmall: headingSmall(false),
    titleLarge: username(false),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: DatingColors.lightPrimaryText,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: DatingColors.lightPrimaryText,
    ),
    bodyLarge: bodyLarge(false),
    bodyMedium: bodyMedium(false),
    bodySmall: bodySmall(false),
    labelLarge: chipText(false),
    labelMedium: sectionLabel(false),
    labelSmall: metaText(false),
  );
  
  /// Generate complete TextTheme for dark mode
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: headingLarge(true),
    displayMedium: headingMedium(true),
    displaySmall: headingSmall(true),
    headlineLarge: headingLarge(true),
    headlineMedium: headingMedium(true),
    headlineSmall: headingSmall(true),
    titleLarge: username(true),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: DatingColors.darkPrimaryText,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: DatingColors.darkPrimaryText,
    ),
    bodyLarge: bodyLarge(true),
    bodyMedium: bodyMedium(true),
    bodySmall: bodySmall(true),
    labelLarge: chipText(true),
    labelMedium: sectionLabel(true),
    labelSmall: metaText(true),
  );
}

/// Extension on BuildContext for easy typography access
extension TypographyExtension on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;
  
  TextStyle get usernameStyle => AppTypography.username(_isDark);
  TextStyle get sectionLabelStyle => AppTypography.sectionLabel(_isDark);
  TextStyle get postContentStyle => AppTypography.postContent(_isDark);
  TextStyle get metaTextStyle => AppTypography.metaText(_isDark);
  TextStyle get chipTextStyle => AppTypography.chipText(_isDark);
  TextStyle get actionTextStyle => AppTypography.actionText(_isDark);
}
