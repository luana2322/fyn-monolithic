import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Giữ nguyên các import của bạn
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../theme/app_colors.dart';
import '../providers/message_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/conversation_type.dart';
import 'chat_detail_screen.dart';
import 'select_user_to_chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationListProvider.notifier).loadConversations();
    });
  }

  void _navigateToCreateChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectUserToChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final conversationState = ref.watch(conversationListProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch sẽ
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: false, // Title lệch trái giống Messenger
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: const Text(
          'Đoạn chat',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 24, // Font to hơn
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Nền xám nhạt cho nút action
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.black87, size: 22),
              onPressed: () {
                // Logic mở camera nhanh (nếu có)
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_square, color: Colors.black87, size: 22),
              tooltip: 'Tin nhắn mới',
              onPressed: _navigateToCreateChat,
            ),
          ),
        ],
      ),
      // Nút Floating Action Button chuẩn UI/UX
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateChat,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // 1. Modern Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Màu nền xám nhạt hiện đại
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ),

              // 2. Chat List Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(conversationListProvider.notifier).loadConversations();
                  },
                  color: AppColors.primary,
                  child: _buildBody(conversationState, currentUserId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ConversationListState state, String? currentUserId) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải tin nhắn',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                ref.read(conversationListProvider.notifier).loadConversations();
              },
              child: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (state.conversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 80), // Bottom padding cho FAB
      itemCount: state.conversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 2), // Khoảng cách nhỏ giữa các item
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return _ConversationListItem(
          conversation: conversation,
          currentUserId: currentUserId ?? '',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(conversation: conversation),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có cuộc trò chuyện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kết nối với bạn bè để bắt đầu ngay',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToCreateChat,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Bắt đầu nhắn tin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationListItem extends ConsumerStatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationListItem({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  ConsumerState<_ConversationListItem> createState() =>
      _ConversationListItemState();
}

class _ConversationListItemState extends ConsumerState<_ConversationListItem> {
  String? _requestedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeLoadOtherUser();
    });
  }

  @override
  void didUpdateWidget(covariant _ConversationListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conversation.id != oldWidget.conversation.id) {
      _requestedUserId = null;
      _maybeLoadOtherUser();
    }
  }

  void _maybeLoadOtherUser() {
    final otherUserId = _findOtherUserId();
    if (widget.conversation.type != ConversationType.direct ||
        otherUserId == null) {
      return;
    }

    if (_requestedUserId == otherUserId) {
      return;
    }

    final params = UserProfileParams(userId: otherUserId);
    final profileState = ref.read(userProfileProvider(params));
    if (profileState.user == null && !profileState.isLoading) {
      _requestedUserId = otherUserId;
      Future.microtask(() {
        if (mounted) ref.read(userProfileProvider(params).notifier).loadUser();
      });
    }
  }

  String? _findOtherUserId() {
    for (final memberId in widget.conversation.memberIds) {
      if (memberId != widget.currentUserId) {
        return memberId;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final otherUserId = _findOtherUserId();

    String? displayName = conversation.otherUserName;
    String? avatarUrl = conversation.otherUserAvatar;

    if (conversation.type == ConversationType.direct && otherUserId != null) {
      final params = UserProfileParams(userId: otherUserId);
      final userState = ref.watch(userProfileProvider(params));
      final user = userState.user;

      if (user != null) {
        displayName ??= user.fullName ?? user.username;
        avatarUrl ??= user.profile.avatarUrl;
      }
    } else {
      displayName ??= conversation.title ?? 'Nhóm chat';
    }

    final lastMessageTime = conversation.lastMessageAt != null
        ? app_date_utils.DateUtils.formatTime(conversation.lastMessageAt!)
        : '';
        
    final fullAvatarUrl = ImageUtils.getAvatarUrl(avatarUrl);
    
    // Giả định logic Unread: Bạn có thể thay đổi điều kiện này dựa trên model thật
    final bool isUnread = false; 

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.grey[100],
        highlightColor: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28, // Avatar to hơn một chút
                    backgroundColor: Colors.grey[200],
                    backgroundImage: fullAvatarUrl != null
                        ? CachedNetworkImageProvider(fullAvatarUrl)
                        : null,
                    child: fullAvatarUrl == null
                        ? Text(
                            (displayName != null && displayName.isNotEmpty)
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  // Online Indicator
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CE417), // Màu xanh Online chuẩn
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName ?? 'Người dùng',
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.w800 : FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ?? 'Bắt đầu cuộc trò chuyện',
                            style: TextStyle(
                                  color: isUnread ? Colors.black87 : Colors.grey[600],
                                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 14,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastMessageTime,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Unread Indicator (Blue Dot)
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}