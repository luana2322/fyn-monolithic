import 'post_visibility.dart';

class CreatePostRequest {
  final String? content;  // Optional - can be null or empty
  final Set<String>? hashtags;
  final Set<String>? mentionUsernames;
  final PostVisibility visibility;
  final double? latitude;
  final double? longitude;
  final String? placeCode;

  CreatePostRequest({
    this.content,  // Now optional
    this.hashtags,
    this.mentionUsernames,
    this.visibility = PostVisibility.public,
    this.latitude,
    this.longitude,
    this.placeCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content ?? '',  // Send empty string if null
      if (hashtags != null) 'hashtags': hashtags!.toList(),
      if (mentionUsernames != null) 'mentionUsernames': mentionUsernames!.toList(),
      'visibility': visibility.serverValue,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeCode != null) 'placeCode': placeCode,
    };
  }
}

