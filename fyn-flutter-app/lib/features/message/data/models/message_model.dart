import '../../../../core/utils/date_utils.dart';
import 'message_status.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final MessageStatus status;
  final DateTime? createdAt;
  final String? mediaUrl;
  final String? reaction;
  final bool isFromCurrentUser;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    required this.status,
    this.createdAt,
    this.mediaUrl,
    this.reaction,
    required this.isFromCurrentUser,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
      content: json['content'] as String? ?? '',
      status: MessageStatus.fromString(json['status'] as String?),
      createdAt: DateUtils.parseIso8601(json['createdAt'] as String?),
      mediaUrl: json['mediaUrl'] as String?,
      reaction: json['reaction'] as String?,
      isFromCurrentUser: json['senderId'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      if (senderAvatar != null) 'senderAvatar': senderAvatar,
      'content': content,
      'status': status.toString(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (reaction != null) 'reaction': reaction,
    };
  }
}



