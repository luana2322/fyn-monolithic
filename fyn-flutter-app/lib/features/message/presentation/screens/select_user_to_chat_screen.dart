import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_response.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/create_conversation_request.dart';
import '../../data/models/conversation_type.dart';
import '../providers/message_provider.dart';
import 'chat_detail_screen.dart';
import '../../data/models/conversation_model.dart';

class SelectUserToChatScreen extends ConsumerStatefulWidget {
  const SelectUserToChatScreen({super.key});

  @override
  ConsumerState<SelectUserToChatScreen> createState() =>
      _SelectUserToChatScreenState();
}

class _SelectUserToChatScreenState
    extends ConsumerState<SelectUserToChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserResponse> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFollowingUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowingUsers() async {
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id;
    if (currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.getFollowing(currentUserId, page: 0, size: 100);
      setState(() {
        _users = result.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách: $e')),
        );
      }
    }
  }

  Future<void> _startChat(UserResponse user) async {
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id;
    if (currentUserId == null) return;

    try {
      final request = CreateConversationRequest(
        participantIds: {currentUserId, user.id},
        type: ConversationType.direct,
      );

      final messageService = ref.read(messageServiceProvider);
      final conversation = await messageService.createConversation(request);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tạo cuộc trò chuyện: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _searchController.text.isEmpty
        ? _users
        : _users
            .where((user) =>
                user.username
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                (user.fullName ?? '')
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Chọn người để chat'),
      ),
      body: Container(
        color: AppColors.background,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 3 / 7,
            constraints: BoxConstraints(
              maxWidth: 600,
              minWidth: 400,
            ),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bạn bè...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                // User list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 64,
                                      color: AppColors.secondaryText
                                          .withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'Bạn chưa follow ai'
                                        : 'Không tìm thấy',
                                    style: const TextStyle(
                                        color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return _UserListItem(
                                  user: user,
                                  onTap: () => _startChat(user),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
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

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.muted,
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? user.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

