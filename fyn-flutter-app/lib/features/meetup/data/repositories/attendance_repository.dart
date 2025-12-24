import 'package:dio/dio.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_client.dart';

/// Repository for attendance confirmation APIs
class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  /// Confirm attendance for a meetup
  Future<AttendanceResult> confirmAttendance({
    required String meetupId,
    required String status, // 'CONFIRMED' or 'NO_SHOW'
    String? feedback,
    double? rating,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/meetups/$meetupId/attendance',
        data: {
          'status': status,
          if (feedback != null) 'feedback': feedback,
          if (rating != null) 'rating': rating,
        },
      );

      final apiResponse = ApiResponse<AttendanceResult>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return AttendanceResult(
              status: data['status'] as String,
              confirmedAt: DateTime.parse(data['confirmedAt'] as String),
            );
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể xác nhận tham dự',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'] as String;
        }
      }
    }
    return error.message ?? 'Có lỗi xảy ra';
  }
}

/// Result model for attendance confirmation
class AttendanceResult {
  final String status;
  final DateTime confirmedAt;

  AttendanceResult({
    required this.status,
    required this.confirmedAt,
  });
}
