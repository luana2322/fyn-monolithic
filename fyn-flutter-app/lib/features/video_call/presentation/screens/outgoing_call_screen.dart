import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/call_provider.dart';
import '../../models/call_state.dart';

/// Outgoing call screen - shown when initiating a call
class OutgoingCallScreen extends ConsumerStatefulWidget {
  final String callId;

  const OutgoingCallScreen({
    super.key,
    required this.callId,
  });

  @override
  ConsumerState<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends ConsumerState<OutgoingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);

    // Listen for call status changes
    ref.listen<CallState>(callProvider, (previous, next) {
      if (next.status == CallStatus.active) {
        // Navigate to active call screen
        context.go('/video-call/active', extra: {'callId': widget.callId});
      } else if (next.status == CallStatus.rejected) {
        // Call was rejected, go back
        _showRejectedDialog();
      } else if (next.status == CallStatus.ended) {
        // Call ended before answering
        context.pop();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _cancelCall();
        }
      },
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
                    // Avatar with pulse animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(8 * (1 + _animationController.value * 0.3)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: child,
                        );
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: callState.otherUserAvatar != null
                            ? NetworkImage(callState.otherUserAvatar!)
                            : null,
                        child: callState.otherUserAvatar == null
                            ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                            : null,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Name
                    Text(
                      callState.otherUserName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Calling status
                    Text(
                      'Đang gọi...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Loading indicator
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[400]!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cancel button
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _cancelCall,
                      backgroundColor: Colors.red,
                      heroTag: 'cancel_call',
                      child: const Icon(Icons.call_end, size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hủy',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
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

  Future<void> _cancelCall() async {
    await ref.read(callProvider.notifier).endCall();
    if (mounted) {
      context.pop();
    }
  }

  void _showRejectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cuộc gọi bị từ chối'),
        content: Text('${ref.read(callProvider).otherUserName} đã từ chối cuộc gọi.'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Close outgoing screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
