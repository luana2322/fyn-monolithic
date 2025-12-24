import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/dating_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/group_chat_provider.dart';

/// Screen for creating a new friends group chat
class CreateGroupChatScreen extends ConsumerStatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  ConsumerState<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends ConsumerState<CreateGroupChatScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final Set<String> _selectedMemberIds = {};

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhóm')),
      );
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 thành viên')),
      );
      return;
    }

    // Use the provider to create group
    await ref.read(createGroupProvider.notifier).createGroup(
      name: _groupNameController.text.trim(),
      memberIds: _selectedMemberIds.toList(),
    );

    final state = ref.read(createGroupProvider);
    
    if (!mounted) return;

    if (state.isSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo nhóm chat thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${state.error}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id;
    final createState = ref.watch(createGroupProvider);

    return Scaffold(
      backgroundColor: isDark ? DatingColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? DatingColors.darkNavBackground : null,
        title: Text(
          'Tạo nhóm chat',
          style: TextStyle(
            color: isDark ? DatingColors.darkPrimaryText : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? DatingColors.darkPrimaryText : null,
        ),
        actions: [
          TextButton(
            onPressed: createState.isLoading ? null : _createGroup,
            child: createState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Tạo',
                    style: TextStyle(
                      color: _selectedMemberIds.isEmpty
                          ? Colors.grey
                          : (isDark ? DatingColors.rose : AppColors.primary),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group name input
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? DatingColors.darkSurface : Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.group,
                    size: 32,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      hintText: 'Tên nhóm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? DatingColors.darkSurfaceElevated
                          : Colors.grey.shade50,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected members
          if (_selectedMemberIds.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isDark ? DatingColors.darkSurface : Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedMemberIds.length,
                itemBuilder: (context, index) {
                  final memberId = _selectedMemberIds.elementAt(index);
                  return _SelectedMemberChip(
                    memberId: memberId,
                    onRemove: () {
                      setState(() => _selectedMemberIds.remove(memberId));
                    },
                  );
                },
              ),
            ),

          // Divider
          Divider(
            height: 1,
            color: isDark ? DatingColors.darkBorder : AppColors.border,
          ),

          // Friends list header
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? DatingColors.darkSurface : Colors.white,
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thêm thành viên từ bạn bè',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),

          // Friends/followers list
          Expanded(
            child: _FriendsList(
              currentUserId: currentUserId ?? '',
              selectedIds: _selectedMemberIds,
              onToggle: (userId) {
                setState(() {
                  if (_selectedMemberIds.contains(userId)) {
                    _selectedMemberIds.remove(userId);
                  } else {
                    _selectedMemberIds.add(userId);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMemberChip extends ConsumerWidget {
  final String memberId;
  final VoidCallback onRemove;

  const _SelectedMemberChip({
    required this.memberId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = UserProfileParams(userId: memberId);
    final userState = ref.watch(userProfileProvider(params));
    final user = userState.user;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: user?.profile.avatarUrl != null
                    ? CachedNetworkImageProvider(
                        ImageUtils.getAvatarUrl(user!.profile.avatarUrl!) ??
                            user.profile.avatarUrl!,
                      )
                    : null,
                child: user?.profile.avatarUrl == null
                    ? Text(
                        (user?.fullName ?? user?.username ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              user?.fullName ?? user?.username ?? 'User',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsList extends ConsumerWidget {
  final String currentUserId;
  final Set<String> selectedIds;
  final Function(String) onToggle;

  const _FriendsList({
    required this.currentUserId,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load followers/friends list from FollowerProvider
    // For now, show placeholder
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            size: 64,
            color: (isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Danh sách bạn bè sẽ hiển thị ở đây',
            style: TextStyle(
              color: isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
