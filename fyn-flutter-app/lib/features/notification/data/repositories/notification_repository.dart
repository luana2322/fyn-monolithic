import 'package:dio/dio.dart';

import '../../../../config/api_config.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/page_response.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<PageResponse<NotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<PageResponse<NotificationModel>>.fromJson(
      response.data,
      (data) => PageResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể tải thông báo',
      );
    }

    return apiResponse.data!;
  }

  Future<void> markAsRead(String notificationId) async {
    final response = await _apiClient.post(
      ApiEndpoints.markNotificationRead(notificationId),
    );
    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể cập nhật thông báo',
      );
    }
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.unreadNotificationCount);
    final apiResponse = ApiResponse<int>.fromJson(
      response.data,
      (data) => (data as num).toInt(),
    );
    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể tải số lượng thông báo chưa đọc',
      );
    }
    return apiResponse.data!;
  }
}


