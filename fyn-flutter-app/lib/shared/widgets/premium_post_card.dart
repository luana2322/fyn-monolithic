import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/dating_colors.dart';
import '../themes/dating_theme.dart';

/// Premium social feed post card with modern styling.
class PremiumPostCard extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final String? authorUsername;
  final DateTime? postedAt;
  final String? content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onMoreOptions;

  const PremiumPostCard({
    super.key,
    required this.authorName,
    this.authorAvatar,
    this.authorUsername,
    this.postedAt,
    this.content,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onAuthorTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? DatingColors.darkSurface 
            : DatingColors.lightSurface,
        borderRadius: BorderRadius.circular(DatingTheme.radiusMd),
        boxShadow: isDark ? null : DatingTheme.softShadow,
        border: isDark 
            ? Border.all(color: DatingColors.darkBorder)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          _buildHeader(context, theme, isDark),
          
          // Content
          if (content != null && content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                content!,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          
          // Image
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            _buildImage(),
          ],
          
          // Engagement stats
          _buildStats(context, theme, isDark),
          
          // Divider
          Divider(
            height: 1,
            color: isDark 
                ? DatingColors.darkDivider 
                : DatingColors.lightDivider,
          ),
          
          // Action buttons
          _buildActions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onAuthorTap,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: isDark 
                  ? DatingColors.darkSurfaceElevated 
                  : DatingColors.lightSurfaceElevated,
              backgroundImage: authorAvatar != null
                  ? CachedNetworkImageProvider(authorAvatar!)
                  : null,
              child: authorAvatar == null
                  ? Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? DatingColors.darkPrimaryText 
                            : DatingColors.lightPrimaryText,
                      ),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name and time
          Expanded(
            child: GestureDetector(
              onTap: onAuthorTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatTime(postedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark 
                          ? DatingColors.darkMutedText 
                          : DatingColors.lightMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // More options
          IconButton(
            onPressed: onMoreOptions,
            icon: Icon(
              Icons.more_horiz,
              color: isDark 
                  ? DatingColors.darkSecondaryText 
                  : DatingColors.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: DatingColors.lightSurfaceElevated,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DatingColors.rose,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: DatingColors.lightSurfaceElevated,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: DatingColors.lightMutedText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, ThemeData theme, bool isDark) {
    if (likeCount == 0 && commentCount == 0) {
      return const SizedBox(height: 12);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (likeCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: DatingColors.rose,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatCount(likeCount),
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark 
                    ? DatingColors.darkSecondaryText 
                    : DatingColors.lightSecondaryText,
              ),
            ),
          ],
          const Spacer(),
          if (commentCount > 0)
            Text(
              '$commentCount ${commentCount == 1 ? 'comment' : 'comments'}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark 
                    ? DatingColors.darkSecondaryText 
                    : DatingColors.lightSecondaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Like',
            isActive: isLiked,
            activeColor: DatingColors.rose,
            onTap: onLike,
            isDark: isDark,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Comment',
            onTap: onComment,
            isDark: isDark,
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: onShare,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive 
        ? (activeColor ?? DatingColors.rose)
        : (isDark 
            ? DatingColors.darkSecondaryText 
            : DatingColors.lightSecondaryText);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
