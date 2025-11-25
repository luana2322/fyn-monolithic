import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/user_provider.dart';
import '../../../auth/data/models/user_response.dart';
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
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserResponse user;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ImageUtils.getAvatarUrl(user.profile.avatarUrl);
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.surfaceElevated,
        backgroundImage:
            avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              )
            : null,
      ),
      title: Text(
        user.fullName ?? user.username,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        '@${user.username}',
        style: const TextStyle(color: AppColors.secondaryText),
      ),
      onTap: onTap,
    );
  }
}

