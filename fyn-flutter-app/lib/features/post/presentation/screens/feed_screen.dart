import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
import 'package:fyn_flutter_app/shared/themes/app_spacing.dart';
import 'reels_screen.dart'; // Import ReelsScreen
import '../../../user/presentation/screens/followers_following_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  int _currentIndex = 0;
  late final ScrollController _scrollController;
  // Để xử lý nút Back trên Android khi ở các tab khác
  final List<int> _navigationHistory = [0];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Load dữ liệu ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postFeedProvider.notifier).loadInitial();
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
    // Load more khi cuộn gần đến cuối (còn 200px)
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(postFeedProvider.notifier).loadMore();
    }
  }

  Future<void> _openCreatePostSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để bo góc hoạt động đẹp
      builder: (context) => const CreatePostSheet(),
    );
  }

  // Xử lý chuyển tab
  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      // Nếu tap lại tab hiện tại -> Scroll to top
      if (index == 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    // Pause video bên Reels nếu rời khỏi tab Reels (index 2)
    if (_currentIndex == 2) {
      ReelsScreen.pauseAllVideos();
    }

    // Xử lý đặc biệt cho Profile Tab (index 4) - chuyển sang trang profile riêng
    if (index == 4) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        context.push('/profile/${user.id}');
      }
      return;
    }

    setState(() {
      _currentIndex = index;
      _navigationHistory.add(index);
    });
  }

  // Xử lý nút Back vật lý
  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      setState(() {
        _currentIndex = _navigationHistory.last;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    
    // Kiểm tra xem có đang ở chế độ nền tối (Reels) hay không
    final isDarkMode = _currentIndex == 2;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : AppColors.background,
        extendBody: true, // Để nội dung tràn xuống dưới BottomNavBar (cho hiệu ứng trong suốt)
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home Feed
            _buildHomeFeed(user),
            
            // Tab 1: Search
            const SafeArea(child: UserSearchView()),
            
            // Tab 2: Reels
            const ReelsScreen(),
            
            // Tab 3: Shop (Placeholder)
            _buildPlaceholderTab(
              icon: Icons.shopping_bag_outlined,
              title: 'Cửa hàng',
              subtitle: 'Tính năng đang được phát triển',
            ),
            
            // Tab 4: Profile (Chỉ là placeholder trong IndexedStack vì ta navigate đi chỗ khác)
            Container(), 
          ],
        ),
        bottomNavigationBar: _buildModernBottomNavBar(isDarkMode, user),
        floatingActionButton: _currentIndex == 0 
            ? FloatingActionButton(
                onPressed: _openCreatePostSheet,
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildHomeFeed(dynamic user) {
    final feedState = ref.watch(postFeedProvider);

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background.withOpacity(0.95), // Hiệu ứng kính mờ
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              AppConfig.appName.toLowerCase(),
              style: const TextStyle(
                fontFamily: 'Inter', // Hoặc font custom của bạn
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: AppColors.primary,
                letterSpacing: -1,
              ),
            ),
            centerTitle: false,
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final notificationState = ref.watch(notificationProvider);
                  final unread = notificationState.unreadCount;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border_rounded, size: 26, color: AppColors.primaryText),
                        onPressed: () => context.push('/notifications'),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.background, width: 2),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24, color: AppColors.primaryText),
                onPressed: () => context.push('/chat'),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () async => ref.read(postFeedProvider.notifier).refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Stories Section
            SliverToBoxAdapter(
              child: _buildStoriesSection(user),
            ),
            
            // Create Post Shortcut
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Sử dụng CreatePostCard đã được tối ưu
                child: CreatePostCard(), 
              ),
            ),

            // Posts List
            if (feedState.isLoading && feedState.posts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (feedState.error != null && feedState.posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.secondaryText),
                      const SizedBox(height: 16),
                      Text('Không thể tải bảng tin', style: TextStyle(color: AppColors.secondaryText)),
                      TextButton(
                        onPressed: () => ref.read(postFeedProvider.notifier).refresh(),
                        child: const Text('Thử lại'),
                      )
                    ],
                  ),
                ),
              )
            else if (feedState.posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.feed_outlined, size: 64, color: AppColors.tertiaryText),
                      SizedBox(height: 16),
                      Text('Chào mừng! Hãy follow mọi người để xem bài viết.', style: TextStyle(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = feedState.posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostCard(
                        post: post,
                        isOwnPost: user?.id == post.author.id,
                        currentUserAvatarUrl: ImageUtils.getAvatarUrl(user?.profile.avatarUrl),
                        currentUsername: user?.username,
                        onDelete: () => _confirmDeletePost(post),
                        onTapProfile: () => context.push('/profile/${post.author.id}'),
                        onToggleReaction: () => ref.read(postFeedProvider.notifier).toggleReaction(post.id, post.likedByCurrentUser),
                        onOpenComments: () => _openCommentsSheet(post),
                      ),
                    );
                  },
                  childCount: feedState.posts.length,
                ),
              ),
              
            // Loading More Indicator
            if (feedState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
              
            // Bottom Padding for FAB and Nav Bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBottomNavBar(bool isDarkMode, dynamic user) {
    // Màu sắc thay đổi tùy theo nền (Reels dùng nền đen)
    final backgroundColor = isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9);
    final selectedItemColor = isDarkMode ? Colors.white : AppColors.primary;
    final unselectedItemColor = isDarkMode ? Colors.white38 : AppColors.tertiaryText;

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, Icons.home_outlined, selectedItemColor, unselectedItemColor),
          _navItem(1, Icons.search_rounded, Icons.search, selectedItemColor, unselectedItemColor),
          _navItem(2, Icons.movie_rounded, Icons.movie_outlined, selectedItemColor, unselectedItemColor),
          _navItem(3, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, selectedItemColor, unselectedItemColor),
          
          // Profile Icon đặc biệt
          GestureDetector(
            onTap: () => _onTabTapped(4),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentIndex == 4 ? selectedItemColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.surfaceHighlight,
                backgroundImage: user?.profile.avatarUrl != null 
                    ? CachedNetworkImageProvider(ImageUtils.getAvatarUrl(user.profile.avatarUrl)!) 
                    : null,
                child: user?.profile.avatarUrl == null 
                    ? Icon(Icons.person, size: 16, color: unselectedItemColor) 
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, Color selectedColor, Color unselectedColor) {
    final isSelected = _currentIndex == index;
    return IconButton(
      onPressed: () => _onTabTapped(index),
      icon: Icon(
        isSelected ? activeIcon : inactiveIcon,
        color: isSelected ? selectedColor : unselectedColor,
        size: 26,
      ),
    );
  }

  Widget _buildStoriesSection(dynamic user) {
    return Container(
      height: 105,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10, // Mock data
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildStoryItem(user: user, isMe: true);
          }
          return _buildStoryItem(index: index);
        },
      ),
    );
  }

  Widget _buildStoryItem({dynamic user, bool isMe = false, int? index}) {
    final avatarUrl = isMe ? ImageUtils.getAvatarUrl(user?.profile.avatarUrl) : null;
    // Mock user names
    final name = isMe ? 'Tin của bạn' : 'User $index';
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Gradient ring cho Story chưa xem
                gradient: isMe 
                    ? null // Story của mình không có vòng gradient nếu chưa post
                    : const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFFDB2777)],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surfaceHighlight,
                  backgroundImage: avatarUrl != null 
                      ? CachedNetworkImageProvider(avatarUrl) 
                      : null,
                  child: !isMe && avatarUrl == null 
                      ? Text('$index') 
                      : (isMe && avatarUrl == null ? const Icon(Icons.person, color: AppColors.secondaryText) : null),
                ),
              ),
            ),
            if (isMe)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.tertiaryText.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePost(PostModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài viết?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(postFeedProvider.notifier).deletePost(post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bài viết'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _openCommentsSheet(PostModel post) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostCommentsSheet(post: post),
    );
  }
}