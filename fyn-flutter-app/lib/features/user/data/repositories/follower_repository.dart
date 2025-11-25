import 'package:dio/dio.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/page_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';
import '../../../auth/data/models/user_response.dart';

class FollowerRepository {
  final ApiClient _apiClient;

  FollowerRepository(this._apiClient);

  /// Follow user
  Future<void> follow(String userId) async {
    try {
      await _apiClient.post(ApiEndpoints.follow(userId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unfollow user
  Future<void> unfollow(String userId) async {
    try {
      await _apiClient.delete(ApiEndpoints.unfollow(userId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy danh sách followers
  Future<PageResponse<UserResponse>> getFollowers(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.followers(userId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponse<PageResponse<UserResponse>>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return PageResponse<UserResponse>.fromJson(
              data,
              (item) => UserResponse.fromJson(item as Map<String, dynamic>),
            );
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Lấy danh sách followers thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Lấy danh sách following
  Future<PageResponse<UserResponse>> getFollowing(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.following(userId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponse<PageResponse<UserResponse>>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return PageResponse<UserResponse>.fromJson(
              data,
              (item) => UserResponse.fromJson(item as Map<String, dynamic>),
            );
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Lấy danh sách following thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Xử lý lỗi
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'] as String;
        }
        if (data['errors'] != null && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.join(', ');
          }
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
      }
      final statusCode = error.response?.statusCode;
      final statusMessage = error.response?.statusMessage ?? 'Có lỗi xảy ra';
      if (statusCode == 400) {
        return 'Dữ liệu không hợp lệ: $statusMessage';
      } else if (statusCode == 401) {
        return 'Không có quyền truy cập';
      } else if (statusCode == 404) {
        return 'Không tìm thấy';
      } else if (statusCode == 500) {
        return 'Lỗi server: $statusMessage';
      }
      return statusMessage;
    }
    return error.message ?? 'Có lỗi xảy ra';
  }
}

