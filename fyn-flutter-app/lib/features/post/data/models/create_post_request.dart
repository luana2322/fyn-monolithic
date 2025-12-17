import 'post_visibility.dart';

class CreatePostRequest {
  final String? content;  // Optional - can be null or empty
  final Set<String>? hashtags;
  final Set<String>? mentionUsernames;
  final PostVisibility visibility;

  CreatePostRequest({
    this.content,  // Now optional
    this.hashtags,
    this.mentionUsernames,
    this.visibility = PostVisibility.public,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content ?? '',  // Send empty string if null
      if (hashtags != null) 'hashtags': hashtags!.toList(),
      if (mentionUsernames != null) 'mentionUsernames': mentionUsernames!.toList(),
      'visibility': visibility.serverValue,
    };
  }
}

