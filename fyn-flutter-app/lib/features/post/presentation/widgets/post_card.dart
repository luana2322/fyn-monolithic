import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/dating_colors.dart';
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
  final void Function(String placeCode, String placeName)? onTapPlace;

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
    this.onTapPlace,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? DatingColors.darkSurface : Colors.white,
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
                      backgroundColor: isDark ? DatingColors.darkSurfaceElevated : Colors.white,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              author.username.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                        ),
                      ),
                      // Hiển thị bio hoặc fullName như title (ví dụ: "Product Designer, slothUI")
                      if (author.profile.bio != null && author.profile.bio!.isNotEmpty)
                        Text(
                          author.profile.bio!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (author.fullName != null && author.fullName!.isNotEmpty)
                        Text(
                          author.fullName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, size: 20, color: isDark ? DatingColors.darkPrimaryText : Colors.black87),
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
          
            // Post content
            if (widget.post.content.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTextWithHashtags(
                  widget.post.content,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Location display
            if (widget.post.location != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.near_me,
                      size: 14,
                      color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Gần đây',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Place tag display (clickable)
            if (widget.post.place != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to posts by place screen
                    if (widget.onTapPlace != null) {
                      widget.onTapPlace!(widget.post.place!.code, widget.post.place!.name);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: DatingColors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: DatingColors.indigo,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.place!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DatingColors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (widget.post.location != null || widget.post.place != null)
              const SizedBox(height: 12),

            // Media Content - supports multiple media with carousel
            if (post.media.isNotEmpty)
            _MultiMediaView(mediaList: _getSortedMedia()),
          
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
                            : (isDark ? DatingColors.darkPrimaryText : AppColors.primaryText),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: post.likedByCurrentUser
                              ? Colors.redAccent
                              : (isDark ? DatingColors.darkPrimaryText : AppColors.primaryText),
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
                      Icon(
                        Icons.mode_comment_outlined,
                        size: 18,
                        color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '187 Share',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.bookmark_border, size: 20, color: isDark ? DatingColors.darkPrimaryText : Colors.black87),
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
                  backgroundColor: isDark ? DatingColors.darkSurfaceElevated : Colors.grey.shade300,
                  backgroundImage: widget.currentUserAvatarUrl != null
                      ? NetworkImage(widget.currentUserAvatarUrl!)
                      : null,
                  child: widget.currentUserAvatarUrl == null
                      ? Text(
                          (widget.currentUsername ?? 'U').substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? DatingColors.darkSurfaceElevated : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Write your comment...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                            ),
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
                          icon: Icon(Icons.attach_file, size: 18, color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600),
                          onPressed: () {},
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Icon(Icons.emoji_emotions_outlined, size: 18, color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600),
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
          
          Divider(height: 1, color: isDark ? DatingColors.darkBorder : const Color(0xFFE0E0E0), thickness: 0.5),
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

  /// Get media list sorted by orderIndex
  List<PostMedia> _getSortedMedia() {
    final mediaList = widget.post.media.toList();
    mediaList.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return mediaList;
  }

  Widget _buildTextWithHashtags(String text, {required bool isDark}) {
    final textColor = isDark ? DatingColors.darkPrimaryText : AppColors.primaryText;
    
    // Regex để tìm hashtags (#hashtag)
    final hashtagRegex = RegExp(r'#\w+');
    final parts = <TextSpan>[];
    int lastIndex = 0;

    for (final match in hashtagRegex.allMatches(text)) {
      // Text trước hashtag
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            fontSize: 14,
            color: textColor,
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
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          height: 1.4,
        ),
      ));
    }

    // Nếu không có hashtag, hiển thị text bình thường
    if (parts.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
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

/// Widget to display multiple media items with PageView carousel
class _MultiMediaView extends StatefulWidget {
  final List<PostMedia> mediaList;

  const _MultiMediaView({required this.mediaList});

  static const double _defaultHeight = 360;

  @override
  State<_MultiMediaView> createState() => _MultiMediaViewState();
}

class _MultiMediaViewState extends State<_MultiMediaView> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _calculateHeight(BuildContext context) {
    if (!kIsWeb) return _MultiMediaView._defaultHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return _MultiMediaView._defaultHeight;
    final target = screenHeight / 3;
    return math.max(280, math.min(target, 520));
  }

  @override
  Widget build(BuildContext context) {
    final double mediaHeight = _calculateHeight(context);
    final mediaCount = widget.mediaList.length;

    if (mediaCount == 0) {
      return const SizedBox.shrink();
    }

    // Single media - use simple display
    if (mediaCount == 1) {
      return Container(
        height: mediaHeight,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildMediaItem(widget.mediaList.first, 0),
      );
    }

    // Multiple media - use PageView carousel
    return Column(
      children: [
        Container(
          height: mediaHeight,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: mediaCount,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildMediaItem(widget.mediaList[index], index);
                },
              ),
              // Page indicator dots
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    mediaCount,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Counter badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/$mediaCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaItem(PostMedia media, int index) {
    if (media.isImage && media.resolvedUrl != null) {
      return GestureDetector(
        onTap: () => _openFullscreenViewer(index),
        child: Image.network(
          media.resolvedUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _placeholder(Icons.broken_image_outlined),
        ),
      );
    }

    if (media.isVideo) {
      return _SingleVideoPlayer(media: media);
    }

    return _placeholder(Icons.insert_drive_file_outlined);
  }

  void _openFullscreenViewer(int initialIndex) {
    final imageMediaList = widget.mediaList.where((m) => m.isImage).toList();
    if (imageMediaList.isEmpty) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenImageViewer(
            mediaList: imageMediaList,
            initialIndex: initialIndex.clamp(0, imageMediaList.length - 1),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _placeholder(IconData icon) {
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

/// Video player widget for individual video items in carousel
class _SingleVideoPlayer extends StatefulWidget {
  final PostMedia media;

  const _SingleVideoPlayer({required this.media});

  @override
  State<_SingleVideoPlayer> createState() => _SingleVideoPlayerState();
}

class _SingleVideoPlayerState extends State<_SingleVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initVideo() async {
    if (widget.media.resolvedUrl == null) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.media.resolvedUrl!),
    );
    _controller = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.addListener(() {
        if (mounted && _controller != null) {
          final playing = _controller!.value.isPlaying;
          if (playing != _isPlaying) {
            setState(() => _isPlaying = playing);
          }
        }
      });
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isError = true);
      }
    }
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.videocam_off_outlined, size: 56, color: Colors.black26),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller!.value.size.width > 0
                    ? _controller!.value.size.width
                    : 320,
                height: _controller!.value.size.height > 0
                    ? _controller!.value.size.height
                    : 240,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          if (!_isPlaying)
            Container(
              color: Colors.black26,
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),
          // Video badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: 12),
                  SizedBox(width: 2),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen image viewer with swipe navigation and pinch-to-zoom
class _FullscreenImageViewer extends StatefulWidget {
  final List<PostMedia> mediaList;
  final int initialIndex;

  const _FullscreenImageViewer({
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image gallery
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaList.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final media = widget.mediaList[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: media.resolvedUrl != null
                      ? Image.network(
                          media.resolvedUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 64,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 64,
                        ),
                ),
              );
            },
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Counter
          if (widget.mediaList.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.mediaList.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // Page indicator dots
          if (widget.mediaList.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaList.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
