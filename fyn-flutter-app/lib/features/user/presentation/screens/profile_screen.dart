import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart'; // Import quan trọng để dùng firstWhereOrNull

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import 'edit_profile_screen.dart';
import 'followers_following_screen.dart';
import '../../../../theme/app_colors.dart';
import '../../../post/presentation/providers/post_provider.dart';
import '../../../post/data/models/post_model.dart';
import '../../../post/presentation/widgets/post_card.dart';
import '../../../post/presentation/widgets/post_comments_sheet.dart';

// Import liên quan đến Chat
import '../../../message/data/models/create_conversation_request.dart';
import '../../../message/data/models/conversation_type.dart';
import '../../../message/presentation/providers/message_provider.dart';
import '../../../message/presentation/screens/chat_detail_screen.dart';

// Helper class để tránh load lại posts liên tục
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

  const ProfileScreen({super.key, this.userId, this.username});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final _postsLoadTracker = _PostsLoadTracker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authState = ref.read(authNotifierProvider);
    String? targetUserId = widget.userId;
    String? targetUsername = widget.username;
    
    // Nếu không truyền ID/Username, mặc định là user đang đăng nhập
    if (targetUserId == null && targetUsername == null && authState.user != null) {
      targetUserId = authState.user!.id;
    }
    
    final params = UserProfileParams(userId: targetUserId, username: targetUsername);
    ref.read(userProfileProvider(params).notifier).loadUser();
    
    if (targetUserId != null) {
      _maybeLoadUserPosts(targetUserId);
    }
  }

  void _maybeLoadUserPosts(String userId) {
    if (!_postsLoadTracker.markLoaded(userId)) return;
    ref.read(userPostsProvider(userId).notifier).loadInitial();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // Hiệu ứng đổi màu appbar title khi cuộn
      final offset = _scrollController.offset;
      final isScrolled = offset > 140; // Ngưỡng cuộn để hiện title
      if (isScrolled != _isScrolled) {
        setState(() => _isScrolled = isScrolled);
      }
      
      // Load more posts logic
      if (offset >= _scrollController.position.maxScrollExtent - 200) {
        final profileState = _getProfileState();
        if (profileState.user != null) {
          ref.read(userPostsProvider(profileState.user!.id).notifier).loadMore();
        }
      }
    }
  }

  UserProfileState _getProfileState() {
    final authState = ref.read(authNotifierProvider);
    String? targetUserId = widget.userId ?? (widget.username == null ? authState.user?.id : null);
    return ref.watch(userProfileProvider(UserProfileParams(userId: targetUserId, username: widget.username)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = _getProfileState();
    final user = profileState.user ?? (widget.userId == null && widget.username == null ? authState.user : null);
    
    final isOwnProfile = user?.id == authState.user?.id;
    
    if (profileState.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(profileState.error ?? 'Không tìm thấy người dùng')),
      );
    }

    // Xác định màu icon/text trên AppBar tùy theo trạng thái cuộn
    final appBarItemColor = _isScrolled ? AppColors.primaryText : Colors.white;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 460, 
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              scrolledUnderElevation: 2,
              leading: Navigator.of(context).canPop() 
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: appBarItemColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ) 
                  : null,
              title: AnimatedOpacity(
                opacity: _isScrolled ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: true,
              actions: [
                if (isOwnProfile) ...[
                  IconButton(
                    icon: Icon(Icons.edit_square, color: appBarItemColor),
                    tooltip: 'Chỉnh sửa hồ sơ',
                    onPressed: () => _navigateToEditProfile(),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: appBarItemColor),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(Icons.more_vert, color: appBarItemColor),
                    onPressed: () {
                      // TODO: Report/Block user
                    },
                  ),
                ]
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                background: _buildProfileHeader(user, isOwnProfile, profileState),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.tertiaryText,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on_rounded)),
                      Tab(icon: Icon(Icons.favorite_border_rounded)),
                      Tab(icon: Icon(Icons.assignment_ind_outlined)),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsGrid(user.id, isOwnProfile), // Tab 1: Posts
            _buildLikedPostsTab(isOwnProfile), // Tab 2: Liked posts
            const Center(child: Text("Chưa được gắn thẻ")), // Tab 3: Tagged
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isOwnProfile, UserProfileState state) {
    final avatarUrl = ImageUtils.getAvatarUrl(user.profile.avatarUrl);
    
    const double avatarRadius = 50.0;
    const double paddingTop = 90.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Cover Background
        Column(
          children: [
            Expanded(
              flex: 35, // Phần màu nền
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4F46E5), // Indigo
                      Color(0xFFEC4899), // Pink
                    ],
                  ),
                ),
              ),
            ),
            Expanded(flex: 65, child: Container(color: AppColors.surface)), // Phần trắng
          ],
        ),

        // 2. Info Overlay
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: paddingTop), 
              
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: isOwnProfile ? _changeAvatar : null,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.surfaceHighlight,
                    backgroundImage: avatarUrl != null 
                        ? CachedNetworkImageProvider(avatarUrl) 
                        : null,
                    child: avatarUrl == null 
                        ? Text(
                            user.username[0].toUpperCase(), 
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)
                          )
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Name & Handle
              Text(
                user.fullName ?? user.username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryText),
              ),
              if (user.fullName != null)
                Text(
                  '@${user.username}',
                  style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
                ),

              // Bio
              if (user.profile.bio != null && user.profile.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Text(
                    user.profile.bio!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: AppColors.primaryText, height: 1.3),
                  ),
                ),

              const SizedBox(height: 12),

              // Stats Row
              _buildStatsRow(user.id, state),

              const SizedBox(height: 16),

              // Action Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isOwnProfile 
                    ? _buildEditButton() 
                    : _buildActionButtons(state), 
              ),
              
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // --- NÚT ACTION (THEO DÕI / NHẮN TIN) ĐÃ CẬP NHẬT ---
  Widget _buildActionButtons(UserProfileState state) {
    final isFollowing = state.isFollowing;
    
    return Row(
      children: [
        // Nút Theo dõi
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: state.isLoading 
                  ? null 
                  : () {
                      final params = UserProfileParams(userId: state.user!.id);
                      ref.read(userProfileProvider(params).notifier).toggleFollow();
                    },
              style: ElevatedButton.styleFrom(
                // Logic màu nền: Đã theo dõi -> Xám, Chưa -> Xanh
                backgroundColor: isFollowing ? AppColors.surfaceHighlight : AppColors.primary,
                // Logic màu chữ: Đã theo dõi -> Đen, Chưa -> Trắng
                foregroundColor: isFollowing ? AppColors.primaryText : Colors.white,
                elevation: isFollowing ? 0 : 4,
                shadowColor: isFollowing ? null : AppColors.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: isFollowing ? const BorderSide(color: AppColors.border) : BorderSide.none,
              ),
              child: state.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Nút Nhắn tin
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => _navigateToChat(state.user!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface, // Màu nền trắng/xám nhẹ
                foregroundColor: AppColors.primaryText,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('Nhắn tin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }

  // --- LOGIC CHUYỂN HƯỚNG NHẮN TIN ---
  Future<void> _navigateToChat(dynamic targetUser) async {
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id;
    
    if (currentUserId == null || targetUser.id == null) return;

    try {
      // Luôn reload danh sách hội thoại từ server trước khi kiểm tra
      await ref.read(conversationListProvider.notifier).loadConversations();
      final conversationState = ref.read(conversationListProvider);

      // 1. Kiểm tra xem đã có cuộc trò chuyện DIRECT giữa 2 user chưa
      final existingConversation = conversationState.conversations.firstWhereOrNull(
        (conversation) =>
            conversation.type == ConversationType.direct &&
            conversation.memberIds.contains(currentUserId) &&
            conversation.memberIds.contains(targetUser.id),
      );

      // 2. Nếu có rồi -> Mở luôn
      if (existingConversation != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                conversation: existingConversation,
                fallbackName: targetUser.fullName ?? targetUser.username,
                fallbackAvatar: targetUser.profile.avatarUrl,
              ),
            ),
          );
        }
        return;
      }

      // 3. Nếu chưa có -> Gọi API tạo mới
      final request = CreateConversationRequest(
        participantIds: {currentUserId, targetUser.id},
        type: ConversationType.direct,
      );

      final messageService = ref.read(messageServiceProvider);
      final newConversation = await messageService.createConversation(request);

      if (mounted) {
        // Cập nhật lại list chat
        ref.read(conversationListProvider.notifier).loadConversations();
        
        // Mở màn hình chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversation: newConversation,
              fallbackName: targetUser.fullName ?? targetUser.username,
              fallbackAvatar: targetUser.profile.avatarUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở cuộc trò chuyện: $e')),
        );
      }
    }
  }

  Widget _buildEditButton() {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _navigateToEditProfile,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.surface,
        ),
        child: const Text('Chỉnh sửa trang cá nhân', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
      ),
    );
  }

  Widget _buildStatsRow(String userId, UserProfileState state) {
    // Lấy số bài viết từ provider post
    final postsCount = ref.watch(userPostsProvider(userId)).posts.length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Bài viết', '$postsCount'),
        _buildStatItem(
          'Người theo dõi', 
          '${state.followersCount ?? 0}',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FollowersFollowingScreen(userId: userId, type: 'followers'))),
        ),
        _buildStatItem(
          'Đang theo dõi', 
          '${state.followingCount ?? 0}',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FollowersFollowingScreen(userId: userId, type: 'following'))),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid(String userId, bool isOwnProfile) {
    final postsState = ref.watch(userPostsProvider(userId));

    if (postsState.isLoading && postsState.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postsState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surfaceHighlight, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.tertiaryText),
            ),
            const SizedBox(height: 16),
            const Text('Chưa có bài viết nào', style: TextStyle(color: AppColors.secondaryText, fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: postsState.posts.length,
      itemBuilder: (context, index) {
        final post = postsState.posts[index];
        return _buildPostGridItem(post, isOwnProfile);
      },
    );
  }

  Widget _buildLikedPostsTab(bool isOwnProfileProfile) {
    final feedState = ref.watch(postFeedProvider);
    final likedPosts =
        feedState.posts.where((p) => p.likedByCurrentUser).toList();

    if (feedState.isLoading && feedState.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isOwnProfileProfile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Chỉ hiển thị bài viết bạn đã thích trong trang cá nhân của chính bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
        ),
      );
    }

    if (likedPosts.isEmpty) {
      return const Center(
        child: Text(
          'Bạn chưa thích bài viết nào',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: likedPosts.length,
      itemBuilder: (context, index) {
        final post = likedPosts[index];
        final isOwnPost =
            ref.read(authNotifierProvider).user?.id == post.author.id;
        return _buildPostGridItem(post, isOwnPost);
      },
    );
  }

  Widget _buildPostGridItem(PostModel post, bool isOwnPost) {
    final hasMedia = post.media.isNotEmpty;
    final isVideo = hasMedia && post.media.first.isVideo;

    return GestureDetector(
      onTap: () => _openPostDetail(post, isOwnPost),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasMedia && post.media.first.resolvedUrl != null)
            CachedNetworkImage(
              imageUrl: post.media.first.resolvedUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceHighlight),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceHighlight,
                child: const Icon(Icons.error_outline),
              ),
            )
          else
            Container(
              color: AppColors.surfaceHighlight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post.content.isNotEmpty ? post.content : '...',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          if (isVideo)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openPostDetail(PostModel post, bool isOwnProfile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: PostCard(
                  post: post,
                  isOwnPost: isOwnProfile,
                  onDelete: isOwnProfile 
                    ? () async {
                        Navigator.pop(context);
                        await ref.read(userPostsProvider(post.author.id).notifier).deletePost(post.id);
                      } 
                    : null,
                  onTapProfile: () => Navigator.pop(context),
                  onToggleReaction: () => ref.read(userPostsProvider(post.author.id).notifier).toggleReaction(post.id, post.likedByCurrentUser),
                  onOpenComments: () => showModalBottomSheet(
                    context: context, 
                    isScrollControlled: true,
                    builder: (_) => PostCommentsSheet(post: post),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    ).then((_) {
       _loadData();
    });
  }

  Future<void> _changeAvatar() async {
    // Logic thay đổi avatar giữ nguyên
  }
}