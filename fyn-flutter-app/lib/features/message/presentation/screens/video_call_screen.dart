import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../../config/app_config.dart';
import '../../../../theme/app_colors.dart';

/// Màn hình VideoCall sử dụng WebRTC + STOMP/WebSocket để signaling.
///
/// Lưu ý:
///  - Cần thêm package trong pubspec.yaml:
///      flutter_webrtc: ^0.9.41
///      stomp_dart_client: ^0.4.4
///  - WebSocket BE: ws://<host>:8080/ws (đã cấu hình trong WebSocketConfig)
///  - Signaling channel:
///      send: /app/call/{conversationId}
///      sub : /topic/call/{conversationId}
class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String roomId;
  final String calleeName;

  /// ID của cuộc trò chuyện dùng làm "room" signaling
  final String conversationId;

  /// ID của current user
  final String currentUserId;

  /// ID của người còn lại trong cuộc gọi
  final String otherUserId;

  /// true nếu mở từ phía người gọi (caller)
  final bool isCaller;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.roomId,
    required this.calleeName,
    required this.conversationId,
    required this.currentUserId,
    required this.otherUserId,
    required this.isCaller,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  StompClient? _stompClient;

  bool _isConnecting = true;
  bool _micEnabled = true;
  bool _camEnabled = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    await _connectSignaling();
    await _createPeerConnection();
  }

  Future<void> _connectSignaling() async {
    final wsUrl = AppConfig.baseUrl
        .replaceFirst('http', 'ws')
        .split('/api')
        .first; // ví dụ: http://localhost:8080 -> ws://localhost:8080

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '$wsUrl/ws',
        onConnect: _onStompConnected,
        onStompError: (frame) => debugPrint('STOMP error: ${frame.body}'),
        onWebSocketError: (err) => debugPrint('WS error: $err'),
      ),
    );
    _stompClient!.activate();
  }

  void _onStompConnected(StompFrame frame) {
    _stompClient?.subscribe(
      destination: '/topic/call/${widget.conversationId}',
      callback: (msgFrame) {
        if (msgFrame.body == null) return;
        final data = jsonDecode(msgFrame.body!) as Map<String, dynamic>;
        _handleSignal(data);
      },
    );
    setState(() => _isConnecting = false);
  }

  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _pc = await createPeerConnection(configuration);

    _pc!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendSignal({
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _pc!.onAddStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    // Lấy local stream (camera + mic)
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _pc!.addStream(_localStream!);
    _localRenderer.srcObject = _localStream;

    // Caller khởi tạo offer
    if (widget.isCaller) {
      final offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);
      _sendSignal({'type': 'offer', 'sdp': offer.sdp});
    }
  }

  void _sendSignal(Map<String, dynamic> payload) {
    if (_stompClient == null || !_stompClient!.connected) return;

    final body = {
      ...payload,
      'fromUserId': widget.currentUserId,
      'toUserId': widget.otherUserId,
      'conversationId': widget.conversationId,
    };

    _stompClient!.send(
      destination: '/app/call/${widget.conversationId}',
      body: jsonEncode(body),
    );
  }

  Future<void> _handleSignal(Map<String, dynamic> msg) async {
    final type = msg['type'] as String? ?? '';

    switch (type) {
      case 'offer':
        if (_pc == null) return;
        final sdp = msg['sdp'] as String?;
        if (sdp == null) return;
        await _pc!.setRemoteDescription(
          RTCSessionDescription(sdp, 'offer'),
        );
        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);
        _sendSignal({'type': 'answer', 'sdp': answer.sdp});
        break;
      case 'answer':
        if (_pc == null) return;
        final sdp = msg['sdp'] as String?;
        if (sdp == null) return;
        await _pc!.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer'),
        );
        break;
      case 'candidate':
        if (_pc == null) return;
        final candidate = msg['candidate'] as String?;
        final sdpMid = msg['sdpMid'] as String?;
        final sdpMLineIndex = msg['sdpMLineIndex'] as int?;
        if (candidate == null || sdpMid == null || sdpMLineIndex == null) {
          return;
        }
        await _pc!.addCandidate(
          RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
        );
        break;
      case 'hangup':
        _onHangupReceived();
        break;
    }
  }

  void _onHangupReceived() {
    _disposeCall();
    if (mounted) Navigator.pop(context);
  }

  void _disposeCall() {
    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream?.dispose();
    _pc?.close();
    _pc?.dispose();
    _stompClient?.deactivate();
  }

  @override
  void dispose() {
    _disposeCall();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.calleeName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Remote video full screen
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: RTCVideoView(
                        _remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  // Local preview nhỏ góc trên phải
                  Positioned(
                    top: 16,
                    right: 16,
                    width: 120,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.black54,
                        child: RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                  ),
                  if (_isConnecting)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _roundButton(
            icon: _camEnabled ? Icons.videocam : Icons.videocam_off,
            color: Colors.white,
            background: Colors.white24,
            onTap: _toggleCamera,
          ),
          const SizedBox(width: 24),
          _roundButton(
            icon: Icons.call_end,
            color: Colors.white,
            background: AppColors.error,
            onTap: _hangup,
          ),
          const SizedBox(width: 24),
          _roundButton(
            icon: _micEnabled ? Icons.mic : Icons.mic_off,
            color: Colors.white,
            background: Colors.white24,
            onTap: _toggleMic,
          ),
        ],
      ),
    );
  }

  void _toggleMic() {
    if (_localStream == null) return;
    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isEmpty) return;
    final enabled = !audioTracks.first.enabled;
    for (final t in audioTracks) {
      t.enabled = enabled;
    }
    setState(() => _micEnabled = enabled);
  }

  void _toggleCamera() {
    if (_localStream == null) return;
    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isEmpty) return;
    final enabled = !videoTracks.first.enabled;
    for (final t in videoTracks) {
      t.enabled = enabled;
    }
    setState(() => _camEnabled = enabled);
  }

  void _hangup() {
    _sendSignal({'type': 'hangup'});
    _disposeCall();
    if (mounted) Navigator.pop(context);
  }

  static Widget _roundButton({
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
