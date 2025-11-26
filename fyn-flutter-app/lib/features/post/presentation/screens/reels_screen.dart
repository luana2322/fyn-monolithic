import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/post_media.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/reels_provider.dart';
import '../widgets/post_comments_sheet.dart';

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
      // Không tự động phát video đầu tiên - chờ user interaction
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
    debugPrint('Reels: All videos paused');
  }

  void _onPageChanged(int index) {
    // Pause video trước đó
    final prevController = _videoControllers[_currentIndex];
    prevController?.pause();
    
    setState(() => _currentIndex = index);
    
    // Không tự động phát video mới - chờ user interaction
    // Video sẽ hiển thị nút play để user tap vào
    
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

    if (reelsState.isLoading && reelsState.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (reelsState.error != null && reelsState.videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                reelsState.error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(reelsProvider.notifier).refresh();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (reelsState.videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            'Chưa có video nào',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: reelsState.videos.length,
        itemBuilder: (context, index) {
          final post = reelsState.videos[index];
          final videoMediaList = post.media.where((m) => m.isVideo).toList();
          if (videoMediaList.isEmpty) {
            debugPrint('Reels: Post ${post.id} has no video media');
            return const Center(
              child: Text(
                'Không có video',
                style: TextStyle(color: Colors.white),
              ),
            );
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
              // Không tự động phát - chờ user interaction (web autoplay policy)
              debugPrint('Reels: Video controller created for index $index');
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

class _ReelVideoItemState extends State<_ReelVideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _hasUserInteracted = false; // Track user interaction for web autoplay policy

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final isPlaying = _controller!.value.isPlaying;
      final hasError = _controller!.value.hasError;
      if (hasError) {
        debugPrint('Reels: Video error: ${_controller!.value.errorDescription}');
      }
      if (isPlaying != _isPlaying) {
        setState(() => _isPlaying = isPlaying);
        debugPrint('Reels: Video playing state changed: $isPlaying');
      }
    }
  }

  @override
  void didUpdateWidget(_ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive && _controller != null && _isInitialized) {
        // Chỉ phát nếu user đã tương tác trước đó
        if (_hasUserInteracted) {
          _controller!.play().then((_) {
            if (mounted) {
              setState(() => _isPlaying = true);
            }
            debugPrint('Reels: Video started playing after becoming active for post ${widget.post.id}');
          }).catchError((e) {
            debugPrint('Reels: Error playing video after becoming active: $e');
          });
        }
      } else if (!widget.isActive && _controller != null) {
        // Tạm dừng khi video không còn active
        _controller!.pause();
        if (mounted) {
          setState(() => _isPlaying = false);
        }
        debugPrint('Reels: Video paused after becoming inactive for post ${widget.post.id}');
      }
    }
  }

  Future<void> _initVideo() async {
    final url = widget.videoMedia.resolvedUrl;
    if (url == null || url.isEmpty) {
      debugPrint('Reels: Video URL is null or empty for post ${widget.post.id}');
      widget.onControllerCreated(null);
      return;
    }

    debugPrint('Reels: Initializing video for post ${widget.post.id} with URL: $url');

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
      }
      
      // Gọi callback để parent có thể quản lý controller
      widget.onControllerCreated(controller);
      
      // Không tự động phát ngay - chờ user interaction (web autoplay policy)
      // Video sẽ được phát khi user tap vào màn hình lần đầu
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      debugPrint('Reels: Video initialized for post ${widget.post.id}, waiting for user interaction');
      
      debugPrint('Reels: Video initialized successfully for post ${widget.post.id}');
      debugPrint('Reels: Video size: ${controller.value.size}');
      debugPrint('Reels: Video aspect ratio: ${controller.value.aspectRatio}');
      debugPrint('Reels: Video duration: ${controller.value.duration}');
      debugPrint('Reels: Video isActive: ${widget.isActive}');
      debugPrint('Reels: Video isPlaying: ${controller.value.isPlaying}');
    } catch (e, stackTrace) {
      debugPrint('Reels: Error initializing video for post ${widget.post.id}: $e');
      debugPrint('Reels: Stack trace: $stackTrace');
      widget.onControllerCreated(null);
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _playVideo() async {
    if (_controller == null || !_isInitialized) return;
    
    // Đánh dấu user đã tương tác
    if (!_hasUserInteracted) {
      setState(() => _hasUserInteracted = true);
    }
    
    try {
      await _controller!.play();
      if (mounted) {
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      debugPrint('Reels: Error playing video: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  void _pauseVideo() {
    if (_controller == null || !_isInitialized) return;
    _controller!.pause();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        // Nếu chưa có user interaction, phát video khi tap lần đầu
        if (!_hasUserInteracted && _isInitialized && _controller != null) {
          _playVideo();
        } else {
          // Nếu đã có interaction, toggle controls
          setState(() => _showControls = !_showControls);
          if (!_showControls) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _showControls = true);
            });
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background màu đen
          Container(color: Colors.black),
          
          // Video player - nhỏ hơn một chút với padding
          if (_isInitialized && _controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio > 0
                        ? _controller!.value.aspectRatio
                        : 9 / 16,
                    child: FittedBox(
                      fit: BoxFit.contain, // Đổi từ cover sang contain để video nhỏ hơn
                      child: SizedBox(
                        width: _controller!.value.size.width > 0
                            ? _controller!.value.size.width
                            : screenSize.width * 0.95, // Nhỏ hơn 5%
                        height: _controller!.value.size.height > 0
                            ? _controller!.value.size.height
                            : screenSize.height * 0.95, // Nhỏ hơn 5%
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (_controller != null && _controller!.value.hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi phát video: ${_controller!.value.errorDescription ?? "Unknown error"}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'URL: ${widget.videoMedia.resolvedUrl ?? "N/A"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (!_isInitialized && widget.videoMedia.resolvedUrl != null)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải video',
                    style: TextStyle(color: Colors.white),
                  ),
                  if (widget.videoMedia.resolvedUrl == null)
                    const Text(
                      'URL video không hợp lệ',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'URL: ${widget.videoMedia.resolvedUrl}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

          // Gradient overlay bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left: Author info & caption
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                backgroundImage: widget.post.author.profile
                                            .avatarUrl !=
                                        null
                                    ? NetworkImage(ImageUtils.getAvatarUrl(
                                            widget.post.author.profile.avatarUrl!) ??
                                        '')
                                    : null,
                                child: widget.post.author.profile.avatarUrl == null
                                    ? Text(
                                        widget.post.author.username
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.post.author.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (widget.post.content.isNotEmpty)
                                      Text(
                                        widget.post.content,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: Action buttons
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(
                          icon: widget.post.likedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: '${widget.post.likeCount}',
                          color: widget.post.likedByCurrentUser
                              ? Colors.redAccent
                              : Colors.white,
                          onTap: widget.onToggleReaction,
                        ),
                        const SizedBox(height: 24),
                        _ActionButton(
                          icon: Icons.mode_comment_outlined,
                          label: '${widget.post.commentCount}',
                          onTap: widget.onOpenComments,
                        ),
                        const SizedBox(height: 24),
                        _ActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: () {},
                        ),
                        const SizedBox(height: 24),
                        _ActionButton(
                          icon: Icons.more_vert,
                          label: '',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Play button overlay - hiển thị khi chưa play hoặc đang pause
          if (_isInitialized && (!_isPlaying || !_hasUserInteracted) && _controller != null)
            Center(
              child: GestureDetector(
                onTap: _playVideo,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

