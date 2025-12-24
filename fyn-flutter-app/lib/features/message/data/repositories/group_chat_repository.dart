import 'package:dio/dio.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';
import '../models/conversation_model.dart';
import '../models/conversation_type.dart';

/// Repository for Group Chat APIs
class GroupChatRepository {
  final ApiClient _apiClient;

  GroupChatRepository(this._apiClient);

  /// Create a new friends group chat
  Future<ConversationModel> createFriendsGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/groups',
        data: {
          'name': name,
          'memberIds': memberIds,
        },
      );

      final apiResponse = ApiResponse<ConversationModel>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return ConversationModel(
              id: data['conversationId'] as String,
              type: ConversationType.friendsGroup,
              title: data['title'] as String?,
              memberIds: {},
              memberCount: data['memberCount'] as int? ?? 0,
            );
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể tạo nhóm chat',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add a member to a friends group
  Future<void> addMemberToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/groups/$groupId/members',
        data: {'userId': userId},
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (!apiResponse.success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể thêm thành viên',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove a member from a friends group
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/api/v1/groups/$groupId/members/$userId',
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (!apiResponse.success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể xoá thành viên',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update group name
  Future<ConversationModel> updateGroupName({
    required String groupId,
    required String newName,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/v1/groups/$groupId',
        data: {'name': newName},
      );

      final apiResponse = ApiResponse<ConversationModel>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return ConversationModel(
              id: data['conversationId'] as String,
              type: ConversationType.friendsGroup,
              title: data['title'] as String?,
              memberIds: {},
            );
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể cập nhật nhóm',
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
