/// Call status enum
enum CallStatus {
  idle,       // No active call
  calling,    // Outgoing call, waiting for answer
  ringing,    // Incoming call, not answered yet
  connecting, // Call accepted, establishing connection
  active,     // Call connected and active
  ended,      // Call ended normally
  rejected,   // Call was rejected
  failed,     // Call failed to connect
}

/// Call state model
class CallState {
  final CallStatus status;
  final String? callId;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final bool isMuted;
  final bool isVideoEnabled;
  final String? error;
  final Duration? duration;

  const CallState({
    this.status = CallStatus.idle,
    this.callId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.error,
    this.duration,
  });

  CallState copyWith({
    CallStatus? status,
    String? callId,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    bool? isMuted,
    bool? isVideoEnabled,
    String? error,
    Duration? duration,
  }) {
    return CallState(
      status: status ?? this.status,
      callId: callId ?? this.callId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      error: error ?? this.error,
      duration: duration ?? this.duration,
    );
  }

  bool get isIdle => status == CallStatus.idle;
  bool get isCalling => status == CallStatus.calling;
  bool get isRinging => status == CallStatus.ringing;
  bool get isActive => status == CallStatus.active;
  bool get hasCall => callId != null;
}
