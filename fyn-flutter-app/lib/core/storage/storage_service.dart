import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../network/api_client.dart';

/// Service for uploading files to MinIO storage
class StorageService {
  final ApiClient _apiClient;

  StorageService(this._apiClient);

  /// Upload image to MinIO and return the URL
  Future<String> uploadImage(XFile image, {String folder = 'stories'}) async {
    try {
      // Read image bytes
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Create multipart form data
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
        'folder': folder,
      });

      // Upload to backend
      final response = await _apiClient.post(
        '/api/v1/upload',
        data: formData,
      );

      // Return the file URL
      if (response.data != null && response.data['url'] != null) {
        return response.data['url'];
      } else if (response.data != null && response.data['data'] != null && response.data['data']['url'] != null) {
        return response.data['data']['url'];
      }
      
      throw Exception('Upload response missing URL');
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload image and return MinIO URL directly
  Future<String> uploadStoryImage(XFile image) async {
    return await uploadImage(image, folder: 'stories');
  }
}
