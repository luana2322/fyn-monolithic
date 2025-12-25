import '../../../../config/api_config.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/page_response.dart';
import '../../../../core/network/api_client.dart';
import '../models/post_report_model.dart';
import '../models/moderation_action_request.dart';

class ModerationRepository {
  final ApiClient _apiClient;

  ModerationRepository(this._apiClient);

  Future<List<PostReportModel>> getReportedPosts() async {
    final response = await _apiClient.get(ApiEndpoints.adminReportedPosts);
    
    final apiResponse = ApiResponse<PageResponse<PostReportModel>>.fromJson(
      response.data,
      (data) => PageResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => PostReportModel.fromJson(item as Map<String, dynamic>),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      return [];
    }

    return apiResponse.data!.content;
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
