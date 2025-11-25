import '../../../../core/utils/date_utils.dart';
import 'conversation_type.dart';

class ConversationModel {
  final String id;
  final ConversationType type;
  final String? title;
  final Set<String> memberIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? otherUserId; // For direct messages
  final String? otherUserAvatar;
  final String? otherUserName;

  ConversationModel({
    required this.id,
    required this.type,
    this.title,
    required this.memberIds,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.otherUserId,
    this.otherUserAvatar,
    this.otherUserName,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      type: ConversationType.fromString(json['type'] as String?),
      title: json['title'] as String?,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      createdAt: DateUtils.parseIso8601(json['createdAt'] as String?),
      updatedAt: DateUtils.parseIso8601(json['updatedAt'] as String?),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: DateUtils.parseIso8601(json['lastMessageAt'] as String?),
      otherUserId: json['otherUserId'] as String?,
      otherUserAvatar: json['otherUserAvatar'] as String?,
      otherUserName: json['otherUserName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.serverValue,
      if (title != null) 'title': title,
      'memberIds': memberIds.toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}



