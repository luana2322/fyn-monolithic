import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart' show apiClientProvider;
import '../../../../config/api_config.dart';
import '../providers/message_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/conversation_type.dart';
import '../../data/models/message_model.dart';
import '../../data/models/message_status.dart';
import '../../data/models/call_model.dart';
import 'video_call_screen.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;
  // Fallback data: Dùng khi tạo chat mới mà chưa có dữ liệu conversation đầy đủ
  final String? fallbackName;
  final String? fallbackAvatar;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
    this.fallbackName,
    this.fallbackAvatar,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSending = false;
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _showSendButton = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      final messageNotifier = ref.read(messageProvider(widget.conversation.id).notifier);
      await messageNotifier.sendMessage(content);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndSendImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ListTile(leading: const Icon(Icons.photo_library, color: Colors.purple), title: const Text('Thư viện ảnh'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
              ListTile(leading: const Icon(Icons.camera_alt, color: Colors.blue), title: const Text('Chụp ảnh'), onTap: () => Navigator.pop(context, ImageSource.camera)),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    final image = await _imagePicker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (image != null) {
      await ref.read(messageProvider(widget.conversation.id).notifier).sendMessage('', mediaFile: image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider(widget.conversation.id));
    
    // --- LOGIC XÁC ĐỊNH TÊN VÀ AVATAR ---
    String displayName = 'Chat';
    String? avatarUrl;

    if (widget.conversation.type == ConversationType.direct) {
      // Ưu tiên: fallbackName (từ Profile / SelectUserToChat) -> otherUserName -> 'Người dùng'
      displayName =
          widget.fallbackName ?? widget.conversation.otherUserName ?? 'Người dùng';

      // Avatar: ưu tiên fallbackAvatar -> otherUserAvatar -> từ tin nhắn
      avatarUrl = widget.fallbackAvatar ?? widget.conversation.otherUserAvatar;

      if (avatarUrl == null ||
          (widget.fallbackName == null &&
              widget.conversation.otherUserName == null)) {
        for (final msg in messageState.messages.reversed) {
          if (!msg.isFromCurrentUser) {
            displayName = msg.senderName ?? displayName;
            avatarUrl ??= msg.senderAvatar;
            break;
          }
        }
      }
    } else {
      // Group Chat: dùng title hoặc fallbackName, avatar nếu có từ fallback
      displayName =
          widget.conversation.title ?? widget.fallbackName ?? 'Nhóm';
      avatarUrl = widget.fallbackAvatar;
    }
    // ------------------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(displayName, avatarUrl),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(messageState),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title, String? avatarUrl) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage: avatarUrl != null 
                    ? CachedNetworkImageProvider(ImageUtils.getAvatarUrl(avatarUrl)!) 
                    : null,
                child: avatarUrl == null 
                    ? Text(
                        title.isNotEmpty ? title[0].toUpperCase() : '?', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)
                      ) 
                    : null,
              ),
              // Online Indicator (Xanh lá)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CE417), 
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Đang hoạt động', 
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: AppColors.primary),
          onPressed: () {
            // TODO: audio call
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam, color: AppColors.primary),
          onPressed: _startVideoCall,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList(MessageState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, 
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final messageIndex = state.messages.length - 1 - index;
        final message = state.messages[messageIndex];

        final bool isMe = message.isFromCurrentUser;
        
        final bool isFirstInGroup = index == state.messages.length - 1 || 
             state.messages[state.messages.length - 1 - (index + 1)].senderId != message.senderId;
             
        final bool isLastInGroup = index == 0 || 
             state.messages[state.messages.length - 1 - (index - 1)].senderId != message.senderId;

        bool showTimeHeader = false;
        if (!isFirstInGroup && index < state.messages.length - 1) {
             final prevMsg = state.messages[state.messages.length - 1 - (index + 1)];
             if (message.createdAt != null && prevMsg.createdAt != null) {
                final diff = message.createdAt!.difference(prevMsg.createdAt!).inMinutes;
                if (diff > 10) showTimeHeader = true;
             }
        }

        return Column(
          children: [
            if (showTimeHeader) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  app_date_utils.DateUtils.formatTime(message.createdAt!),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                ),
              ),
            _MessageBubble(
              message: message,
              isMe: isMe,
              isLastInGroup: isLastInGroup,
              isFirstInGroup: isFirstInGroup,
            ),
          ],
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
            child: Icon(Icons.waving_hand_rounded, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy gửi lời chào để bắt đầu trò chuyện!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), offset: const Offset(0, -2), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.black54, size: 28),
            onPressed: _pickAndSendImage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Nhắn tin...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black54, size: 24),
                    onPressed: () {},
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_showSendButton || _isSending)
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            )
          else
             IconButton(
              icon: const Icon(Icons.mic_none_rounded, color: Colors.black87, size: 28),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
            ),
        ],
      ),
    );
  }

  /// Bắt đầu cuộc gọi video: gọi API /api/calls rồi mở màn hình VideoCallScreen
  Future<void> _startVideoCall() async {
    try {
      final api = ref.read(apiClientProvider);

      final otherUserId = widget.conversation.otherUserId;
      if (otherUserId == null || otherUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không xác định được người nhận cuộc gọi')),
        );
        return;
      }

      final res = await api.post(
        ApiEndpoints.startCall,
        data: {
          'conversationId': widget.conversation.id,
          'calleeId': otherUserId,
        },
      );

      final data = Map<String, dynamic>.from(res.data as Map);
      final call = CallModel.fromJson(data);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            callId: call.id,
            roomId: call.roomId,
            calleeName: widget.conversation.otherUserName ?? 'Người dùng',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể bắt đầu cuộc gọi video: $e')),
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isLastInGroup;
  final bool isFirstInGroup;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.isLastInGroup = true,
    this.isFirstInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    const double rLarge = 20.0;
    const double rSmall = 5.0;

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? rLarge : (isFirstInGroup ? rLarge : rSmall)),
      topRight: Radius.circular(isMe ? (isFirstInGroup ? rLarge : rSmall) : rLarge),
      bottomLeft: Radius.circular(isMe ? rLarge : (isLastInGroup ? rSmall : rSmall)),
      bottomRight: Radius.circular(isMe ? (isLastInGroup ? rSmall : rSmall) : rLarge),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLastInGroup ? 12 : 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 28,
              margin: const EdgeInsets.only(right: 8),
              child: isLastInGroup
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: message.senderAvatar != null
                          ? CachedNetworkImageProvider(ImageUtils.getAvatarUrl(message.senderAvatar!)!)
                          : null,
                      child: message.senderAvatar == null
                          ? Text((message.senderName ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))
                          : null,
                    )
                  : null,
            ),

          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: isMe ? 50 : 0, right: isMe ? 0 : 50),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe 
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) 
                    : null,
                color: isMe ? null : Colors.grey[200],
                borderRadius: borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.mediaUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: ImageUtils.buildImageUrl(message.mediaUrl!) ?? '',
                          placeholder: (_, __) => Container(width: 200, height: 150, color: Colors.black12, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (isMe && isLastInGroup)
             Padding(
               padding: const EdgeInsets.only(left: 4, bottom: 2),
               child: Icon(
                  message.status == MessageStatus.read ? Icons.check_circle : Icons.check_circle_outline,
                  size: 14,
                  color: message.status == MessageStatus.read ? AppColors.primary : Colors.grey[300],
               ),
             ),
        ],
      ),
    );
  }
}