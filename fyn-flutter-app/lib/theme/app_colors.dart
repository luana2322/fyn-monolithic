import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Điều chỉnh để hiện đại hơn
  // Primary: Đổi sang tông Deep Navy Blue hiện đại thay vì Teal cũ kỹ
  static const Color primary = Color(0xFF264653); 
  static const Color primaryDark = Color(0xFF1A323D);
  static const Color primaryLight = Color(0xFF457B9D);

  // Accent: Cam ấm, dùng cho notification hoặc nút hành động chính (Like/CTA)
  static const Color secondary = Color(0xFFE76F51); 
  static const Color secondaryDark = Color(0xFFC65D43);
  static const Color secondaryLight = Color(0xFFF4A261);

  // Background Surfaces
  static const Color background = Color(0xFFFAFAFA); // Gần như trắng, sạch hơn màu xám cũ
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFF5F5F5); // Nền xám nhạt (Liquid feel) - dùng cho input fields, elevated surfaces
  static const Color surfaceHighlight = Color(0xFFF1F5F9); // Dùng cho comment box, card background nhẹ

  // Text Colors
  static const Color primaryText = Color(0xFF1E293B); // Slate 800 - Dễ đọc hơn đen tuyền
  static const Color secondaryText = Color(0xFF64748B); // Slate 500
  static const Color tertiaryText = Color(0xFF94A3B8); // Dùng cho timestamp

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Status
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color error = Color(0xFFEF4444);   // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6);    // Blue 500
}