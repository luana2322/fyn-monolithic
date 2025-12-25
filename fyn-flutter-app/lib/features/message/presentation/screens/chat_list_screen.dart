import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../theme/app_colors.dart';
import '../../../../theme/dating_colors.dart';
import '../providers/message_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/conversation_type.dart';
import 'chat_detail_screen.dart';
import 'select_user_to_chat_screen.dart';
import 'create_group_chat_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DatingColors.darkBackground : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? DatingColors.darkNavBackground : null,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? DatingColors.darkPrimaryText : null),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/feed');
            }
          },
        ),
        title: Text(
          'Tin nhắn',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? DatingColors.darkPrimaryText : null,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? DatingColors.darkPrimaryText : null),
        actions: [
          // Create group chat button
          IconButton(
            icon: Icon(Icons.group_add, color: isDark ? DatingColors.darkPrimaryText : null),
            tooltip: 'Tạo nhóm chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroupChatScreen(),
                ),
              );
            },
          ),
          // Create direct chat button
          IconButton(
            icon: Icon(Icons.add_comment, color: isDark ? DatingColors.darkPrimaryText : null),
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
        color: isDark ? DatingColors.darkBackground : AppColors.background,
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
              child: _buildBody(conversationState, currentUserId, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ConversationListState state, String? currentUserId, bool isDark) {
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
              style: TextStyle(color: isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText),
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
              color: (isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có cuộc trò chuyện nào',
              style: TextStyle(color: isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút + để bắt đầu chat',
              style: TextStyle(
                color: isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText,
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
          isDark: isDark,
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
  final bool isDark;
  final VoidCallback onTap;

  const _ConversationListItem({
    required this.conversation,
    required this.currentUserId,
    required this.isDark,
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
          color: widget.isDark ? DatingColors.darkSurface : Colors.white,
          border: Border(
            bottom: BorderSide(color: widget.isDark ? DatingColors.darkBorder : AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar - different for group vs direct chats
            if (conversation.isGroupChat)
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: conversation.type == ConversationType.groupMeetup
                        ? Colors.pink.shade100
                        : Colors.blue.shade100,
                    child: Icon(
                      conversation.type == ConversationType.groupMeetup
                          ? Icons.calendar_today
                          : Icons.group,
                      size: 28,
                      color: conversation.type == ConversationType.groupMeetup
                          ? Colors.pink.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                  // Member count badge
                  if (conversation.memberCount > 0)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.isDark ? DatingColors.rose : AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDark ? DatingColors.darkSurface : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${conversation.memberCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: widget.isDark ? DatingColors.darkSurfaceElevated : AppColors.muted,
                backgroundImage: avatarUrl != null
                    ? CachedNetworkImageProvider(
                        ImageUtils.getAvatarUrl(avatarUrl) ?? avatarUrl,
                      )
                    : null,
                child: avatarUrl == null
                    ? Text(
                        (displayName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessageTime.isNotEmpty)
                        Text(
                          lastMessageTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText,
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
                          ? (widget.isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText)
                          : (widget.isDark ? DatingColors.darkMutedText : AppColors.muted),
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
