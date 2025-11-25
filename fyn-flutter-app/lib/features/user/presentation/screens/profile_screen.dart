import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import 'edit_profile_screen.dart';
import 'followers_following_screen.dart';
import '../../../../theme/app_colors.dart';
import '../../../post/presentation/providers/post_provider.dart';
import '../../../post/data/models/post_model.dart';
import '../../../post/presentation/widgets/post_card.dart';

class _PostsLoadTracker {
  final Set<String> loadedUserIds = <String>{};

  bool markLoaded(String userId) {
    if (loadedUserIds.contains(userId)) return false;
    loadedUserIds.add(userId);
    return true;
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? username;

  const ProfileScreen({
    super.key,
    this.userId,
    this.username,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _postsLoadTracker = _PostsLoadTracker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      // Nếu không có userId/username, dùng user hiện tại
      String? userId = widget.userId;
      String? username = widget.username;
      
      if (userId == null && username == null && authState.user != null) {
        userId = authState.user!.id;
      }
      
      final params = UserProfileParams(userId: userId, username: username);
      ref.read(userProfileProvider(params).notifier).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final canPop = Navigator.of(context).canPop();
    
    // Nếu không có userId/username, dùng user hiện tại
    String? userId = widget.userId;
    String? username = widget.username;
    
    if (userId == null && username == null && authState.user != null) {
      userId = authState.user!.id;
    }
    
    final params = UserProfileParams(userId: userId, username: username);
    final profileState = ref.watch(userProfileProvider(params));
    final profileNotifier = ref.read(userProfileProvider(params).notifier);

    final isOwnProfile = (widget.userId == null && widget.username == null) ||
        (authState.user != null &&
            (widget.userId == authState.user!.id ||
                widget.username == authState.user!.username));

    final shouldShowBack =
        (widget.userId != null || widget.username != null) || canPop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          profileState.user?.username ?? 'Hồ sơ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: shouldShowBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                  } else {
                    context.go('/feed');
                  }
                },
              )
            : null,
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileNotifier.refresh();
          final currentUserId = profileState.user?.id ?? userId;
          if (currentUserId != null) {
            await ref
                .read(userPostsProvider(currentUserId).notifier)
                .refresh();
          }
        },
        child: _buildBody(
          ref,
          profileState,
          isOwnProfile,
          authState,
          params,
          profileNotifier,
        ),
      ),
    );
  }

  Widget _buildBody(
    WidgetRef ref,
    UserProfileState profileState,
    bool isOwnProfile,
    AuthState authState,
    UserProfileParams params,
    UserProfileNotifier profileNotifier,
  ) {
    // Nếu là profile của chính mình và chưa load, dùng user từ authState
    final user = isOwnProfile && profileState.user == null
        ? authState.user
        : profileState.user;

    if (profileState.isLoading && user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.error != null && user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              profileState.error!,
              style: const TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                profileNotifier.loadUser();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (user == null) return const SizedBox.shrink();

    _maybeLoadUserPosts(user.id);
    final userPostsState = ref.watch(userPostsProvider(user.id));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(user, profileState, isOwnProfile, authState),
          
          // Stats
          _buildStats(profileState, user.id, userPostsState.posts.length),
          
          // Bio
          if (user.profile.bio != null && user.profile.bio!.isNotEmpty)
            _buildBio(user),
          
          // Action Button
          if (!isOwnProfile)
            _buildFollowButton(
              profileState,
              profileNotifier,
            ),
          
          const Divider(),
          
          _buildPostsSection(
            ref,
            user.id,
            isOwnProfile,
            userPostsState,
          ),
        ],
      ),
    );
  }

  void _maybeLoadUserPosts(String userId) {
    if (!_postsLoadTracker.markLoaded(userId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(userPostsProvider(userId).notifier).loadInitial();
    });
  }

  Widget _buildProfileHeader(
    user,
    UserProfileState profileState,
    bool isOwnProfile,
    AuthState authState,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.muted,
            backgroundImage: ImageUtils.getAvatarUrl(user.profile.avatarUrl) != null
                ? CachedNetworkImageProvider(ImageUtils.getAvatarUrl(user.profile.avatarUrl)!)
                : null,
            child: user.profile.avatarUrl == null
                ? Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 24),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    user.fullName ?? user.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                if (user.profile.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        user.profile.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    UserProfileState profileState,
    String userId,
    int postsCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Posts',
            '$postsCount',
            onTap: () {},
          ),
          _buildStatItem(
            'Followers',
            '${profileState.followersCount ?? 0}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersFollowingScreen(
                    userId: userId,
                    type: 'followers',
                  ),
                ),
              );
            },
          ),
          _buildStatItem(
            'Following',
            '${profileState.followingCount ?? 0}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersFollowingScreen(
                    userId: userId,
                    type: 'following',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.profile.bio!,
            style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
          ),
          if (user.profile.website != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  user.profile.website!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowButton(
    UserProfileState profileState,
    UserProfileNotifier profileNotifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: profileState.isLoading
              ? null
              : () {
                  profileNotifier.toggleFollow();
                },
          child: profileState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  profileState.isFollowing ? 'Bỏ theo dõi' : 'Theo dõi',
                ),
        ),
      ),
    );
  }

  Widget _buildPostsSection(
    WidgetRef ref,
    String userId,
    bool isOwnProfile,
    UserPostsState postsState,
  ) {
    Widget content;
    if (postsState.isLoading && postsState.posts.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (postsState.error != null && postsState.posts.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 12),
            Text(
              postsState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(userPostsProvider(userId).notifier).refresh();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    } else if (postsState.posts.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: const [
            Icon(Icons.camera_alt_outlined,
                size: 48, color: AppColors.secondaryText),
            SizedBox(height: 12),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    } else {
      content = Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: postsState.posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final post = postsState.posts[index];
              final media = post.media.isNotEmpty ? post.media.first : null;
              final imageUrl = media?.resolvedUrl;
              return GestureDetector(
                onTap: () {
                  _openPostDetail(ref, post, isOwnProfile);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.secondaryText,
                          ),
                        ),
                ),
              );
            },
          ),
          if (postsState.hasMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: OutlinedButton(
                onPressed: postsState.isLoadingMore
                    ? null
                    : () {
                        ref
                            .read(userPostsProvider(userId).notifier)
                            .loadMore();
                      },
                child: postsState.isLoadingMore
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Xem thêm'),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Posts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        content,
      ],
    );
  }

  Future<void> _openPostDetail(
    WidgetRef ref,
    PostModel post,
    bool isOwnProfile,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.6),
      builder: (ctx) {
        final onDelete = isOwnProfile
            ? () async {
                await ref.read(postFeedProvider.notifier).deletePost(post.id);
                await ref
                    .read(userPostsProvider(post.author.id).notifier)
                    .deletePost(post.id);
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa bài viết')),
                  );
                }
              }
            : null;
        return _PostDetailSheet(
          post: post,
          isOwnPost: isOwnProfile,
          onDelete: onDelete,
          onClose: () => Navigator.of(ctx).pop(),
        );
      },
    );
  }
}

class _PostDetailSheet extends StatelessWidget {
  const _PostDetailSheet({
    required this.post,
    required this.isOwnPost,
    this.onDelete,
    this.onClose,
  });

  final PostModel post;
  final bool isOwnPost;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: PostCard(
                  post: post,
                  isOwnPost: isOwnPost,
                  onDelete: onDelete,
                  onTapProfile: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
