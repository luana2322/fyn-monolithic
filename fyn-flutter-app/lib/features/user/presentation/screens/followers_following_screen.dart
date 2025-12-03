import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/user_provider.dart';
import '../../../auth/data/models/user_response.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import 'profile_screen.dart';

class FollowersFollowingScreen extends ConsumerStatefulWidget {
  final String userId;
  final String type; // 'followers' or 'following'

  const FollowersFollowingScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  ConsumerState<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends ConsumerState<FollowersFollowingScreen> {
  int _page = 0;
  final int _size = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  List<UserResponse> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _page = 0;
        _users = [];
        _hasMore = true;
      }
    });

    try {
      final userService = ref.read(userServiceProvider);
      final result = widget.type == 'followers'
          ? await userService.getFollowers(
              widget.userId,
              page: _page,
              size: _size,
            )
          : await userService.getFollowing(
              widget.userId,
              page: _page,
              size: _size,
            );

      if (mounted) {
        setState(() {
          if (refresh) {
            _users = result.content;
          } else {
            _users.addAll(result.content);
          }
          _page++;
          _hasMore = result.hasNextPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'followers' ? 'Người theo dõi' : 'Đang theo dõi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 0.5),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: () => _loadUsers(refresh: true),
            color: AppColors.primary,
            child: _users.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _users.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _users.length) {
                        if (_hasMore) {
                          _loadUsers();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      return _UserListItem(
                        user: _users[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userId: _users[index].id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_outlined,
              size: 48,
              color: AppColors.tertiaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.type == 'followers' ? 'Chưa có người theo dõi nào' : 'Chưa theo dõi ai',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends ConsumerStatefulWidget {
  final UserResponse user;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.onTap,
  });

  @override
  ConsumerState<_UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends ConsumerState<_UserListItem> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    // Trong thực tế, bạn nên check từ API hoặc cache
    // Ở đây tạm thời giả định false để đơn giản hóa UI demo
    // Nếu có API check status: gọi và update _isFollowing
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      
      if (_isFollowing) {
        await userService.unfollow(widget.user.id);
      } else {
        await userService.follow(widget.user.id);
      }

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isOwnProfile = authState.user?.id == widget.user.id;
    final avatarUrl = ImageUtils.getAvatarUrl(widget.user.profile.avatarUrl);

    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Tăng padding
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.surfaceHighlight,
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      widget.user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primaryText,
                    ),
                  ),
                  if (widget.user.fullName != null &&
                      widget.user.fullName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        widget.user.fullName!,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Follow Button
            if (!isOwnProfile)
              SizedBox(
                height: 34,
                width: 110, // Fixed width for consistency
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing
                        ? AppColors.surfaceHighlight
                        : AppColors.primary,
                    foregroundColor:
                        _isFollowing ? AppColors.primaryText : Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bo góc vừa phải
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}