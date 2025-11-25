import 'post_visibility.dart';

class CreatePostRequest {
  final String content;
  final Set<String>? hashtags;
  final Set<String>? mentionUsernames;
  final PostVisibility visibility;

  CreatePostRequest({
    required this.content,
    this.hashtags,
    this.mentionUsernames,
    this.visibility = PostVisibility.public,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (hashtags != null) 'hashtags': hashtags!.toList(),
      if (mentionUsernames != null) 'mentionUsernames': mentionUsernames!.toList(),
      'visibility': visibility.serverValue,
    };
  }
}

