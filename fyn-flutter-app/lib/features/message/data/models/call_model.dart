class CallModel {
  final String id;
  final String conversationId;
  final String callerId;
  final String calleeId;
  final String roomId;
  final String status;

  CallModel({
    required this.id,
    required this.conversationId,
    required this.callerId,
    required this.calleeId,
    required this.roomId,
    required this.status,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      callerId: json['callerId'] as String,
      calleeId: json['calleeId'] as String,
      roomId: json['roomId'] as String? ?? '',
      status: json['status'] as String? ?? 'RINGING',
    );
  }
}


