import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap; // Thêm tính năng bấm vào card
  final Color? color;
  final Border? border;

  const AppCard({
    super.key, 
    required this.child, 
    this.padding, 
    this.onTap,
    this.color,
    this.border
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Tạo khoảng cách giữa các post
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        // Xóa boxShadow để giao diện phẳng hiện đại, hoặc thêm shadow rất nhẹ
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16), 
            child: child
          ),
        ),
      ),
    );
  }
}