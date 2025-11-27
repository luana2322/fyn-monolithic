import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final conversationState = ref.watch(conversationListProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Tin nhắn',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectUserToChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 3 / 7,
            constraints: const BoxConstraints(
              maxWidth: 600,
              minWidth: 400,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(conversationListProvider.notifier)
                    .loadConversations();
              },
              child: _buildBody(conversationState, currentUserId),
            ),
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
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(conversationListProvider.notifier)
                    .loadConversations();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có cuộc trò chuyện nào',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút + để bắt đầu chat',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.conversations.length,
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
      ref.read(userProfileProvider(params).notifier).loadUser();
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
      } else if (!userState.isLoading) {
        _maybeLoadOtherUser();
      }
    } else {
      displayName ??= conversation.title ?? 'Nhóm chat';
    }

    final lastMessageTime = conversation.lastMessageAt != null
        ? app_date_utils.DateUtils.formatTime(conversation.lastMessageAt!)
        : '';

    return InkWell(
      onTap: widget.onTap,
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
              radius: 28,
              backgroundColor: AppColors.muted,
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(
                      ImageUtils.getAvatarUrl(avatarUrl) ?? avatarUrl,
                    )
                  : null,
              child: avatarUrl == null
                  ? Text(
                      (displayName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName ?? 'Người dùng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessageTime.isNotEmpty)
                        Text(
                          lastMessageTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage ?? 'Chưa có tin nhắn',
                    style: TextStyle(
                      fontSize: 14,
                      color: conversation.lastMessage != null
                          ? AppColors.secondaryText
                          : AppColors.muted,
                      fontStyle: conversation.lastMessage == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
