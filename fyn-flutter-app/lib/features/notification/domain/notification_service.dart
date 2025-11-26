import '../../notification/data/models/notification_model.dart';
import '../../notification/data/repositories/notification_repository.dart';
import '../../../core/models/page_response.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

  Future<PageResponse<NotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
  }) {
    return _repository.getNotifications(page: page, size: size);
  }

  Future<void> markAsRead(String notificationId) {
    return _repository.markAsRead(notificationId);
  }

  Future<int> getUnreadCount() {
    return _repository.getUnreadCount();
  }
}


