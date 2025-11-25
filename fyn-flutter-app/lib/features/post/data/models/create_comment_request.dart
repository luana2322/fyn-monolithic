class CreateCommentRequest {
  final String content;
  final String? parentCommentId;

  CreateCommentRequest({
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    };
  }
}





