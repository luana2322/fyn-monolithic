import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../auth/data/models/user_list_item_response.dart';
import '../providers/followed_users_provider.dart';

/// Instagram-style card for friend suggestions
class FriendSuggestionCard extends ConsumerStatefulWidget {
  final UserListItemResponse user;
  final VoidCallback? onFollowPressed;

  const FriendSuggestionCard({
    super.key,
    required this.user,
    this.onFollowPressed,
  });

  @override
  ConsumerState<FriendSuggestionCard> createState() => _FriendSuggestionCardState();
}

class _FriendSuggestionCardState extends ConsumerState<FriendSuggestionCard> {
  bool _isLoading = false;

  Future<void> _handleFollowTap() async {
    final followedUsers = ref.read(followedUsersProvider.notifier);
    final isFollowing = followedUsers.isFollowing(widget.user.id);

    setState(() {
      _isLoading = true;
    });

    try {
      if (isFollowing) {
        await followedUsers.unfollowUser(widget.user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã bỏ theo dõi ${widget.user.username}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await followedUsers.followUser(widget.user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã theo dõi ${widget.user.username}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (widget.onFollowPressed != null) {
      widget.onFollowPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ImageUtils.getAvatarUrl(widget.user.avatarUrl);
    final isFollowing = ref.watch(followedUsersProvider).contains(widget.user.id);

    return Card(
      elevation: 2,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.go('/profile/${widget.user.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        widget.user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // Username
              Text(
                widget.user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // Full Name (if available)
              if (widget.user.fullName != null && widget.user.fullName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.user.fullName!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],

              // Bio Preview (if available)
              if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.user.bio!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 16),

              // Follow Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleFollowTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing 
                        ? const Color(0xFF2A2A2A) 
                        : Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: isFollowing 
                          ? BorderSide(color: Colors.grey[700]!, width: 1)
                          : BorderSide.none,
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
