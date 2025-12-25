import '../../../../config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/post_report_model.dart';
import '../models/moderation_action_request.dart';

class ModerationRepository {
  final ApiClient _apiClient;

  ModerationRepository(this._apiClient);

  Future<List<PostReportModel>> getReportedPosts() async {
    final response = await _apiClient.get(ApiEndpoints.adminReportedPosts);
    return (response.data as List)
        .map((json) => PostReportModel.fromJson(json))
        .toList();
  }

  Future<void> hidePost(String postId, ModerationActionRequest request) async {
    await _apiClient.post(
      ApiEndpoints.adminHidePost(postId),
      data: request.toJson(),
    );
  }

  Future<void> deletePost(String postId, ModerationActionRequest request) async {
    await _apiClient.post(
      ApiEndpoints.adminDeletePost(postId),
      data: request.toJson(),
    );
  }

  Future<void> restorePost(String postId, ModerationActionRequest request) async {
    await _apiClient.post(
      ApiEndpoints.adminRestorePost(postId),
      data: request.toJson(),
    );
  }

  Future<void> markReportValid(String reportId, ModerationActionRequest request) async {
    await _apiClient.post(
      ApiEndpoints.adminMarkReportValid(reportId),
      data: request.toJson(),
    );
  }

  Future<void> markReportInvalid(String reportId, ModerationActionRequest request) async {
    await _apiClient.post(
      ApiEndpoints.adminMarkReportInvalid(reportId),
      data: request.toJson(),
    );
  }
}
