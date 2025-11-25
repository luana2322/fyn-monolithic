import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/api_config.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/page_response.dart';
import '../../../../core/network/api_client.dart';
import '../models/create_post_request.dart';
import '../models/create_comment_request.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/post_reaction.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  Future<PageResponse<PostModel>> getFeed({int page = 0, int size = 10}) async {
    final response = await _apiClient.get(
      ApiEndpoints.feed,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<PageResponse<PostModel>>.fromJson(
      response.data,
      (data) => PageResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => PostModel.fromJson(item as Map<String, dynamic>),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể tải bài viết',
      );
    }

    return apiResponse.data!;
  }

  Future<PageResponse<PostModel>> getPostsByUser(
    String userId, {
    int page = 0,
    int size = 9,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.postsByUser(userId),
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<PageResponse<PostModel>>.fromJson(
      response.data,
      (data) => PageResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => PostModel.fromJson(item as Map<String, dynamic>),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể tải bài viết',
      );
    }

    return apiResponse.data!;
  }

  Future<PostModel> createPost(
    CreatePostRequest request, {
    List<XFile>? mediaFiles,
  }) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'payload',
        MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'payload.json',
          contentType: MediaType.parse('application/json'),
        ),
      ),
    );

    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      for (final file in mediaFiles) {
        MultipartFile multipartFile;
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          // Xác định content type dựa trên extension
          final contentType = _getContentType(file.name);
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: file.name,
            contentType: contentType,
          );
        } else {
          // Xác định content type dựa trên extension
          final contentType = _getContentType(file.name);
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: contentType,
          );
        }
        formData.files.add(MapEntry('media', multipartFile));
      }
    }

    final response = await _apiClient.post(
      ApiEndpoints.createPost,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final apiResponse = ApiResponse<PostModel>.fromJson(
      response.data,
      (data) => PostModel.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể tạo bài viết',
      );
    }

    return apiResponse.data!;
  }

  Future<void> deletePost(String postId) async {
    final response = await _apiClient.delete(ApiEndpoints.deletePost(postId));
    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể xóa bài viết',
      );
    }
  }

  Future<PostReaction> likePost(String postId) async {
    final response = await _apiClient.post(ApiEndpoints.likePost(postId));
    return _parseReaction(response);
  }

  Future<PostReaction> unlikePost(String postId) async {
    final response = await _apiClient.delete(ApiEndpoints.unlikePost(postId));
    return _parseReaction(response);
  }

  Future<List<CommentModel>> getComments(String postId) async {
    final response = await _apiClient.get(ApiEndpoints.comments(postId));
    final apiResponse =
        ApiResponse<List<CommentModel>>.fromJson(response.data, (data) {
      final list = data as List<dynamic>? ?? [];
      return list
          .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể tải bình luận',
      );
    }

    return apiResponse.data!;
  }

  Future<CommentModel> addComment(
    String postId,
    CreateCommentRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.addComment(postId),
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<CommentModel>.fromJson(
      response.data,
      (data) => CommentModel.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể thêm bình luận',
      );
    }

    return apiResponse.data!;
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final response =
        await _apiClient.delete(ApiEndpoints.deleteComment(postId, commentId));
    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể xóa bình luận',
      );
    }
  }

  MediaType? _getContentType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'webm':
        return MediaType('video', 'webm');
      default:
        return null; // Let server determine
    }
  }

  PostReaction _parseReaction(Response response) {
    final apiResponse = ApiResponse<PostReaction>.fromJson(
      response.data,
      (data) => PostReaction.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiResponse.message ?? 'Không thể cập nhật phản ứng',
      );
    }

    return apiResponse.data!;
  }
}

