import 'package:fyn_flutter_app/core/utils/date_utils.dart' as app_date_utils;

class NotificationModel {
  final String id;
  final NotificationType type;
  final NotificationStatus status;
  final String message;
  final String? referenceId;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.status,
    required this.message,
    this.referenceId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: NotificationTypeX.fromString(json['type'] as String?),
      status: NotificationStatusX.fromString(json['status'] as String?),
      message: json['message'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      createdAt: app_date_utils.DateUtils.parseIso8601(json['createdAt'] as String?),
    );
  }
}

enum NotificationType { follow, like, comment, message, system }

extension NotificationTypeX on NotificationType {
  static NotificationType fromString(String? value) {
    switch (value) {
      case 'FOLLOW':
        return NotificationType.follow;
      case 'LIKE':
        return NotificationType.like;
      case 'COMMENT':
        return NotificationType.comment;
      case 'MESSAGE':
        return NotificationType.message;
      case 'SYSTEM':
      default:
        return NotificationType.system;
    }
  }
}

enum NotificationStatus { unread, read }

extension NotificationStatusX on NotificationStatus {
  static NotificationStatus fromString(String? value) {
    switch (value) {
      case 'READ':
        return NotificationStatus.read;
      case 'UNREAD':
      default:
        return NotificationStatus.unread;
    }
  }

  bool get isUnread => this == NotificationStatus.unread;
}


