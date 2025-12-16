import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/dating_colors.dart';
import '../themes/dating_theme.dart';

/// Modern match list tile with avatar, online indicator, and unread badge.
class MatchListTile extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isOnline;
  final int unreadCount;
  final VoidCallback? onTap;

  const MatchListTile({
    super.key,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.isOnline = false,
    this.unreadCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DatingTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: unreadCount > 0
              ? (isDark 
                  ? DatingColors.darkSurfaceElevated 
                  : DatingColors.lightSurfaceElevated)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DatingTheme.radiusSm),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            _buildAvatar(isDark),
            
            const SizedBox(width: 12),
            
            // Name and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: unreadCount > 0 
                          ? FontWeight.w700 
                          : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark 
                            ? DatingColors.darkSecondaryText 
                            : DatingColors.lightSecondaryText,
                        fontWeight: unreadCount > 0 
                            ? FontWeight.w500 
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lastMessageTime != null)
                  Text(
                    _formatTime(lastMessageTime!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: unreadCount > 0 
                          ? DatingColors.rose 
                          : (isDark 
                              ? DatingColors.darkMutedText 
                              : DatingColors.lightMutedText),
                    ),
                  ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DatingColors.rose,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: isDark 
              ? DatingColors.darkSurfaceElevated 
              : DatingColors.lightSurfaceElevated,
          backgroundImage: avatarUrl != null
              ? CachedNetworkImageProvider(avatarUrl!)
              : null,
          child: avatarUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark 
                        ? DatingColors.darkPrimaryText 
                        : DatingColors.lightPrimaryText,
                  ),
                )
              : null,
        ),
        
        // Online indicator
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: DatingColors.online,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark 
                      ? DatingColors.darkBackground 
                      : DatingColors.lightBackground,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}

/// Horizontal scrollable list of match avatars for "New Matches" section
class NewMatchesRow extends StatelessWidget {
  final List<MatchAvatar> matches;
  final VoidCallback? onSeeAll;

  const NewMatchesRow({
    super.key,
    required this.matches,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Matches',
                style: theme.textTheme.titleMedium,
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final match = matches[index];
              return _MatchAvatarItem(
                avatar: match,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class MatchAvatar {
  final String name;
  final String? imageUrl;
  final bool isNew;
  final VoidCallback? onTap;

  const MatchAvatar({
    required this.name,
    this.imageUrl,
    this.isNew = false,
    this.onTap,
  });
}

class _MatchAvatarItem extends StatelessWidget {
  final MatchAvatar avatar;
  final bool isDark;

  const _MatchAvatarItem({
    required this.avatar,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: avatar.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: avatar.isNew
                  ? const LinearGradient(
                      colors: [DatingColors.rose, DatingColors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: avatar.isNew
                  ? null
                  : Border.all(
                      color: isDark 
                          ? DatingColors.darkBorder 
                          : DatingColors.lightBorder,
                      width: 2,
                    ),
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundColor: isDark 
                  ? DatingColors.darkSurface 
                  : DatingColors.lightSurface,
              backgroundImage: avatar.imageUrl != null
                  ? CachedNetworkImageProvider(avatar.imageUrl!)
                  : null,
              child: avatar.imageUrl == null
                  ? Text(
                      avatar.name.isNotEmpty 
                          ? avatar.name[0].toUpperCase() 
                          : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? DatingColors.darkPrimaryText 
                            : DatingColors.lightPrimaryText,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            avatar.name.split(' ').first,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark 
                  ? DatingColors.darkPrimaryText 
                  : DatingColors.lightPrimaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
