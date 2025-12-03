import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import 'package:fyn_flutter_app/shared/themes/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/post_media.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/reels_provider.dart';
import '../widgets/post_comments_sheet.dart'; // Đảm bảo đường dẫn này đúng

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();

  // Static method để pause tất cả video từ bên ngoài
  static void pauseAllVideos() {
    _ReelsScreenState._currentInstance?.pauseAllVideos();
  }
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController?> _videoControllers = {};

  // Static reference để có thể access từ bên ngoài
  static _ReelsScreenState? _currentInstance;

  @override
  void initState() {
    super.initState();
    _currentInstance = this;
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reelsProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    pauseAllVideos();
    if (_currentInstance == this) {
      _currentInstance = null;
    }
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    _videoControllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  // Method để pause tất cả video - được gọi khi rời khỏi tab
  void pauseAllVideos() {
    for (var controller in _videoControllers.values) {
      controller?.pause();
    }
  }

  void _onPageChanged(int index) {
    // Pause video trước đó
    final prevController = _videoControllers[_currentIndex];
    prevController?.pause();
    
    setState(() => _currentIndex = index);
    
    // Play video hiện tại nếu có controller (được tạo trong _ReelVideoItem)
    // Lưu ý: Logic play/pause chi tiết hơn nằm trong _ReelVideoItem
    
    final state = ref.read(reelsProvider);
    // Load more khi gần cuối
    if (index >= state.videos.length - 3 && state.hasMore) {
      ref.read(reelsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reelsState = ref.watch(reelsProvider);
    final authState = ref.watch(authNotifierProvider);

    // Giao diện Loading / Error / Empty tối giản trên nền đen
    if (reelsState.isLoading && reelsState.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black, 
        body: Center(child: CircularProgressIndicator(color: Colors.white))
      );
    }

    if (reelsState.error != null && reelsState.videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                reelsState.error!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(reelsProvider.notifier).refresh(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (reelsState.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Chưa có video nào',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // Stack để PageView nằm dưới, các overlay (nếu có) nằm trên
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: reelsState.videos.length,
        itemBuilder: (context, index) {
          final post = reelsState.videos[index];
          final videoMediaList = post.media.where((m) => m.isVideo).toList();
          
          if (videoMediaList.isEmpty) {
            return const Center(child: Text('Không có video', style: TextStyle(color: Colors.white)));
          }
          
          final videoMedia = videoMediaList.first;
          return _ReelVideoItem(
            key: ValueKey(post.id),
            post: post,
            videoMedia: videoMedia,
            currentUser: authState.user,
            isActive: index == _currentIndex,
            onControllerCreated: (controller) {
              _videoControllers[index] = controller;
            },
            onToggleReaction: () async {
              await ref.read(reelsProvider.notifier).toggleReaction(
                    post.id,
                    post.likedByCurrentUser,
                  );
            },
            onOpenComments: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PostCommentsSheet(post: post),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReelVideoItem extends StatefulWidget {
  final PostModel post;
  final PostMedia videoMedia;
  final dynamic currentUser;
  final bool isActive;
  final void Function(VideoPlayerController?) onControllerCreated;
  final VoidCallback onToggleReaction;
  final VoidCallback onOpenComments;

  const _ReelVideoItem({
    super.key,
    required this.post,
    required this.videoMedia,
    required this.currentUser,
    this.isActive = false,
    required this.onControllerCreated,
    required this.onToggleReaction,
    required this.onOpenComments,
  });

  @override
  State<_ReelVideoItem> createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends State<_ReelVideoItem> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasUserInteracted = false;
  
  // Animation cho nút Like (Heart pulse)
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  bool _showHeartOverlay = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );
    
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeartOverlay = false);
        _heartAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final isPlaying = _controller!.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() => _isPlaying = isPlaying);
      }
    }
  }

  @override
  void didUpdateWidget(_ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive && _controller != null && _isInitialized) {
        // Tự động phát khi lướt tới nếu đã có tương tác trước đó (hoặc chính sách cho phép)
        // Để UX tốt nhất, nên auto-play
        _controller!.play();
      } else if (!widget.isActive && _controller != null) {
        _controller!.pause();
        // Reset về đầu nếu cần: _controller!.seekTo(Duration.zero);
      }
    }
  }

  Future<void> _initVideo() async {
    final url = widget.videoMedia.resolvedUrl;
    if (url == null || url.isEmpty) {
      widget.onControllerCreated(null);
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      controller.addListener(_videoListener);
      await controller.initialize();
      controller.setLooping(true);
      
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        
        // Auto-play nếu đây là video đang active ngay khi init xong
        if (widget.isActive) {
          controller.play();
        }
      }
      widget.onControllerCreated(controller);
    } catch (e) {
      debugPrint('Reels Error: $e');
      widget.onControllerCreated(null);
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _handleDoubleTap() {
    if (!widget.post.likedByCurrentUser) {
      widget.onToggleReaction();
    }
    setState(() => _showHeartOverlay = true);
    _heartAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Layer
          Container(color: Colors.black),
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2)),

          // 2. Gradient Overlay (Bottom & Top) for better text visibility
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 3. Play/Pause Icon Overlay (Central)
          if (_isInitialized && !_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
              ),
            ),

          // 4. Double Tap Heart Animation
          if (_showHeartOverlay)
            Center(
              child: ScaleTransition(
                scale: _heartAnimation,
                child: const Icon(Icons.favorite, color: Colors.white, size: 100),
              ),
            ),

          // 5. Right Action Bar
          Positioned(
            right: 12,
            bottom: 100, // Cách đáy một khoảng để chừa chỗ cho info
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionItem(
                  icon: widget.post.likedByCurrentUser ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: '${widget.post.likeCount}',
                  color: widget.post.likedByCurrentUser ? Colors.redAccent : Colors.white,
                  onTap: widget.onToggleReaction,
                ),
                const SizedBox(height: 20),
                _buildActionItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${widget.post.commentCount}',
                  onTap: widget.onOpenComments,
                ),
                const SizedBox(height: 20),
                _buildActionItem(
                  icon: Icons.send_rounded, // Share icon
                  label: 'Share',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _buildActionItem(
                  icon: Icons.more_horiz_rounded,
                  label: '',
                  onTap: () {}, // More options
                ),
                const SizedBox(height: 20),
                // Music Disc Animation (Static for now)
                _buildMusicDisc(widget.post.author.profile.avatarUrl),
              ],
            ),
          ),

          // 6. Bottom Info Area
          Positioned(
            left: 16,
            right: 80, // Chừa chỗ cho action bar bên phải
            bottom: 32, // Bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      backgroundImage: widget.post.author.profile.avatarUrl != null
                          ? CachedNetworkImageProvider(ImageUtils.getAvatarUrl(widget.post.author.profile.avatarUrl!)!)
                          : null,
                      child: widget.post.author.profile.avatarUrl == null
                          ? Text(widget.post.author.username[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.post.author.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Follow Button (Small & Clean)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Caption / Description
                if (widget.post.content.isNotEmpty)
                  Text(
                    widget.post.content,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),
                
                // Music Tag
                Row(
                  children: const [
                    Icon(Icons.music_note_rounded, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Original Audio - Fyn Social',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 7. Top Navigation (Transparent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2), // Glass effect background for buttons
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMusicDisc(String? avatarUrl) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 8),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey[800],
        backgroundImage: avatarUrl != null 
            ? CachedNetworkImageProvider(ImageUtils.getAvatarUrl(avatarUrl)!) 
            : null,
        child: avatarUrl == null ? const Icon(Icons.music_note, color: Colors.white, size: 16) : null,
      ),
    );
  }
}