import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppTypography {
  // Inter hoặc Roboto là lựa chọn an toàn. Nếu được, hãy dùng 'Inter' hoặc 'Nunito'
  static const String fontFamily = 'Inter';

  static TextTheme get light => const TextTheme(
        // Dùng cho tiêu đề lớn (Splash screen, Auth)
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5),
        
        // Dùng cho tiêu đề trang (Newsfeed, Profile)
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryText, letterSpacing: -0.5),
        
        // Dùng cho tên người dùng trong bài post
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        
        // Body text - Nội dung bài viết
        bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: AppColors.primaryText, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: AppColors.secondaryText),
        
        // Caption, Timestamp
        bodySmall: TextStyle(fontSize: 12, color: AppColors.tertiaryText, fontWeight: FontWeight.w500),
        
        // Nút bấm
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      );

  static TextTheme get dark => light.apply(
        bodyColor: const Color(0xFFE2E8F0),
        displayColor: Colors.white,
      );
}