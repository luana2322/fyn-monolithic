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
import '../models/post_model.dart';

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
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: file.name,
          );
        } else {
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: file.name,
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
}

