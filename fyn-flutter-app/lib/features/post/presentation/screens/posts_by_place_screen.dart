import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/dating_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Screen displaying all posts tagged with a specific place
class PostsByPlaceScreen extends ConsumerStatefulWidget {
  final String placeCode;
  final String placeName;

  const PostsByPlaceScreen({
    super.key,
    required this.placeCode,
    required this.placeName,
  });

  @override
  ConsumerState<PostsByPlaceScreen> createState() => _PostsByPlaceScreenState();
}

class _PostsByPlaceScreenState extends ConsumerState<PostsByPlaceScreen> {
  final List<PostModel> _posts = [];
  bool _isLoading = false;  // Start as false, will be set to true when loading
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    // Prevent multiple simultaneous loads
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(postRepositoryProvider);
      final pageResponse = await repository.getPostsByPlace(
        widget.placeCode,
        page: _page,
        size: 10,
      );
      
      setState(() {
        _posts.addAll(pageResponse.content);
        _hasMore = pageResponse.content.length == 10;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải bài viết: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: isDark ? DatingColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? DatingColors.darkSurface : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: DatingColors.indigo),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.placeName,
                style: TextStyle(
                  color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: _posts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: isDark
                            ? DatingColors.darkSecondaryText
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bài viết nào tại ${widget.placeName}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? DatingColors.darkSecondaryText
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _posts.clear();
                      _page = 0;
                      _hasMore = true;
                    });
                    await _loadPosts();
                  },
                  child: ListView.builder(
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        _loadPosts();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Use PostCard to display posts like normal feed
                      final post = _posts[index];
                      final isOwn = user?.id == post.author.id;
                      
                      return PostCard(
                        post: post,
                        isOwnPost: isOwn,
                        currentUserAvatarUrl: user?.profile?.avatarUrl != null
                            ? ImageUtils.getAvatarUrl(user!.profile.avatarUrl)
                            : null,
                        currentUsername: user?.username,
                        onDelete: () async {
                          // Delete post logic
                          try {
                            final repository = ref.read(postRepositoryProvider);
                            await repository.deletePost(post.id);
                            setState(() {
                              _posts.removeAt(index);
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã xóa bài viết')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          }
                        },
                        onTapProfile: () => context.go('/profile/${post.author.id}'),
                        onToggleReaction: () async {
                          // Toggle like
                          final repository = ref.read(postRepositoryProvider);
                          if (post.likedByCurrentUser) {
                            await repository.unlikePost(post.id);
                          } else {
                            await repository.likePost(post.id);
                          }
                          // Refresh post
                          setState(() {
                            _posts[index] = post.copyWith(
                              likedByCurrentUser: !post.likedByCurrentUser,
                              likeCount: post.likedByCurrentUser
                                  ? post.likeCount - 1
                                  : post.likeCount + 1,
                            );
                          });
                        },
                        onOpenComments: () {
                          // Open comments (reuse from FeedScreen if available)
                          // For now, just show a toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comments coming soon')),
                          );
                        },
                        onTapPlace: (placeCode, placeName) {
                          // Navigate to another place
                          context.push(
                            '/posts/place/$placeCode',
                            extra: {'placeName': placeName},
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
