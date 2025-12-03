import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_response.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/create_conversation_request.dart';
import '../../data/models/conversation_type.dart';
import '../providers/message_provider.dart';
import 'chat_detail_screen.dart';

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
    // Load danh sách ngay khi mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowingUsers();
    });
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
      // Lấy danh sách following để nhắn tin
      final result = await userService.getFollowing(currentUserId, page: 0, size: 100);
      if (mounted) {
        setState(() {
          _users = result.content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startChat(UserResponse user) async {
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id;
    if (currentUserId == null) return;

    try {
      // Luôn đồng bộ danh sách hội thoại mới nhất
      await ref.read(conversationListProvider.notifier).loadConversations();
      final conversationState = ref.read(conversationListProvider);

      // 1. Kiểm tra xem đã có hội thoại DIRECT giữa 2 user chưa
      final existingConversation = conversationState.conversations.firstWhereOrNull(
        (conversation) =>
            conversation.type == ConversationType.direct &&
            conversation.memberIds.contains(currentUserId) &&
            conversation.memberIds.contains(user.id),
      );

      if (existingConversation != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                conversation: existingConversation,
                fallbackName: user.fullName ?? user.username,
                fallbackAvatar: user.profile.avatarUrl,
              ),
            ),
          );
        }
        return;
      }

      // 2. Nếu chưa có, tạo mới qua API
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
            builder: (context) => ChatDetailScreen(
              conversation: conversation,
              fallbackName: user.fullName ?? user.username,
              fallbackAvatar: user.profile.avatarUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic filter local
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          // Nút đóng kiểu modal
          icon: const Icon(Icons.close_rounded, color: Colors.black87, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tin nhắn mới',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Text("Đến:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true, // Tự động focus để gõ luôn
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm tên hoặc username',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 0.5, color: Colors.grey),

          // 2. User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Không tìm thấy người dùng "${_searchController.text}"'
                : 'Danh sách bạn bè trống',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
    final displayName = user.fullName ?? user.username;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey[100],
      highlightColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}