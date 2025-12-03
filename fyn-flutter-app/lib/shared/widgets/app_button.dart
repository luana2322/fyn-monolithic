import 'package:flutter/material.dart';
import 'package:fyn_flutter_app/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 50, // Cao hơn một chút cho chuẩn touch target
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = isLoading 
      ? SizedBox(
          height: 20, width: 20, 
          child: CircularProgressIndicator(color: foregroundColor ?? Colors.white, strokeWidth: 2)
        ) 
      : child;

    Widget button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          // Shape đã được định nghĩa trong AppTheme, nhưng có thể override ở đây
        ),
        child: buttonContent,
      ),
    );

    return button;
  }
}
// Giữ nguyên AppOutlinedButton hoặc cập nhật tương tự