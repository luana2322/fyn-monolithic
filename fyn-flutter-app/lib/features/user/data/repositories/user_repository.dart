import 'package:dio/dio.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';
import '../../../auth/data/models/user_response.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  /// Lấy thông tin user theo ID
  Future<UserResponse> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userById(userId),
      );

      final apiResponse = ApiResponse<UserResponse>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return UserResponse.fromJson(data);
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Lấy thông tin user thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Lấy thông tin user theo username
  Future<UserResponse> getUserByUsername(String username) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userByUsername(username),
      );

      final apiResponse = ApiResponse<UserResponse>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return UserResponse.fromJson(data);
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Lấy thông tin user thất bại',
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
        return 'Không tìm thấy user';
      } else if (statusCode == 500) {
        return 'Lỗi server: $statusMessage';
      }
      return statusMessage;
    }
    return error.message ?? 'Có lỗi xảy ra';
  }
}

