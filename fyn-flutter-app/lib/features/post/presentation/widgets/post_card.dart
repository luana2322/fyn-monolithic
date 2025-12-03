import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  Widget build(BuildContext context) {
    final author = post.author;
    final avatarUrl = ImageUtils.getAvatarUrl(author.profile.avatarUrl);
    final timeAgo = post.createdAt != null ? app_date_utils.DateUtils.formatReadable(post.createdAt!) : '';

    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onTapProfile,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surfaceHighlight,
                    backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
                    child: avatarUrl == null ? Text(author.username[0].toUpperCase()) : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onTapProfile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(author.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 4),
                            // FIX: Bỏ check isVerified vì model không có
                            Text('• $timeAgo', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOwnPost)
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // 2. Content Text
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.primaryText),
              ),
            ),
          const SizedBox(height: 8),

          // 3. Media
          if (post.media.isNotEmpty) _PostMediaView(media: post.media.first),

          // 4. Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _ActionButton(
                  icon: post.likedByCurrentUser ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: post.likedByCurrentUser ? Colors.red : AppColors.primaryText,
                  label: '${post.likeCount}',
                  onTap: onToggleReaction,
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.commentCount}',
                  onTap: onOpenComments,
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.send_rounded,
                  onTap: () {},
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border_rounded, color: AppColors.primaryText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.label, this.color = AppColors.primaryText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 26, color: color),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

// FIX: Full implementation of _PostMediaView
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
  }

  void _videoListener() {
    if (_videoController != null && mounted) {
      final isPlaying = _videoController!.value.isPlaying;
      if (isPlaying != _isVideoPlaying) {
        setState(() => _isVideoPlaying = isPlaying);
      }
    }
  }

  Future<void> _initVideoIfNeeded() async {
    if (widget.media == null || !widget.media!.isVideo || widget.media!.resolvedUrl == null) {
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
          _isVideoPlaying = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isVideoError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: _calculateHeight(context)),
      width: double.infinity,
      color: AppColors.surfaceHighlight,
      child: _buildContent(), // FIX: Now defined below
    );
  }

  double _calculateHeight(BuildContext context) {
    if (!kIsWeb) return _PostMediaView._defaultHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return _PostMediaView._defaultHeight;
    return math.max(280, math.min(screenHeight / 2, 520));
  }

  // FIX: Added _buildContent
  Widget _buildContent() {
    final media = widget.media;
    if (media == null) return _placeholder(icon: Icons.image);

    if (media.isImage && media.resolvedUrl != null) {
      return CachedNetworkImage(
        imageUrl: media.resolvedUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(icon: Icons.image),
        errorWidget: (_, __, ___) => _placeholder(icon: Icons.broken_image),
      );
    }

    if (media.isVideo) {
      if (_isVideoError || _videoController == null) {
        return _placeholder(icon: Icons.videocam_off);
      }
      if (!_isVideoInitialized) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      return GestureDetector(
        onTap: () {
          if (_videoController == null || !_isVideoInitialized) return;
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
          } else {
            _videoController!.play();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            if (!_isVideoPlaying)
              Container(
                color: Colors.black26,
                child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
          ],
        ),
      );
    }

    return _placeholder(icon: Icons.insert_drive_file);
  }

  Widget _placeholder({required IconData icon}) {
    return Container(
      height: 250,
      color: AppColors.surfaceHighlight,
      child: Center(child: Icon(icon, size: 48, color: AppColors.tertiaryText)),
    );
  }
}