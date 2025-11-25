import '../../../auth/data/models/user_response.dart';
import '../../../../core/utils/date_utils.dart';

class CommentModel {
  final String id;
  final String? parentId;
  final UserResponse author;
  final String content;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.parentId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      author: UserResponse.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      createdAt: DateUtils.parseIso8601(json['createdAt'] as String?),
    );
  }
}





