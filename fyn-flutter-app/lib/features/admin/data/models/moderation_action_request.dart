class ModerationActionRequest {
  final String? reason;
  final String? adminComment;

  ModerationActionRequest({
    this.reason,
    this.adminComment,
  });

  Map<String, dynamic> toJson() {
    return {
      if (reason != null) 'reason': reason,
      if (adminComment != null) 'adminComment': adminComment,
    };
  }
}
