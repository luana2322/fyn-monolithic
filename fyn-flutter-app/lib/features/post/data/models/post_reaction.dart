class PostReaction {
  final String postId;
  final int likeCount;
  final bool likedByCurrentUser;

  const PostReaction({
    required this.postId,
    required this.likeCount,
    required this.likedByCurrentUser,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      postId: json['postId'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      likedByCurrentUser: json['likedByCurrentUser'] as bool? ?? false,
    );
  }
}





