import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/post_media.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isOwnPost;
  final VoidCallback? onDelete;
  final VoidCallback? onTapProfile;

  const PostCard({
    super.key,
    required this.post,
    this.isOwnPost = false,
    this.onDelete,
    this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final avatarUrl = ImageUtils.getAvatarUrl(author.profile.avatarUrl);
    final createdAt = post.createdAt != null
        ? app_date_utils.DateUtils.formatReadable(post.createdAt!)
        : '';
    final PostMedia? primaryMedia = _primaryMedia();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onTapProfile,
                child: _storyRing(
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            author.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwnPost)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa bài viết'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                )
              else
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang phát triển'),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        if (primaryMedia != null && primaryMedia.resolvedUrl != null)
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                primaryMedia.resolvedUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _mediaPlaceholder();
                },
              ),
            ),
          )
        else
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFfdfbfb),
                    Color(0xFFebedee),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: _mediaPlaceholder(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _iconButton(context, icon: Icons.favorite_border),
              _iconButton(context, icon: Icons.mode_comment_outlined),
              _iconButton(context, icon: Icons.send_outlined),
              const Spacer(),
              _iconButton(context, icon: Icons.bookmark_border),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${post.likeCount} lượt thích',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade900, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${author.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.content),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${post.commentCount} bình luận',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            createdAt,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }

  PostMedia? _primaryMedia() {
    if (post.media.isEmpty) return null;
    return post.media.firstWhere(
      (media) => media.isImage,
      orElse: () => post.media.first,
    );
  }

  Widget _mediaPlaceholder() {
    return const Center(
      child: Icon(Icons.image, size: 72, color: Colors.black26),
    );
  }

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.black87),
      splashRadius: 20,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng đang phát triển')),
        );
      },
    );
  }

  static Widget _storyRing({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFEDA75),
            Color(0xFFFA7E1E),
            Color(0xFFD62976),
            Color(0xFF962FBF),
            Color(0xFF4F5BD5),
          ],
        ),
      ),
      child: child,
    );
  }
}
