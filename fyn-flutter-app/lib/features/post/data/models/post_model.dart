import '../../../../core/utils/date_utils.dart';
import '../../../auth/data/models/user_response.dart';
import 'post_media.dart';
import 'post_visibility.dart';

class PostModel {
  final String id;
  final UserResponse author;
  final String content;
  final PostVisibility visibility;
  final int likeCount;
  final int commentCount;
  final DateTime? createdAt;
  final List<PostMedia> media;
  final bool likedByCurrentUser;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.media,
    required this.likedByCurrentUser,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      author: UserResponse.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      visibility: PostVisibility.fromServerValue(json['visibility'] as String?),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      likedByCurrentUser: json['likedByCurrentUser'] as bool? ?? false,
      createdAt: DateUtils.parseIso8601(json['createdAt'] as String?),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((item) => PostMedia.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  PostModel copyWith({
    int? likeCount,
    int? commentCount,
    bool? likedByCurrentUser,
  }) {
    return PostModel(
      id: id,
      author: author,
      content: content,
      visibility: visibility,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      media: media,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
    );
  }
}

