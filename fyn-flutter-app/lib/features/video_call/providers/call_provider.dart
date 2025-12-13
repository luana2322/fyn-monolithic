import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_state.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';

/// Provider for SignalingService
final signalingServiceProvider = Provider<SignalingService>((ref) {
  return SignalingService();
});

/// Provider for WebRTCService
final webrtcServiceProvider = Provider<WebRTCService>((ref) {
  return WebRTCService();
});

/// Call state notifier
class CallNotifier extends StateNotifier<CallState> {
  final SignalingService _signalingService;
  final WebRTCService _webrtcService;
  
  StreamSubscription? _callSubscription;
  StreamSubscription? _iceCandidatesSubscription;
  StreamSubscription? _iceGeneratedSubscription;
  
  String? _currentUserId;
  bool _isCaller = false;

  CallNotifier({
    required SignalingService signalingService,
    required WebRTCService webrtcService,
  })  : _signalingService = signalingService,
        _webrtcService = webrtcService,
        super(const CallState());

  /// Initialize with current user ID
  void initialize(String currentUserId) {
    _currentUserId = currentUserId;
  }

  /// Initiate outgoing call
  Future<String?> initiateCall({
    required String calleeId,
    String? calleeName,
    String? calleeAvatar,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not initialized');
      }

      // Update state to calling
      state = state.copyWith(
        status: CallStatus.calling,
        otherUserId: calleeId,
        otherUserName: calleeName,
        otherUserAvatar: calleeAvatar,
      );

      // Reset WebRTC service if it was previously disposed
      _webrtcService.reset();

      // Initialize local stream
      await _webrtcService.initializeLocalStream();
      
      // Create peer connection
      await _webrtcService.initializePeerConnection();

      // Create call in Firestore
      final callId = await _signalingService.createCall(
        callerId: _currentUserId!,
        calleeId: calleeId,
      );

      _isCaller = true;
      
      // Update state with call ID
      state = state.copyWith(callId: callId);

      // Create and send offer
      final offer = await _webrtcService.createOffer();
      await _signalingService.sendOffer(
        callId: callId,
        offer: offer,
      );

      // Listen for answer and ICE candidates
      _listenToCall(callId);
      _listenToIceCandidates(callId);
      _listenToGeneratedIceCandidates(callId);

      return callId;
    } catch (e) {
      state = state.copyWith(
        status: CallStatus.failed,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Answer incoming call
  Future<void> answerCall(String callId) async {
    try {
      state = state.copyWith(status: CallStatus.connecting);

      // Initialize local stream
      await _webrtcService.initializeLocalStream();
      
      // Create peer connection
      await _webrtcService.initializePeerConnection();

      // Get call document to retrieve offer
      final callDoc = await _signalingService.getCall(callId);
      final callData = callDoc.data() as Map<String, dynamic>;
      final offerData = callData['offer'] as Map<String, dynamic>;

      // Set remote description (offer)
      final offer = RTCSessionDescription(
        offerData['sdp'],
        offerData['type'],
      );
      await _webrtcService.setRemoteDescription(offer);

      // Create and send answer
      final answer = await _webrtcService.createAnswer();
      await _signalingService.sendAnswer(
        callId: callId,
        answer: answer,
      );

      // Update status
      await _signalingService.updateCallStatus(
        callId: callId,
        status: 'active',
      );

      _isCaller = false;
      
      state = state.copyWith(
        status: CallStatus.active,
        callId: callId,
      );

      // Listen for ICE candidates
      _listenToCall(callId);
      _listenToIceCandidates(callId);
      _listenToGeneratedIceCandidates(callId);
    } catch (e) {
      state = state.copyWith(
        status: CallStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Reject incoming call
  Future<void> rejectCall(String callId) async {
    await _signalingService.updateCallStatus(
      callId: callId,
      status: 'rejected',
    );
    
    state = state.copyWith(status: CallStatus.rejected);
    await _cleanup();
  }

  /// End active call
  Future<void> endCall() async {
    if (state.callId != null) {
      await _signalingService.endCall(state.callId!);
    }
    
    state = state.copyWith(status: CallStatus.ended);
    await _cleanup();
  }

  /// Toggle microphone
  void toggleMicrophone() {
    final newMuteState = !state.isMuted;
    _webrtcService.toggleMicrophone(!newMuteState);
    state = state.copyWith(isMuted: newMuteState);
  }

  /// Toggle video
  void toggleVideo() {
    final newVideoState = !state.isVideoEnabled;
    _webrtcService.toggleVideo(newVideoState);
    state = state.copyWith(isVideoEnabled: newVideoState);
  }

  /// Switch camera
  Future<void> switchCamera() async {
    await _webrtcService.switchCamera();
  }

  /// Get local stream
  MediaStream? get localStream => _webrtcService.currentLocalStream;

  /// Get remote stream
  MediaStream? get remoteStream => _webrtcService.currentRemoteStream;

  /// Listen to call document changes
  void _listenToCall(String callId) {
    _callSubscription = _signalingService.listenToCall(callId).listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status == 'ended' || status == 'rejected') {
        state = state.copyWith(
          status: status == 'ended' ? CallStatus.ended : CallStatus.rejected,
        );
        _cleanup();
      } else if (status == 'active' && _isCaller) {
        // Caller receives answer
        final answerData = data['answer'] as Map<String, dynamic>?;
        if (answerData != null) {
          final answer = RTCSessionDescription(
            answerData['sdp'],
            answerData['type'],
          );
          _webrtcService.setRemoteDescription(answer);
          
          state = state.copyWith(status: CallStatus.active);
        }
      }
    });
  }

  /// Listen to ICE candidates
  void _listenToIceCandidates(String callId) {
    _iceCandidatesSubscription = _signalingService
        .listenToIceCandidates(callId: callId, isCaller: _isCaller)
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          _webrtcService.addIceCandidate(candidate);
        }
      }
    });
  }

  /// Listen to locally generated ICE candidates and send to Firestore
  void _listenToGeneratedIceCandidates(String callId) {
    _iceGeneratedSubscription = _webrtcService.onIceCandidate.listen((candidate) {
      _signalingService.addIceCandidate(
        callId: callId,
        candidate: candidate,
        isCaller: _isCaller,
      );
    });
  }

  /// Cleanup resources
  Future<void> _cleanup() async {
    await _callSubscription?.cancel();
    await _iceCandidatesSubscription?.cancel();
    await _iceGeneratedSubscription?.cancel();
    
    _callSubscription = null;
    _iceCandidatesSubscription = null;
    _iceGeneratedSubscription = null;

    await _webrtcService.dispose();
    
    state = const CallState();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

/// Call provider
final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  return CallNotifier(
    signalingService: ref.read(signalingServiceProvider),
    webrtcService: ref.read(webrtcServiceProvider),
  );
});
