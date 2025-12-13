import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../config/app_config.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../widgets/create_post_card.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/post_card.dart';
import '../widgets/post_comments_sheet.dart';
import '../../../search/presentation/widgets/user_search_view.dart';
import '../../../../theme/app_colors.dart';
import 'reels_screen.dart' show ReelsScreen, _ReelsScreenState;
import '../../../connections/presentation/screens/connection_hub_screen.dart';
import '../../../story/presentation/widgets/story_widgets.dart';
import '../../../story/presentation/screens/create_story_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  int _currentIndex = 0;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postFeedProvider.notifier).loadInitial();
      // Khởi động notifier thông báo để bắt đầu polling realtime số thông báo
      ref.read(notificationProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(postFeedProvider.notifier).loadMore();
    }
  }

  Future<void> _openCreatePostSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreatePostSheet(),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng bài thành công')),
      );
    }
  }

  Future<void> _confirmDeletePost(PostModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(postFeedProvider.notifier).deletePost(post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bài viết')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể xóa bài viết: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final feedState = ref.watch(postFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(user),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(user, feedState),
          const UserSearchView(),
          const ReelsScreen(),
          const ConnectionHubScreen(), // Dating, Friendship, Meetups
          _buildProfileShortcut(user),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppColors.primary,
          elevation: 0,
          onTap: (index) {
            // Nếu đang rời khỏi tab Reels (index 2), pause tất cả video
            if (_currentIndex == 2 && index != 2) {
              // Pause tất cả video khi rời khỏi tab Reels
              ReelsScreen.pauseAllVideos();
            }
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: Colors.white70,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(_currentIndex == 1 ? Icons.search : Icons.search_outlined),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2
                  ? Icons.movie_filter
                  : Icons.movie_filter_outlined),
              label: 'Reels',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? Icons.favorite : Icons.favorite_outline),
              label: 'Connections',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileNavIcon(user, isActive: false),
              activeIcon: _buildProfileNavIcon(user, isActive: true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(user) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Text(
            AppConfig.appName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final notificationState = ref.watch(notificationProvider);
            final unread = notificationState.unreadCount;
            return _buildNotificationButton(
              count: unread,
              onPressed: () {
                context.go('/notifications');
              },
            );
          },
        ),
        _buildAppBarButton(
          icon: Icons.chat_bubble_outline,
          onPressed: () {
            context.go('/chat');
          },
        ),
        _buildAppBarButton(
          icon: Icons.logout,
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            if (mounted) {
              context.go('/login');
            }
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildAppBarButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildNotificationButton({
    required int count,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: onPressed,
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 16,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(user, FeedState feedState) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Feed chiếm khoảng 1/3 màn hình ở giữa như Facebook/Instagram
    // Trên mobile: chiếm toàn bộ, trên desktop/tablet: chiếm 1/3 với margin hai bên
    final isMobile = screenWidth < 768;
    final feedMaxWidth = isMobile ? screenWidth : screenWidth * 0.33;
    final feedWidth = feedMaxWidth.clamp(400.0, 600.0);

    final content = RefreshIndicator(
      onRefresh: () async {
        await ref.read(postFeedProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                CreatePostCard(onCreatePost: _openCreatePostSheet),
                StoriesRow(
                  onAddStory: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateStoryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColors.muted),
              ],
            ),
          ),
          if (feedState.isLoading && feedState.posts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (feedState.error != null && feedState.posts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      feedState.error ?? 'Có lỗi xảy ra',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else if (feedState.posts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'Chưa có bài viết nào. Hãy là người đầu tiên chia sẻ!',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = feedState.posts[index];
                  final isOwn = user?.id == post.author.id;
                  return PostCard(
                    post: post,
                    isOwnPost: isOwn,
                    currentUserAvatarUrl: user?.profile?.avatarUrl != null
                        ? ImageUtils.getAvatarUrl(user!.profile.avatarUrl)
                        : null,
                    currentUsername: user?.username,
                    onDelete: () => _confirmDeletePost(post),
                    onTapProfile: () => context.go('/profile/${post.author.id}'),
                    onToggleReaction: () => ref
                        .read(postFeedProvider.notifier)
                        .toggleReaction(post.id, post.likedByCurrentUser),
                    onOpenComments: () => _openCommentsSheet(post),
                  );
                },
                childCount: feedState.posts.length,
              ),
            ),
          if (feedState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );

    // Feed nằm giữa màn hình với margin hai bên
    return Container(
      color: AppColors.background,
      child: Center(
        child: Container(
          width: isMobile ? double.infinity : feedWidth,
          constraints: BoxConstraints(
            maxWidth: feedWidth,
          ),
          child: content,
        ),
      ),
    );
  }

  Future<void> _openCommentsSheet(PostModel post) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PostCommentsSheet(post: post),
    );
  }

  Widget _buildStoriesSection(user) {
    final stories = List.generate(10, (index) => index);
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildStoryAvatar(
              label: 'Tin của bạn',
              isOwnStory: true,
              username: user?.username ?? 'Bạn',
            );
          }
          return _buildStoryAvatar(
            label: 'user$index',
            isOwnStory: false,
          );
        },
      ),
    );
  }

  Widget _buildStoryAvatar({
    required String label,
    bool isOwnStory = false,
    String? username,
  }) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isOwnStory
                ? [AppColors.surfaceElevated, AppColors.surface]
                : [
                    AppColors.secondaryLight,
                    AppColors.secondary,
                    AppColors.primary,
                  ],
          ),
        ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      (username ?? label)[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (isOwnStory)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }

  static Widget _buildProfileNavIcon(user, {required bool isActive}) {
    final borderColor = isActive ? AppColors.primaryText : Colors.transparent;
    final avatarKey = user?.profile?.avatarUrl;
    final avatarUrl = avatarKey != null ? ImageUtils.getAvatarUrl(avatarKey) : null;
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.muted,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(Icons.person, size: 14, color: AppColors.secondaryText)
            : null,
      ),
    );
  }

  Widget _buildProfileShortcut(user) {
    if (user == null) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập để xem hồ sơ',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.muted,
                backgroundImage: user.profile.avatarUrl != null
                    ? NetworkImage(ImageUtils.getAvatarUrl(user.profile.avatarUrl) ?? '')
                    : null,
                child: user.profile.avatarUrl == null
                    ? Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.fullName ?? '',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/profile/${user.id}'),
              child: const Text(
                'Xem hồ sơ',
                style: TextStyle(color: AppColors.primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitials(String username, {double size = 18}) {
    final initials = username.isNotEmpty
        ? username.substring(0, 1).toUpperCase()
        : 'U';
    return Text(
      initials,
      style: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.bold,
        fontSize: size * 0.6,
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.secondaryText.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              subtitle,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
