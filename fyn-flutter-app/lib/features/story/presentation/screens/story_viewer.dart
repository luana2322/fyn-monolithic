import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/story_model.dart';
import '../providers/story_provider.dart';

/// Full-screen story viewer with progress bars
class StoryViewer extends ConsumerStatefulWidget {
  final StoryUserWithStories storyUser;
  final int initialIndex;

  const StoryViewer({
    super.key,
    required this.storyUser,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends ConsumerState<StoryViewer>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;
  Timer? _autoAdvanceTimer;
  bool _isPaused = false;

  static const Duration storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: storyDuration,
    );
    _startProgress();
    _markCurrentStoryViewed();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(storyDuration, _nextStory);
  }

  void _markCurrentStoryViewed() {
    if (_currentIndex < widget.storyUser.stories.length) {
      final story = widget.storyUser.stories[_currentIndex];
      ref.read(storyFeedProvider.notifier).viewStory(story.id);
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.storyUser.stories.length - 1) {
      setState(() => _currentIndex++);
      _startProgress();
      _markCurrentStoryViewed();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _startProgress();
      _markCurrentStoryViewed();
    }
  }

  void _pauseStory() {
    if (!_isPaused) {
      _isPaused = true;
      _progressController.stop();
      _autoAdvanceTimer?.cancel();
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      _isPaused = false;
      _progressController.forward();
      final remaining = storyDuration * (1 - _progressController.value);
      _autoAdvanceTimer = Timer(remaining, _nextStory);
    }
  }

  void _showDeleteConfirmation(BuildContext context, String storyId) {
    _pauseStory(); // Pause while showing dialog
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xóa Story'),
          content: const Text('Bạn có chắc muốn xóa story này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resumeStory(); // Resume if cancelled
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteStory(storyId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStory(String storyId) async {
    try {
      await ref.read(storyFeedProvider.notifier).deleteStory(storyId);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close viewer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa story')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa story: $e')),
        );
        _resumeStory(); // Resume on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.storyUser.stories;
    if (stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No stories', style: TextStyle(color: Colors.white))),
      );
    }

    final currentStory = stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _pauseStory(),
        onTapUp: (_) => _resumeStory(),
        onTapCancel: () => _resumeStory(),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _nextStory();
            } else if (details.primaryVelocity! > 0) {
              _previousStory();
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story content
            _buildStoryContent(currentStory),
            
            // Tap areas for navigation
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _previousStory,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextStory,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
            
            // Top UI (progress bars, user info)
            SafeArea(
              child: Column(
                children: [
                  // Progress bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: List.generate(stories.length, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: index < _currentIndex
                                ? Container(color: Colors.white)
                                : index == _currentIndex
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (context, child) {
                                          return FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: _progressController.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : null,
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  // User info and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.muted,
                          backgroundImage: widget.storyUser.avatarUrl != null
                              ? NetworkImage(widget.storyUser.avatarUrl!)
                              : null,
                          child: widget.storyUser.avatarUrl == null
                              ? Text(
                                  widget.storyUser.username.isNotEmpty
                                      ? widget.storyUser.username[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        // Username and time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.storyUser.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                currentStory.timeAgo,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        // Delete button (only for own stories)
                        if (widget.storyUser.userId == ref.read(authNotifierProvider).user?.id)
                         IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _showDeleteConfirmation(context, currentStory.id),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Text overlay
            if (currentStory.textContent != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentStory.textContent!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    if (story.mediaType == 'VIDEO') {
      // For video stories, could implement video_player here
      // For now, show placeholder
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 80),
        ),
      );
    }
    
    // Image story
    return Image.network(
      story.mediaDisplayUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: _parseBackgroundColor(story.backgroundColor),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
          ),
        );
      },
    );
  }

  Color _parseBackgroundColor(String? colorString) {
    if (colorString == null) return Colors.black;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}
