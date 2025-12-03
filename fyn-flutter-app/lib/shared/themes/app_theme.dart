import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để chỉnh màu status bar
import 'package:fyn_flutter_app/theme/app_colors.dart';
import 'package:fyn_flutter_app/shared/themes/app_typography.dart';
import 'package:fyn_flutter_app/shared/themes/app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      
      // Color Scheme chuẩn Material 3
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.primaryText,
      ),

      // AppBar hiện đại: Nền trắng, Text đen, không bóng (hoặc bóng rất nhẹ khi cuộn)
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2, // Hiệu ứng khi cuộn mới hiện bóng
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText, // Icon và Text màu tối
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w700, 
          color: AppColors.primaryText,
          fontFamily: AppTypography.fontFamily
        ),
        iconTheme: IconThemeData(color: AppColors.primaryText),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Status bar màu đen
      ),

      // Card hiện đại: Border nhẹ, ít bóng
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0, // Flat style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1), // Viền mỏng
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Full width ở mobile thường đẹp hơn
      ),

      // Input field: Bo tròn mềm mại, nền xám nhạt
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24), // Pill shape
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.tertiaryText),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Pill shape button
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          foregroundColor: AppColors.primaryText,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      textTheme: AppTypography.light,
    );
  }

  // Dark Theme (Cấu hình tương tự nhưng màu tối)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: Color(0xFF1E293B), // Slate 800
        background: Color(0xFF0F172A),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
      ),
      
      textTheme: AppTypography.dark,
    );
  }
}