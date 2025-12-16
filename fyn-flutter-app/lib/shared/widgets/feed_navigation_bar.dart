import 'package:flutter/material.dart';
import '../../theme/dating_colors.dart';

/// Premium top navigation bar with neutral background and subtle border.
/// Active tab uses accent color, inactive tabs use muted colors.
class FeedNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final List<Widget>? actions;
  final Widget? leading;
  final String? title;

  const FeedNavigationBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.actions,
    this.leading,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? DatingColors.darkNavBackground 
            : DatingColors.lightNavBackground,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? DatingColors.darkNavBorder 
                : DatingColors.lightNavBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with title and actions
            if (title != null || leading != null || actions != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    if (leading != null) leading!,
                    if (title != null) ...[
                      if (leading != null) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark 
                                ? DatingColors.darkPrimaryText 
                                : DatingColors.lightPrimaryText,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            
            // Tab bar
            SizedBox(
              height: 44,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTabSelected?.call(index),
                      behavior: HitTestBehavior.opaque,
                      child: _TabItem(
                        label: tabs[index],
                        isSelected: isSelected,
                        isDark: isDark,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? DatingColors.rose
                    : (isDark 
                        ? DatingColors.darkMutedText 
                        : DatingColors.lightMutedText),
              ),
            ),
          ),
        ),
        // Indicator line
        Container(
          height: 2.5,
          width: 40,
          decoration: BoxDecoration(
            color: isSelected ? DatingColors.rose : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// Simple app bar header for feed screens with neutral styling.
class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;

  const FeedAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.height = 56,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: isDark 
            ? DatingColors.darkNavBackground 
            : DatingColors.lightNavBackground,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? DatingColors.darkNavBorder 
                : DatingColors.lightNavBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else
            const SizedBox(width: 16),
          
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? DatingColors.darkPrimaryText 
                      : DatingColors.lightPrimaryText,
                ),
              ),
            )
          else
            const Spacer(),
          
          if (actions != null) ...[
            ...actions!,
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}
