import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/app_config.dart';

/// Utility functions for handling image URLs
class ImageUtils {
  // MinIO server hostname to use based on platform
  static String get _minioHost {
    if (kIsWeb) {
      return 'localhost:9000';
    }
    try {
      if (Platform.isAndroid) {
        // Use the same IP as the backend server for Android
        return '192.168.1.175:9000';
      }
    } catch (e) {
      // Fallback
    }
    return 'localhost:9000';
  }

  /// Build full URL for avatar/image from object key or partial URL
  /// Handles encoding of special characters
  static String? buildImageUrl(String? urlOrKey) {
    if (urlOrKey == null || urlOrKey.isEmpty) {
      return null;
    }

    // If it's already a full URL (starts with http:// or https://)
    if (urlOrKey.startsWith('http://') || urlOrKey.startsWith('https://')) {
      // Fix Docker internal hostname for access from current platform
      String fixedUrl = urlOrKey;
      
      // Replace Docker internal hostnames with actual accessible host
      final minioHost = _minioHost;
      if (fixedUrl.contains('fyn-minio:9000')) {
        fixedUrl = fixedUrl.replaceAll('fyn-minio:9000', minioHost);
      }
      if (fixedUrl.contains('fyn-minio:9001')) {
        fixedUrl = fixedUrl.replaceAll('fyn-minio:9001', minioHost.replaceAll(':9000', ':9001'));
      }
      // Also handle minio container name without prefix
      if (fixedUrl.contains('minio:9000')) {
        fixedUrl = fixedUrl.replaceAll('minio:9000', minioHost);
      }
      // Handle localhost for Android (in case backend returns localhost URLs)
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid && fixedUrl.contains('localhost:9000')) {
            fixedUrl = fixedUrl.replaceAll('localhost:9000', minioHost);
          }
        } catch (e) {
          // Ignore
        }
      }
      return fixedUrl;
    }

    // If it's an object key, build full URL
    // Backend typically serves files through /api/files/{objectKey} or similar
    final baseUrl = AppConfig.baseUrl;
    
    // Remove leading slash if present
    final cleanKey = urlOrKey.startsWith('/') ? urlOrKey.substring(1) : urlOrKey;
    
    // Build URL with proper encoding of the key
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

