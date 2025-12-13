import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/call_provider.dart';

/// Incoming call screen - shown when receiving a call
class IncomingCallScreen extends ConsumerWidget {
  final String callId;
  final String callerId;
  final String? callerName;
  final String? callerAvatar;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerId,
    this.callerName,
    this.callerAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 60),

              // Avatar and name section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: callerAvatar != null
                            ? NetworkImage(callerAvatar!)
                            : null,
                        child: callerAvatar == null
                            ? Icon(Icons.person, size: 70, color: Colors.grey[600])
                            : null,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Name
                    Text(
                      callerName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Incoming call text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: Colors.grey[400], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Cuộc gọi video đến...',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reject button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          onPressed: () => _rejectCall(context, ref),
                          backgroundColor: Colors.red,
                          heroTag: 'reject_call',
                          child: const Icon(Icons.call_end, size: 32),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Từ chối',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    // Accept button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          onPressed: () => _acceptCall(context, ref),
                          backgroundColor: Colors.green,
                          heroTag: 'accept_call',
                          child: const Icon(Icons.videocam, size: 32),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chấp nhận',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptCall(BuildContext context, WidgetRef ref) async {
    // Update call state with caller info
    final callNotifier = ref.read(callProvider.notifier);
    
    // Answer the call
    await callNotifier.answerCall(callId);

    // Navigate to active call screen
    if (context.mounted) {
      context.go('/video-call/active', extra: {'callId': callId});
    }
  }

  Future<void> _rejectCall(BuildContext context, WidgetRef ref) async {
    await ref.read(callProvider.notifier).rejectCall(callId);

    if (context.mounted) {
      context.pop();
    }
  }
}
