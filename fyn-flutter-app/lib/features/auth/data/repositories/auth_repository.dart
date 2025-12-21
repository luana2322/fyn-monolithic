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
      throw _handleError(e);
    } catch (e) {
      // Handle other errors (parsing errors, etc.)
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
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
      throw _handleError(e);
    } catch (e) {
      // Handle other errors (parsing errors, etc.)
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
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
      throw _handleError(e);
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
      throw _handleError(e);
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
      throw _handleError(e);
    }
  }

  /// Xử lý lỗi
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        // Try to get detailed error message
        if (data['message'] != null) {
          final message = data['message'] as String;
          // Translate common error messages to Vietnamese
          return _translateErrorMessage(message);
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
          return _translateErrorMessage(data['error'].toString());
        }
      }
      // Return status message with status code
      final statusCode = error.response?.statusCode;
      if (statusCode == 400) {
        return 'Dữ liệu không hợp lệ';
      } else if (statusCode == 401) {
        return 'Không có quyền truy cập';
      } else if (statusCode == 404) {
        return 'Không tìm thấy tài nguyên';
      } else if (statusCode == 500) {
        return 'Lỗi server, vui lòng thử lại sau';
      }
      return error.response?.statusMessage ?? 'Có lỗi xảy ra';
    }
    return error.message ?? 'Có lỗi xảy ra';
  }

  /// Translate common error messages to Vietnamese
  String _translateErrorMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('invalid credentials') || 
        lowerMessage.contains('bad credentials')) {
      return 'Email/Username hoặc mật khẩu không chính xác';
    }
    if (lowerMessage.contains('user not found')) {
      return 'Tài khoản không tồn tại';
    }
    if (lowerMessage.contains('email already exists') ||
        lowerMessage.contains('email already registered')) {
      return 'Email đã được đăng ký';
    }
    if (lowerMessage.contains('username already exists') ||
        lowerMessage.contains('username already taken')) {
      return 'Username đã được sử dụng';
    }
    if (lowerMessage.contains('password') && lowerMessage.contains('weak')) {
      return 'Mật khẩu quá yếu';
    }
    if (lowerMessage.contains('account disabled') || 
        lowerMessage.contains('account locked')) {
      return 'Tài khoản đã bị khóa';
    }
    if (lowerMessage.contains('token expired') ||
        lowerMessage.contains('session expired')) {
      return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
    }
    
    // Return original message if no translation found
    return message;
  }
}
