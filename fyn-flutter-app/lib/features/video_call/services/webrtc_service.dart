import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// WebRTC service for peer-to-peer video/audio connection
/// Handles local/remote streams, peer connection, and ICE candidates
class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  StreamController<MediaStream> _localStreamController = StreamController<MediaStream>.broadcast();
  StreamController<MediaStream> _remoteStreamController = StreamController<MediaStream>.broadcast();
  StreamController<RTCIceCandidate> _iceCandidateController = StreamController<RTCIceCandidate>.broadcast();

  bool _isDisposed = false;

  Stream<MediaStream> get localStream => _localStreamController.stream;
  Stream<MediaStream> get remoteStream => _remoteStreamController.stream;
  Stream<RTCIceCandidate> get onIceCandidate => _iceCandidateController.stream;

  MediaStream? get currentLocalStream => _localStream;
  MediaStream? get currentRemoteStream => _remoteStream;

  /// STUN/TURN server configuration
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  /// Media constraints for video/audio
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'optional': [],
    }
  };

  /// Initialize local media stream (camera + microphone)
  Future<void> initializeLocalStream() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      _localStreamController.add(_localStream!);
    } catch (e) {
      throw Exception('Failed to get user media: $e');
    }
  }

  /// Create peer connection
  Future<void> initializePeerConnection() async {
    if (_peerConnection != null) {
      return;
    }

    _peerConnection = await createPeerConnection(_configuration);

    // Add local stream tracks to peer connection
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }

    // Listen for ICE candidates
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _iceCandidateController.add(candidate);
    };

    // Listen for remote stream
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteStreamController.add(_remoteStream!);
      }
    };

    // Listen for connection state changes
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state: $state');
    };
  }

  /// Create SDP offer
  Future<RTCSessionDescription> createOffer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  /// Create SDP answer
  Future<RTCSessionDescription> createAnswer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  /// Set remote SDP description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.setRemoteDescription(description);
  }

  /// Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.addCandidate(candidate);
  }

  /// Toggle microphone mute
  void toggleMicrophone(bool enabled) {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().firstOrNull;
      if (audioTrack != null) {
        audioTrack.enabled = enabled;
      }
    }
  }

  /// Toggle video
  void toggleVideo(bool enabled) {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        videoTrack.enabled = enabled;
      }
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);
      }
    }
  }

  /// Reset service for reuse after disposal
  void reset() {
    if (_isDisposed) {
      _localStreamController = StreamController<MediaStream>.broadcast();
      _remoteStreamController = StreamController<MediaStream>.broadcast();
      _iceCandidateController = StreamController<RTCIceCandidate>.broadcast();
      _isDisposed = false;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    await _peerConnection?.dispose();

    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;

    await _localStreamController.close();
    await _remoteStreamController.close();
    await _iceCandidateController.close();
  }
}

