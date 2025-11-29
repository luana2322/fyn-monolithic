import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/user_provider.dart';
import '../../../auth/data/models/user_response.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';

class FollowersFollowingScreen extends ConsumerStatefulWidget {
  final String userId;
  final String type; // 'followers' or 'following'

  const FollowersFollowingScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  ConsumerState<FollowersFollowingScreen> createState() =>
      _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState
    extends ConsumerState<FollowersFollowingScreen> {
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.type == 'followers' ? 'Followers' : 'Following',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadUsers(refresh: true),
        child: _users.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.type == 'followers'
                              ? 'Chưa có followers'
                              : 'Chưa follow ai',
                          style: const TextStyle(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _users.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _users.length) {
                        if (_hasMore) {
                          _loadUsers();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
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
                              builder: (context) => FollowersFollowingScreen(
                                userId: _users[index].id,
                                type: 'followers',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
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
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id;
    if (currentUserId == null || currentUserId == widget.user.id) {
      return;
    }

    try {
      final userService = ref.read(userServiceProvider);
      // Check xem user này có trong danh sách following của current user không
      final following = await userService.getFollowing(
        currentUserId,
        page: 0,
        size: 100,
      );
      final isFollowing = following.content.any((u) => u.id == widget.user.id);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final wasFollowing = _isFollowing;
      
      if (_isFollowing) {
        await userService.unfollow(widget.user.id);
      } else {
        await userService.follow(widget.user.id);
      }

      // Reload trạng thái để đảm bảo đồng bộ
      await _checkFollowingStatus();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasFollowing ? 'Đã bỏ theo dõi' : 'Đã theo dõi',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Parse error message để hiển thị rõ ràng hơn
        String errorMessage = 'Có lỗi xảy ra';
        final errorString = e.toString();
        if (errorString.contains('Already following')) {
          errorMessage = 'Bạn đã theo dõi người dùng này rồi';
        } else if (errorString.contains('Not following')) {
          errorMessage = 'Bạn chưa theo dõi người dùng này';
        } else if (errorString.contains('Cannot follow yourself') || 
                   errorString.contains('Cannot unfollow yourself')) {
          errorMessage = 'Không thể thực hiện thao tác này';
        } else if (errorString.contains('Bad Request') || 
                   errorString.contains('400')) {
          errorMessage = 'Yêu cầu không hợp lệ. Vui lòng thử lại';
        } else {
          errorMessage = errorString.replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id;
    final isOwnProfile = currentUserId == widget.user.id;
    final avatarUrl = ImageUtils.getAvatarUrl(widget.user.profile.avatarUrl);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: CircleAvatar(
          radius: 23,
          backgroundColor: AppColors.muted,
          backgroundImage:
              avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  widget.user.username[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                )
              : null,
        ),
      ),
      title: Text(
        widget.user.fullName ?? widget.user.username,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        '@${widget.user.username}',
        style: const TextStyle(color: AppColors.secondaryText),
      ),
      trailing: isOwnProfile
          ? null
          : _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: _toggleFollow,
                  style: TextButton.styleFrom(
                    backgroundColor: _isFollowing
                        ? Colors.grey.shade300
                        : AppColors.secondary,
                    foregroundColor: _isFollowing
                        ? AppColors.primaryText
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isFollowing ? 'Đã theo dõi' : 'Theo dõi',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
      onTap: widget.onTap,
    );
  }
}

