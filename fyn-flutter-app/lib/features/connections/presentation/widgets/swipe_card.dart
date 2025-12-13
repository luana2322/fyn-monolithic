import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';
import '../../data/models/meetup_model.dart';

/// Swipe card widget for discover screen
/// Displays user profile with photo, name, bio, and interest badges
class SwipeCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onSuperlike;
  final VoidCallback? onTap;

  const SwipeCard({
    super.key,
    required this.match,
    this.onLike,
    this.onDislike,
    this.onSuperlike,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = match.user;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background photo
              _buildPhoto(user),
              // Gradient overlay for text readability
              _buildGradientOverlay(),
              // User info overlay
              _buildInfoOverlay(context, user),
              // Match score badge
              _buildMatchScoreBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(UserPreview user) {
    if (user.primaryPhoto != null) {
      return Image.network(
        user.primaryPhoto!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(user),
      );
    }
    return _buildPlaceholder(user);
  }

  Widget _buildPlaceholder(UserPreview user) {
    // Generate color from username hash
    final colors = [
      Colors.purple.shade400,
      Colors.blue.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
    ];
    final color = colors[user.username.hashCode % colors.length];
    
    return Container(
      color: color,
      child: Center(
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildInfoOverlay(BuildContext context, UserPreview user) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and age
          Row(
            children: [
              Expanded(
                child: Text(
                  '${user.displayName}${user.age != null ? ', ${user.age}' : ''}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black26),
                    ],
                  ),
                ),
              ),
              if (match.distanceKm > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${match.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          const SizedBox(height: 12),
          // Common interests
          if (match.commonInterests.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: match.commonInterests.take(4).map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchScoreBadge(BuildContext context) {
    // Determine color based on match score
    Color badgeColor;
    if (match.matchScore >= 80) {
      badgeColor = Colors.green;
    } else if (match.matchScore >= 60) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.grey;
    }

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              '${match.matchScore.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Connection type tab chip widget
class ConnectionTypeChip extends StatelessWidget {
  final ConnectionType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const ConnectionTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor 
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipe action buttons (Like, Dislike, Superlike)
class SwipeActionButtons extends StatelessWidget {
  final VoidCallback? onDislike;
  final VoidCallback? onLike;
  final VoidCallback? onSuperlike;
  final bool isLoading;

  const SwipeActionButtons({
    super.key,
    this.onDislike,
    this.onLike,
    this.onSuperlike,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dislike button
        _ActionButton(
          icon: Icons.close,
          color: Colors.red.shade400,
          size: 54,
          onTap: isLoading ? null : onDislike,
        ),
        // Superlike button
        _ActionButton(
          icon: Icons.star,
          color: Colors.blue.shade400,
          size: 44,
          onTap: isLoading ? null : onSuperlike,
        ),
        // Like button
        _ActionButton(
          icon: Icons.favorite,
          color: Colors.green.shade400,
          size: 54,
          onTap: isLoading ? null : onLike,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.search_off,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
