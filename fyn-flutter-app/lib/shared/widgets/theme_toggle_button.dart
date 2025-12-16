import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/dating_colors.dart';
import '../providers/theme_provider.dart';

/// Animated theme toggle button for switching between light and dark mode.
class ThemeToggleButton extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.size = 48,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isDark 
                  ? DatingColors.darkSurfaceElevated 
                  : DatingColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(size / 2),
              border: Border.all(
                color: isDark 
                    ? DatingColors.darkBorder 
                    : DatingColors.lightBorder,
                width: 1.5,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                size: size * 0.5,
                color: isDark 
                    ? DatingColors.superLike 
                    : DatingColors.rose,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 12),
          Text(
            isDark ? 'Dark' : 'Light',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark 
                  ? DatingColors.darkPrimaryText 
                  : DatingColors.lightPrimaryText,
            ),
          ),
        ],
      ],
    );
  }
}

/// Theme toggle switch for settings screen
class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? DatingColors.darkSurface 
            : DatingColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? DatingColors.darkBorder 
              : DatingColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Light mode option
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: themeMode == ThemeMode.light,
            onTap: () => ref.read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.light),
          ),
          const SizedBox(height: 8),
          
          // Dark mode option
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => ref.read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: 8),
          
          // System option
          _ThemeOption(
            icon: Icons.settings_suggest_rounded,
            label: 'System',
            isSelected: themeMode == ThemeMode.system,
            onTap: () => ref.read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? DatingColors.rose.withValues(alpha: 0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? DatingColors.rose 
                : (isDark 
                    ? DatingColors.darkBorder 
                    : DatingColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? DatingColors.rose 
                  : (isDark 
                      ? DatingColors.darkSecondaryText 
                      : DatingColors.lightSecondaryText),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? DatingColors.rose 
                    : (isDark 
                        ? DatingColors.darkPrimaryText 
                        : DatingColors.lightPrimaryText),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: DatingColors.rose,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
