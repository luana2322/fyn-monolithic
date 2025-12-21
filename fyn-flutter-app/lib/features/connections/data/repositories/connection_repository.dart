import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';

/// Repository for managing user connections/follows
class ConnectionRepository {
  final ApiClient _apiClient;

  ConnectionRepository(this._apiClient);

  /// Get list of user IDs that the current user is following
  Future<List<String>> getFollowingUserIds() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.followingIds,
      );

      if (response.data['data'] != null) {
        return List<String>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching following user IDs: $e');
      return [];
    }
  }

  /// Follow a user
  Future<void> followUser(String userId) async {
    await _apiClient.post(
      '${ApiEndpoints.followUser}/$userId',
    );
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    await _apiClient.delete(
      '${ApiEndpoints.followUser}/$userId',
    );
  }
}
