class SendMessageRequest {
  final String content;
  final String? mediaObjectKey;
  final String? reaction;

  SendMessageRequest({
    String? content,
    this.mediaObjectKey,
    this.reaction,
  }) : content = content ?? '';

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (mediaObjectKey != null) 'mediaObjectKey': mediaObjectKey,
      if (reaction != null) 'reaction': reaction,
    };
  }
}



