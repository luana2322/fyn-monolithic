class SendMessageRequest {
  final String content;
  final String? mediaObjectKey;
  final String? reaction;

  SendMessageRequest({
    required this.content,
    this.mediaObjectKey,
    this.reaction,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (mediaObjectKey != null) 'mediaObjectKey': mediaObjectKey,
      if (reaction != null) 'reaction': reaction,
    };
  }
}



