import 'package:flutter/material.dart';

/// Responsive utilities for adapting UI based on screen size.
/// Supports mobile, tablet, and desktop breakpoints.
class ResponsiveUtils {
  /// Mobile breakpoint (< 600px)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint (600px - 1200px)
  static const double tabletBreakpoint = 900;

  /// Desktop breakpoint (>= 1200px)
  static const double desktopBreakpoint = 1200;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Returns appropriate content width based on screen size.
  /// Mobile: full width, Tablet: 80%, Desktop: constrained max-width
  static double getContentWidth(BuildContext context, {double maxWidth = 600}) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width;
    if (width < desktopBreakpoint) return width * 0.8;
    return maxWidth;
  }

  /// Returns responsive padding based on screen size
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// Returns responsive font scale factor
  static double getFontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 1.0;
    if (width < desktopBreakpoint) return 1.05;
    return 1.1;
  }
}
