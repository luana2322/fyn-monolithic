import 'package:dio/dio.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/refresh_token_request.dart';
import '../models/token_response.dart';
import '../models/user_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Đăng ký
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      // Debug: Print response for troubleshooting
      // print('Register response: ${response.data}');

      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        response.data,
        (data) {
          try {
            if (data is Map<String, dynamic>) {
              return AuthResponse.fromJson(data);
            }
            throw Exception('Invalid response data format');
          } catch (e) {
            // Log parsing error for debugging
            print('Error parsing AuthResponse: $e');
            print('Data: $data');
            rethrow;
          }
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Đăng ký thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      final errorMessage = _handleError(e);
      throw Exception(errorMessage);
    } catch (e) {
      // Handle other errors (parsing errors, etc.)
      final errorMessage = e is String 
          ? e 
          : 'Lỗi xử lý dữ liệu: ${e.toString()}';
      throw Exception(errorMessage);
    }
  }

  /// Đăng nhập
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        response.data,
        (data) {
          try {
            if (data is Map<String, dynamic>) {
              return AuthResponse.fromJson(data);
            }
            throw Exception('Invalid response data format');
          } catch (e) {
            // Log parsing error for debugging
            print('Error parsing AuthResponse: $e');
            print('Data: $data');
            rethrow;
          }
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Đăng nhập thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      final errorMessage = _handleError(e);
      throw Exception(errorMessage);
    } catch (e) {
      // Handle other errors (parsing errors, etc.)
      final errorMessage = e is String 
          ? e 
          : 'Lỗi xử lý dữ liệu: ${e.toString()}';
      throw Exception(errorMessage);
    }
  }

  /// Refresh token
  Future<TokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refresh,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<TokenResponse>.fromJson(
        response.data,
        (data) => TokenResponse.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Refresh token thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      final errorMessage = _handleError(e);
      throw Exception(errorMessage);
    }
  }

  /// Đăng xuất
  Future<void> logout(RefreshTokenRequest request) async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      final errorMessage = _handleError(e);
      throw Exception(errorMessage);
    }
  }

  /// Lấy thông tin user hiện tại
  Future<UserResponse> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.currentUser);

      final apiResponse = ApiResponse<UserResponse>.fromJson(
        response.data,
        (data) => UserResponse.fromJson(data as Map<String, dynamic>),
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
      final errorMessage = _handleError(e);
      throw Exception(errorMessage);
    }
  }

  /// Xử lý lỗi
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        // Try to get detailed error message
        if (data['message'] != null) {
          return data['message'] as String;
        }
        // Try to get validation errors
        if (data['errors'] != null && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.join(', ');
          }
        }
        // Try to get error details
        if (data['error'] != null) {
          return data['error'].toString();
        }
      }
      // Return status message with status code
      final statusCode = error.response?.statusCode;
      final statusMessage = error.response?.statusMessage ?? 'Có lỗi xảy ra';
      if (statusCode == 400) {
        return 'Dữ liệu không hợp lệ: $statusMessage';
      } else if (statusCode == 401) {
        return 'Không có quyền truy cập';
      } else if (statusCode == 404) {
        return 'Không tìm thấy tài nguyên';
      } else if (statusCode == 500) {
        return 'Lỗi server: $statusMessage';
      }
      return statusMessage;
    }
    return error.message ?? 'Có lỗi xảy ra';
  }
}

