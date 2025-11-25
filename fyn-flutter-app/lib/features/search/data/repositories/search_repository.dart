import 'package:dio/dio.dart';

import '../../../../config/api_config.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_response.dart';

class SearchRepository {
  final ApiClient _apiClient;

  SearchRepository(this._apiClient);

  Future<List<UserResponse>> searchUsers(String query) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchUsers,
        queryParameters: {'query': query},
      );

      final apiResponse = ApiResponse<List<UserResponse>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(UserResponse.fromJson)
                .toList();
          }
          return <UserResponse>[];
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể tìm kiếm người dùng',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi xử lý dữ liệu: $e');
    }
  }
}

