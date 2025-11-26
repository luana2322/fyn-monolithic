import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/post_media.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isOwnPost;
  final VoidCallback? onDelete;
  final VoidCallback? onTapProfile;
  final Future<void> Function()? onToggleReaction;
  final VoidCallback? onOpenComments;
  final String? currentUserAvatarUrl;
  final String? currentUsername;

  const PostCard({
    super.key,
    required this.post,
    this.isOwnPost = false,
    this.onDelete,
    this.onTapProfile,
    this.onToggleReaction,
    this.onOpenComments,
    this.currentUserAvatarUrl,
    this.currentUsername,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isReacting = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final author = post.author;
    final avatarUrl = ImageUtils.getAvatarUrl(author.profile.avatarUrl);
    final createdAt = post.createdAt != null
        ? app_date_utils.DateUtils.formatReadable(post.createdAt!)
        : '';
    final PostMedia? primaryMedia = _primaryMedia();

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onTapProfile,
                  child: _storyRing(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              author.username.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 16,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                      ),
                      // Hiển thị bio hoặc fullName như title (ví dụ: "Product Designer, slothUI")
                      if (author.profile.bio != null && author.profile.bio!.isNotEmpty)
                        Text(
                          author.profile.bio!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (author.fullName != null && author.fullName!.isNotEmpty)
                        Text(
                          author.fullName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: Colors.black87,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.isOwnPost
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                                    title: const Text('Xóa bài viết'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      widget.onDelete?.call();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      : () {
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
          
          // Text Content với hashtags
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildTextWithHashtags(post.content),
            ),
          
          // Media Content
          _PostMediaView(media: primaryMedia),
          
          // Engagement Metrics (Likes, Comments, Share, Bookmark)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like button - có thể click
                GestureDetector(
                  onTap: widget.onToggleReaction != null && !_isReacting
                      ? _handleToggleReaction
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        post.likedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: post.likedByCurrentUser
                            ? Colors.redAccent
                            : AppColors.primaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: post.likedByCurrentUser
                              ? Colors.redAccent
                              : AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Comment button - có thể click
                GestureDetector(
                  onTap: widget.onOpenComments,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mode_comment_outlined,
                        size: 18,
                        color: AppColors.primaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '187 Share',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.bookmark_border, size: 20),
                  color: Colors.black87,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Comment Input Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: widget.currentUserAvatarUrl != null
                      ? NetworkImage(widget.currentUserAvatarUrl!)
                      : null,
                  child: widget.currentUserAvatarUrl == null
                      ? Text(
                          (widget.currentUsername ?? 'U').substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Write your comment...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 14),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(Icons.attach_file, size: 18),
                          color: Colors.grey.shade600,
                          onPressed: () {},
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(Icons.emoji_emotions_outlined, size: 18),
                          color: Colors.grey.shade600,
                          onPressed: () {},
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(Icons.send, size: 18),
                          color: Colors.blue,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE0E0E0), thickness: 0.5),
        ],
      ),
    );
  }

  Future<void> _handleToggleReaction() async {
    if (widget.onToggleReaction == null) return;
    setState(() => _isReacting = true);
    try {
      await widget.onToggleReaction!.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReacting = false);
      }
    }
  }

  PostMedia? _primaryMedia() {
    final mediaList = widget.post.media;
    if (mediaList.isEmpty) return null;
    return mediaList.firstWhere(
      (media) => media.isImage,
      orElse: () => mediaList.first,
    );
  }

  Widget _buildTextWithHashtags(String text) {
    // Regex để tìm hashtags (#hashtag)
    final hashtagRegex = RegExp(r'#\w+');
    final parts = <TextSpan>[];
    int lastIndex = 0;

    for (final match in hashtagRegex.allMatches(text)) {
      // Text trước hashtag
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryText,
            height: 1.4,
          ),
        ));
      }

      // Hashtag với màu xanh
      parts.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ));

      lastIndex = match.end;
    }

    // Text còn lại sau hashtag cuối
    if (lastIndex < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryText,
          height: 1.4,
        ),
      ));
    }

    // Nếu không có hashtag, hiển thị text bình thường
    if (parts.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryText,
          height: 1.4,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: parts),
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

class _PostMediaView extends StatefulWidget {
  const _PostMediaView({this.media});

  final PostMedia? media;

  static const double _defaultHeight = 360;

  @override
  State<_PostMediaView> createState() => _PostMediaViewState();
}

class _PostMediaViewState extends State<_PostMediaView> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  bool _isVideoPlaying = false;
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _PostMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media?.resolvedUrl != widget.media?.resolvedUrl) {
      _disposeVideo();
      _initVideoIfNeeded();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _isVideoError = false;
    _isVideoPlaying = false;
    _hasUserInteracted = false;
  }

  void _videoListener() {
    if (_videoController != null && mounted) {
      final isPlaying = _videoController!.value.isPlaying;
      if (isPlaying != _isVideoPlaying) {
        setState(() {
          _isVideoPlaying = isPlaying;
        });
      }
    }
  }

  Future<void> _initVideoIfNeeded() async {
    if (widget.media == null ||
        !widget.media!.isVideo ||
        widget.media!.resolvedUrl == null) {
      return;
    }

    final url = widget.media!.resolvedUrl!;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    controller.addListener(_videoListener);
    _videoController = controller;
    try {
      await controller.initialize();
      controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoPlaying = false; // Không tự động phát (web autoplay policy)
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double mediaHeight = _calculateHeight(context);

    return Container(
      height: mediaHeight,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  double _calculateHeight(BuildContext context) {
    if (!kIsWeb) return _PostMediaView._defaultHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return _PostMediaView._defaultHeight;
    final target = screenHeight / 3;
    return math.max(280, math.min(target, 520));
  }

  Widget _buildContent() {
    final media = widget.media;
    if (media == null) {
      return _placeholder(icon: Icons.insert_photo_outlined);
    }

    if (media.isImage && media.resolvedUrl != null) {
      return Image.network(
        media.resolvedUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _placeholder(icon: Icons.broken_image_outlined),
      );
    }

    if (media.isVideo) {
      if (_isVideoError || _videoController == null) {
        return _placeholder(icon: Icons.videocam_off_outlined);
      }
      if (!_isVideoInitialized) {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }
      return GestureDetector(
        onTap: () {
          if (_videoController == null || !_isVideoInitialized) return;
          
          // Đánh dấu user đã tương tác
          if (!_hasUserInteracted) {
            setState(() => _hasUserInteracted = true);
          }
          
          // Toggle play/pause
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
          } else {
            _videoController!.play().then((_) {
              if (mounted) {
                setState(() => _isVideoPlaying = true);
              }
            }).catchError((e) {
              debugPrint('Error playing video: $e');
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width > 0
                    ? _videoController!.value.size.width
                    : double.infinity,
                height: _videoController!.value.size.height > 0
                    ? _videoController!.value.size.height
                    : double.infinity,
                child: VideoPlayer(_videoController!),
              ),
            ),
            if (!_isVideoPlaying)
              Container(
                color: Colors.black26,
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 64,
                ),
              ),
          ],
        ),
      );
    }

    return _placeholder(icon: Icons.insert_drive_file_outlined);
  }

  Widget _placeholder({required IconData icon}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFfdfbfb),
            Color(0xFFebedee),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 56,
          color: Colors.black26,
        ),
      ),
    );
  }
}

