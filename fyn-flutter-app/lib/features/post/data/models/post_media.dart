import '../../../../core/utils/image_utils.dart';

enum PostMediaType { image, video, audio, file }

class PostMedia {
  final String? objectKey;
  final String? mediaUrl;
  final PostMediaType mediaType;
  final String? description;

  const PostMedia({
    this.objectKey,
    this.mediaUrl,
    required this.mediaType,
    this.description,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      objectKey: json['objectKey'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: _typeFromString(json['mediaType'] as String?),
      description: json['description'] as String?,
    );
  }

  static PostMediaType _typeFromString(String? value) {
    switch (value) {
      case 'VIDEO':
        return PostMediaType.video;
      case 'AUDIO':
        return PostMediaType.audio;
      case 'FILE':
        return PostMediaType.file;
      case 'IMAGE':
      default:
        return PostMediaType.image;
    }
  }

  String? get resolvedUrl {
    if (mediaUrl != null && mediaUrl!.isNotEmpty) {
      return ImageUtils.buildImageUrl(mediaUrl);
    }
    if (objectKey != null && objectKey!.isNotEmpty) {
      return ImageUtils.buildImageUrl(objectKey);
    }
    return null;
  }

  bool get isImage => mediaType == PostMediaType.image;

  bool get isVideo => mediaType == PostMediaType.video;
}

