import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/page_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/api_config.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/create_conversation_request.dart';
import '../models/send_message_request.dart';

class MessageRepository {
  final ApiClient _apiClient;
  final String _currentUserId;

  MessageRepository(this._apiClient, this._currentUserId);

  /// Lấy danh sách conversations
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.conversations);

      final apiResponse = ApiResponse<List<ConversationModel>>.fromJson(
        response.data,
        (data) {
          if (data is List<dynamic>) {
            return data
                .map((item) => ConversationModel.fromJson(
                    item as Map<String, dynamic>))
                .toList();
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể tải danh sách chat',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Tạo conversation mới
  Future<ConversationModel> createConversation(
    CreateConversationRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.conversations,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<ConversationModel>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return ConversationModel.fromJson(data);
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể tạo cuộc trò chuyện',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Lấy danh sách messages trong conversation
  Future<PageResponse<MessageModel>> getMessages(
    String conversationId, {
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: {'page': page, 'size': size},
      );

      final apiResponse =
          ApiResponse<PageResponse<MessageModel>>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return PageResponse<MessageModel>.fromJson(
              data,
              (item) => MessageModel.fromJson(
                item as Map<String, dynamic>,
                _currentUserId,
              ),
            );
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể tải tin nhắn',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  /// Gửi tin nhắn
  Future<MessageModel> sendMessage(
    String conversationId,
    SendMessageRequest request, {
    XFile? mediaFile,
  }) async {
    try {
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

      if (mediaFile != null) {
        MultipartFile multipartFile;
        if (kIsWeb) {
          final bytes = await mediaFile.readAsBytes();
          // Xác định content type dựa trên extension
          final extension = mediaFile.name.split('.').last.toLowerCase();
          final contentType = _getContentType(extension);
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: mediaFile.name,
            contentType: contentType,
          );
        } else {
          final extension = mediaFile.path.split('.').last.toLowerCase();
          final contentType = _getContentType(extension);
          multipartFile = await MultipartFile.fromFile(
            mediaFile.path,
            filename: mediaFile.name,
            contentType: contentType,
          );
        }
        formData.files.add(MapEntry('media', multipartFile));
      }

      final response = await _apiClient.post(
        ApiEndpoints.sendMessage(conversationId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final apiResponse = ApiResponse<MessageModel>.fromJson(
        response.data,
        (data) {
          if (data is Map<String, dynamic>) {
            return MessageModel.fromJson(data, _currentUserId);
          }
          throw Exception('Invalid response data format');
        },
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: apiResponse.message ?? 'Không thể gửi tin nhắn',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Lỗi xử lý dữ liệu: ${e.toString()}';
    }
  }

  MediaType _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
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
      final statusCode = error.response?.statusCode;
      if (statusCode == 400) {
        return 'Dữ liệu không hợp lệ';
      } else if (statusCode == 401) {
        return 'Không có quyền truy cập';
      } else if (statusCode == 404) {
        return 'Không tìm thấy';
      } else if (statusCode == 500) {
        return 'Lỗi server';
      }
    }
    return error.message ?? 'Có lỗi xảy ra';
  }
}

