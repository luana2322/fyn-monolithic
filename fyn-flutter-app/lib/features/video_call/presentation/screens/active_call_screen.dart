import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import '../../providers/call_provider.dart';
import '../../models/call_state.dart';

/// Active call screen with video views and controls
class ActiveCallScreen extends ConsumerStatefulWidget {
  final String callId;

  const ActiveCallScreen({
    super.key,
    required this.callId,
  });

  @override
  ConsumerState<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends ConsumerState<ActiveCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _startDurationTimer();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Get streams from provider
    final callNotifier = ref.read(callProvider.notifier);
    final localStream = callNotifier.localStream;
    final remoteStream = callNotifier.remoteStream;

    if (localStream != null) {
      _localRenderer.srcObject = localStream;
    }

    if (remoteStream != null) {
      _remoteRenderer.srcObject = remoteStream;
    }

    // Listen for remote stream updates
    ref.read(callProvider.notifier);
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);

    // Listen for call end
    ref.listen<CallState>(callProvider, (previous, next) {
      if (next.status == CallStatus.ended && mounted) {
        context.pop();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _endCall();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Remote video (full screen)
            Positioned.fill(
              child: _remoteRenderer.srcObject != null
                  ? RTCVideoView(
                      _remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: false,
                    )
                  : Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: callState.otherUserAvatar != null
                                  ? NetworkImage(callState.otherUserAvatar!)
                                  : null,
                              child: callState.otherUserAvatar == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              callState.otherUserName ?? 'Connecting...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(color: Colors.white),
                          ],
                        ),
                      ),
                    ),
            ),

            // Local video (picture-in-picture)
            Positioned(
              top: 50,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _localRenderer.srcObject != null
                      ? RTCVideoView(
                          _localRenderer,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          mirror: true,
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                ),
              ),
            ),

            // Top info bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      callState.otherUserName ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button
                    _buildControlButton(
                      icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                      label: callState.isMuted ? 'Bật mic' : 'Tắt mic',
                      onPressed: _toggleMicrophone,
                      color: callState.isMuted ? Colors.red : Colors.white,
                    ),

                    // Video toggle button
                    _buildControlButton(
                      icon: callState.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      label: callState.isVideoEnabled ? 'Tắt video' : 'Bật video',
                      onPressed: _toggleVideo,
                      color: callState.isVideoEnabled ? Colors.white : Colors.red,
                    ),

                    // Switch camera button
                    _buildControlButton(
                      icon: Icons.flip_camera_android,
                      label: 'Đổi camera',
                      onPressed: _switchCamera,
                      color: Colors.white,
                    ),

                    // End call button
                    _buildControlButton(
                      icon: Icons.call_end,
                      label: 'Kết thúc',
                      onPressed: _endCall,
                      color: Colors.red,
                      isEndCall: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isEndCall = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: isEndCall ? Colors.red : Colors.white.withOpacity(0.2),
          heroTag: label,
          child: Icon(
            icon,
            color: color,
            size: isEndCall ? 32 : 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _toggleMicrophone() {
    ref.read(callProvider.notifier).toggleMicrophone();
  }

  void _toggleVideo() {
    ref.read(callProvider.notifier).toggleVideo();
  }

  Future<void> _switchCamera() async {
    await ref.read(callProvider.notifier).switchCamera();
  }

  Future<void> _endCall() async {
    await ref.read(callProvider.notifier).endCall();
    if (mounted) {
      context.pop();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
