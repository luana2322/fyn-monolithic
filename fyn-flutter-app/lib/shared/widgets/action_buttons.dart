import 'package:flutter/material.dart';
import '../../theme/dating_colors.dart';
import '../themes/dating_theme.dart';

/// Animated action buttons for swipe interface.
/// Includes Nope (X), Super Like (Star), and Like (Heart).
class SwipeActionButtons extends StatelessWidget {
  final VoidCallback? onNope;
  final VoidCallback? onSuperLike;
  final VoidCallback? onLike;
  final bool showLabels;

  const SwipeActionButtons({
    super.key,
    this.onNope,
    this.onSuperLike,
    this.onLike,
    this.showLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nope Button
        _ActionButton(
          icon: Icons.close_rounded,
          color: DatingColors.nope,
          size: 56,
          onTap: onNope,
          label: showLabels ? 'Nope' : null,
        ),
        
        const SizedBox(width: 24),
        
        // Super Like Button
        _ActionButton(
          icon: Icons.star_rounded,
          color: DatingColors.superLike,
          size: 48,
          onTap: onSuperLike,
          label: showLabels ? 'Super' : null,
        ),
        
        const SizedBox(width: 24),
        
        // Like Button
        _ActionButton(
          icon: Icons.favorite_rounded,
          color: DatingColors.rose,
          size: 56,
          onTap: onLike,
          label: showLabels ? 'Like' : null,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final String? label;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onTap,
    this.label,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: isDark 
                    ? DatingColors.darkSurface 
                    : DatingColors.lightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? DatingColors.darkSecondaryText
                  : DatingColors.lightSecondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

/// Individual action button that can be used standalone
class DatingActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  const DatingActionButton({
    super.key,
    required this.icon,
    required this.color,
    this.size = 56,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = _ActionButton(
      icon: icon,
      color: color,
      size: size,
      onTap: onTap,
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}
