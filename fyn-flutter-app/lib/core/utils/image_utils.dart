import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/app_config.dart';

/// Utility functions for handling image URLs
class ImageUtils {
  /// Build full URL for avatar/image from object key or partial URL
  /// Handles encoding of special characters
  static String? buildImageUrl(String? urlOrKey) {
    if (urlOrKey == null || urlOrKey.isEmpty) {
      return null;
    }

    // If it's already a full URL (starts with http:// or https://), return as is
    if (urlOrKey.startsWith('http://') || urlOrKey.startsWith('https://')) {
      // Với các URL đã được backend/presigned URL generate, không encode lại
      // để tránh làm hỏng chữ ký hoặc path đã được mã hóa sẵn.
      return urlOrKey;
    }

    // If it's an object key, build full URL
    // Backend typically serves files through /api/files/{objectKey} or similar
    final baseUrl = AppConfig.baseUrl;
    
    // Remove leading slash if present
    final cleanKey = urlOrKey.startsWith('/') ? urlOrKey.substring(1) : urlOrKey;
    
    // Try different possible endpoints
    // Option 1: /api/files/{key} (most common)
    // Option 2: /api/storage/{key}
    // Option 3: /api/files/download/{key}
    // For now, try /api/files/{key} - if this doesn't work, backend might need
    // to provide a file serving endpoint or return full MinIO URLs
    
    // Build URL with proper encoding of the key
    // Encode only the key part, not the entire path
    final encodedKey = Uri.encodeComponent(cleanKey);
    final fullUrl = '$baseUrl/api/files/$encodedKey';
    
    return fullUrl;
  }

  /// Encode URL to handle special characters (Vietnamese, spaces, etc.)
  static String _encodeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Split URL into parts
      final scheme = uri.scheme;
      final host = uri.host;
      final port = uri.hasPort ? ':${uri.port}' : '';
      final pathSegments = uri.pathSegments;
      
      // Encode each path segment
      final encodedSegments = pathSegments.map((segment) {
        // Encode the segment but preserve slashes
        return Uri.encodeComponent(segment);
      }).toList();
      
      // Rebuild URL
      final encodedPath = '/${encodedSegments.join('/')}';
      final query = uri.hasQuery ? '?${uri.query}' : '';
      final fragment = uri.hasFragment ? '#${uri.fragment}' : '';
      
      return '$scheme://$host$port$encodedPath$query$fragment';
    } catch (e) {
      // If parsing fails, try simple encoding
      return Uri.encodeFull(url);
    }
  }

  /// Get avatar URL with proper encoding
  static String? getAvatarUrl(String? avatarUrl) {
    return buildImageUrl(avatarUrl);
  }
}

