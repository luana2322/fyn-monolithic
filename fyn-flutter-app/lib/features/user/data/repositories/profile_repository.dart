import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';
import '../../../auth/data/models/user_response.dart';
import '../models/update_profile_request.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  /// Cập nhật profile
  Future<UserResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: request.toJson(),
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
          message: apiResponse.message ?? 'Cập nhật profile thất bại',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Upload avatar
  Future<UserResponse> uploadAvatar(XFile imageFile) async {
    try {
      MultipartFile multipartFile;
      
      if (kIsWeb) {
        // Web platform: read bytes from XFile
        final bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.split('/').last,
        );
      } else {
        // Mobile/Desktop platform: use file path
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name.split('/').last,
        );
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await _apiClient.post(
        ApiEndpoints.changeAvatar,
        data: formData,
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
          message: apiResponse.message ?? 'Upload avatar thất bại',
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

