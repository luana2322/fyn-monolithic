import 'package:flutter/material.dart';
import '../../theme/dating_colors.dart';
import 'app_typography.dart';

/// Premium dating app theme with modern styling.
/// Supports both light and dark modes with smooth, eye-friendly design.
class DatingTheme {
  // ============================================
  // DESIGN TOKENS
  // ============================================
  
  /// Border radius values
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  
  /// Spacing values
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  
  /// Shadow definitions
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
  
  // ============================================
  // LIGHT THEME
  // ============================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: DatingColors.rose,
        onPrimary: Colors.white,
        primaryContainer: DatingColors.roseLight.withValues(alpha: 0.3),
        secondary: DatingColors.indigo,
        onSecondary: Colors.white,
        secondaryContainer: DatingColors.indigoLight.withValues(alpha: 0.3),
        surface: DatingColors.lightSurface,
        onSurface: DatingColors.lightPrimaryText,
        error: DatingColors.error,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: DatingColors.lightBackground,
      
      // AppBar - neutral white with subtle border
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DatingColors.lightNavBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: DatingColors.lightPrimaryText,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DatingColors.lightPrimaryText,
        ),
        iconTheme: IconThemeData(
          color: DatingColors.lightPrimaryText,
        ),
      ),
      
      // TabBar - for top navigation tabs
      tabBarTheme: TabBarThemeData(
        labelColor: DatingColors.rose,
        unselectedLabelColor: DatingColors.lightMutedText,
        indicatorColor: DatingColors.rose,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: DatingColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DatingColors.rose,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DatingColors.rose,
          side: const BorderSide(color: DatingColors.rose, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DatingColors.rose,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DatingColors.rose,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DatingColors.lightSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: DatingColors.rose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: DatingColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: DatingColors.lightMutedText,
          fontSize: 16,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DatingColors.lightSurface,
        selectedItemColor: DatingColors.rose,
        unselectedItemColor: DatingColors.lightMutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: DatingColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Text Theme - using AppTypography
      textTheme: AppTypography.lightTextTheme,
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: DatingColors.lightPrimaryText,
        size: 24,
      ),
      
      // Chip Theme - dating app style chips
      chipTheme: ChipThemeData(
        backgroundColor: DatingColors.lightSurfaceElevated,
        labelStyle: AppTypography.chipText(false),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
  
  // ============================================
  // DARK THEME
  // ============================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: DatingColors.rose,
        onPrimary: Colors.white,
        primaryContainer: DatingColors.roseDark.withValues(alpha: 0.3),
        secondary: DatingColors.indigo,
        onSecondary: Colors.white,
        secondaryContainer: DatingColors.indigoDark.withValues(alpha: 0.3),
        surface: DatingColors.darkSurface,
        onSurface: DatingColors.darkPrimaryText,
        error: DatingColors.error,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: DatingColors.darkBackground,
      
      // AppBar - darker than background for depth
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DatingColors.darkNavBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: DatingColors.darkPrimaryText,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DatingColors.darkPrimaryText,
        ),
        iconTheme: IconThemeData(
          color: DatingColors.darkPrimaryText,
        ),
      ),
      
      // TabBar - for top navigation tabs
      tabBarTheme: TabBarThemeData(
        labelColor: DatingColors.rose,
        unselectedLabelColor: DatingColors.darkMutedText,
        indicatorColor: DatingColors.rose,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: DatingColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DatingColors.rose,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DatingColors.rose,
          side: const BorderSide(color: DatingColors.rose, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DatingColors.rose,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DatingColors.rose,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DatingColors.darkSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: DatingColors.rose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: DatingColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: DatingColors.darkMutedText,
          fontSize: 16,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DatingColors.darkSurface,
        selectedItemColor: DatingColors.rose,
        unselectedItemColor: DatingColors.darkMutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: DatingColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Text Theme - using AppTypography
      textTheme: AppTypography.darkTextTheme,
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: DatingColors.darkPrimaryText,
        size: 24,
      ),
      
      // Chip Theme - dating app style chips
      chipTheme: ChipThemeData(
        backgroundColor: DatingColors.darkSurfaceElevated,
        labelStyle: AppTypography.chipText(true),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
