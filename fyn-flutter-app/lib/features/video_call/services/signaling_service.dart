import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Signaling service for WebRTC call setup via Firebase Firestore
/// Handles SDP offer/answer exchange and ICE candidate exchange
class SignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new call document in Firestore
  /// Returns the call ID
  Future<String> createCall({
    required String callerId,
    required String calleeId,
  }) async {
    final callDoc = _firestore.collection('calls').doc();
    
    await callDoc.set({
      'callerId': callerId,
      'calleeId': calleeId,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return callDoc.id;
  }

  /// Send SDP offer to Firestore
  Future<void> sendOffer({
    required String callId,
    required RTCSessionDescription offer,
  }) async {
    await _firestore.collection('calls').doc(callId).update({
      'offer': {
        'sdp': offer.sdp,
        'type': offer.type,
      },
    });
  }

  /// Send SDP answer to Firestore
  Future<void> sendAnswer({
    required String callId,
    required RTCSessionDescription answer,
  }) async {
    await _firestore.collection('calls').doc(callId).update({
      'answer': {
        'sdp': answer.sdp,
        'type': answer.type,
      },
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add ICE candidate to Firestore
  Future<void> addIceCandidate({
    required String callId,
    required RTCIceCandidate candidate,
    required bool isCaller,
  }) async {
    final candidatesCollection = isCaller
        ? 'callerCandidates'
        : 'calleeCandidates';

    await _firestore
        .collection('calls')
        .doc(callId)
        .collection(candidatesCollection)
        .add({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  /// Listen to call document changes
  Stream<DocumentSnapshot> listenToCall(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  /// Listen to ICE candidates
  Stream<QuerySnapshot> listenToIceCandidates({
    required String callId,
    required bool isCaller,
  }) {
    final candidatesCollection = isCaller
        ? 'calleeCandidates'  // Caller listens to callee's candidates
        : 'callerCandidates';  // Callee listens to caller's candidates

    return _firestore
        .collection('calls')
        .doc(callId)
        .collection(candidatesCollection)
        .snapshots();
  }

  /// Update call status
  Future<void> updateCallStatus({
    required String callId,
    required String status,
  }) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': status,
      'endedAt': status == 'ended' ? FieldValue.serverTimestamp() : null,
    });
  }

  /// End call
  Future<void> endCall(String callId) async {
    await updateCallStatus(callId: callId, status: 'ended');
  }

  /// Get call document
  Future<DocumentSnapshot> getCall(String callId) async {
    return await _firestore.collection('calls').doc(callId).get();
  }
}
