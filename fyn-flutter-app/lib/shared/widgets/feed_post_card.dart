import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../theme/dating_colors.dart';
import '../themes/dating_theme.dart';

/// Premium social feed post card with modern, clean styling.
/// Uses neutral colors for default states, accent only for active interactions.
class FeedPostCard extends StatefulWidget {
  final String authorName;
  final String? authorAvatar;
  final String? authorUsername;
  final DateTime? postedAt;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onMoreOptions;

  const FeedPostCard({
    super.key,
    required this.authorName,
    this.authorAvatar,
    this.authorUsername,
    this.postedAt,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onAuthorTap,
    this.onMoreOptions,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: isDark 
            ? DatingColors.darkSurface 
            : DatingColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark 
            ? Border.all(color: DatingColors.darkBorder, width: 0.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            _buildHeader(context, theme, isDark),
            
            // Content text
            if (widget.content != null && widget.content!.isNotEmpty)
              _buildContent(context, isDark),
            
            // Media (image/video)
            if (widget.imageUrl != null || widget.videoUrl != null)
              _buildMedia(context, isDark),
            
            // Engagement section
            _buildEngagement(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: widget.onAuthorTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark 
                      ? DatingColors.darkBorder 
                      : DatingColors.lightBorder,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: widget.authorAvatar != null
                    ? CachedNetworkImage(
                        imageUrl: widget.authorAvatar!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _avatarPlaceholder(isDark),
                        errorWidget: (_, __, ___) => _avatarPlaceholder(isDark),
                      )
                    : _avatarPlaceholder(isDark),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name and time
          Expanded(
            child: GestureDetector(
              onTap: widget.onAuthorTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.authorName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(widget.postedAt),
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
            onPressed: widget.onMoreOptions,
            icon: Icon(
              Icons.more_horiz,
              color: isDark 
                  ? DatingColors.darkSecondaryText 
                  : DatingColors.lightSecondaryText,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(bool isDark) {
    return Container(
      color: isDark 
          ? DatingColors.darkSurfaceElevated 
          : DatingColors.lightSurfaceElevated,
      child: Center(
        child: Text(
          widget.authorName.isNotEmpty 
              ? widget.authorName[0].toUpperCase() 
              : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark 
                ? DatingColors.darkPrimaryText 
                : DatingColors.lightPrimaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _buildTextWithHashtags(
          widget.content!,
          isDark,
        ),
      ),
    );
  }

  Widget _buildTextWithHashtags(String text, bool isDark) {
    final hashtagRegex = RegExp(r'#\w+');
    final parts = <TextSpan>[];
    int lastIndex = 0;

    final defaultStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: isDark 
          ? DatingColors.darkPrimaryText 
          : DatingColors.lightPrimaryText,
    );

    for (final match in hashtagRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }

      parts.add(TextSpan(
        text: match.group(0),
        style: defaultStyle.copyWith(
          color: DatingColors.link,
          fontWeight: FontWeight.w500,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    if (parts.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    return RichText(text: TextSpan(children: parts));
  }

  Widget _buildMedia(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark 
            ? DatingColors.darkSurfaceElevated 
            : DatingColors.lightSurfaceElevated,
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: widget.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _mediaPlaceholder(isDark, Icons.image),
                errorWidget: (_, __, ___) => _mediaPlaceholder(isDark, Icons.broken_image_outlined),
              )
            : _mediaPlaceholder(isDark, Icons.play_circle_outline),
      ),
    );
  }

  Widget _mediaPlaceholder(bool isDark, IconData icon) {
    return Container(
      color: isDark 
          ? DatingColors.darkSurfaceElevated 
          : DatingColors.lightSurfaceElevated,
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: isDark 
              ? DatingColors.darkMutedText 
              : DatingColors.lightMutedText,
        ),
      ),
    );
  }

  Widget _buildEngagement(BuildContext context, ThemeData theme, bool isDark) {
    final iconColor = isDark 
        ? DatingColors.feedIconDefaultDark 
        : DatingColors.feedIconDefault;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Row(
        children: [
          // Like button
          _EngagementButton(
            icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
            label: _formatCount(widget.likeCount),
            isActive: widget.isLiked,
            activeColor: DatingColors.rose,
            inactiveColor: iconColor,
            onTap: widget.onLike,
          ),
          
          const SizedBox(width: 4),
          
          // Comment button
          _EngagementButton(
            icon: Icons.chat_bubble_outline,
            label: _formatCount(widget.commentCount),
            inactiveColor: iconColor,
            onTap: widget.onComment,
          ),
          
          const SizedBox(width: 4),
          
          // Share button
          _EngagementButton(
            icon: Icons.share_outlined,
            label: widget.shareCount > 0 ? _formatCount(widget.shareCount) : null,
            inactiveColor: iconColor,
            onTap: widget.onShare,
          ),
          
          const Spacer(),
          
          // Bookmark button
          _EngagementButton(
            icon: widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            isActive: widget.isBookmarked,
            activeColor: DatingColors.indigo,
            inactiveColor: iconColor,
            onTap: widget.onBookmark,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }

  String _formatCount(int count) {
    if (count < 1) return '';
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isActive;
  final Color? activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  const _EngagementButton({
    required this.icon,
    this.label,
    this.isActive = false,
    this.activeColor,
    required this.inactiveColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (activeColor ?? inactiveColor) : inactiveColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (label != null && label!.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
