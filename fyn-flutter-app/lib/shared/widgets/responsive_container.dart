import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// A responsive container that centers content and constrains width
/// based on screen size. Use this as a wrapper for main content areas.
class ResponsiveContainer extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;

  /// Maximum width constraint (default: 600)
  final double maxWidth;

  /// Background color (optional)
  final Color? backgroundColor;

  /// Padding (optional, defaults to responsive horizontal padding)
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      color: backgroundColor,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : maxWidth,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A responsive scaffold that applies consistent layout patterns
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final double maxContentWidth;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.maxContentWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: ResponsiveContainer(
        maxWidth: maxContentWidth,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
