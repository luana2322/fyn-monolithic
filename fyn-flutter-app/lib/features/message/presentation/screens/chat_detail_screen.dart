import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../theme/app_colors.dart';
import '../providers/message_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/conversation_type.dart';
import '../../data/models/message_model.dart';
import '../../data/models/message_status.dart';
import '../../data/models/send_message_request.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final messageNotifier = ref.read(messageProvider(widget.conversation.id).notifier);
    await messageNotifier.sendMessage(content);
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final messageNotifier = ref.read(messageProvider(widget.conversation.id).notifier);
        await messageNotifier.sendMessage('', mediaFile: image);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  String _getDisplayName() {
    if (widget.conversation.type == ConversationType.direct) {
      return widget.conversation.otherUserName ?? 'Người dùng';
    }
    return widget.conversation.title ?? 'Nhóm chat';
  }

  String? _getAvatarUrl() {
    if (widget.conversation.type == ConversationType.direct) {
      return widget.conversation.otherUserAvatar;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final messageState = ref.watch(messageProvider(widget.conversation.id));
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.muted,
              backgroundImage: _getAvatarUrl() != null
                  ? CachedNetworkImageProvider(
                      ImageUtils.getAvatarUrl(_getAvatarUrl()!)!)
                  : null,
              child: _getAvatarUrl() == null
                  ? Text(
                      _getDisplayName()[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getDisplayName(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
                // Messages list
                Expanded(
                  child: _buildMessagesList(messageState, currentUserId),
                ),
                // Input area
                _buildInputArea(messageState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(MessageState state, String? currentUserId) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(messageProvider(widget.conversation.id).notifier).loadMessages(reset: true);
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: AppColors.secondaryText.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Chưa có tin nhắn nào',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bắt đầu cuộc trò chuyện!',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Reverse để hiển thị tin nhắn mới nhất ở dưới
    final reversedMessages = state.messages.reversed.toList();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        final message = reversedMessages[index];
        final showAvatar = index == reversedMessages.length - 1 ||
            reversedMessages[index + 1].senderId != message.senderId;
        return _MessageBubble(
          message: message,
          showAvatar: showAvatar,
        );
      },
    );
  }

  Widget _buildInputArea(MessageState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: state.isSending ? null : _pickAndSendImage,
            color: AppColors.primary,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: state.isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: state.isSending ? null : _sendMessage,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFromMe = message.isFromCurrentUser;
    final time = message.createdAt != null
        ? app_date_utils.DateUtils.formatTime(message.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe && showAvatar)
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.muted,
              child: Text(
                'U',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          if (!isFromMe && showAvatar) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromMe ? 16 : 4),
                  bottomRight: Radius.circular(isFromMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.mediaUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ImageUtils.buildImageUrl(message.mediaUrl!) ?? '',
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  if (message.content.isNotEmpty) ...[
                    if (message.mediaUrl != null) const SizedBox(height: 8),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isFromMe ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isFromMe
                              ? Colors.white70
                              : AppColors.secondaryText,
                        ),
                      ),
                      if (isFromMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all
                              : message.status == MessageStatus.delivered
                                  ? Icons.done_all
                                  : Icons.done,
                          size: 14,
                          color: message.status == MessageStatus.read
                              ? Colors.blue.shade300
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isFromMe && showAvatar) const SizedBox(width: 8),
          if (isFromMe && showAvatar)
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.secondary,
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

