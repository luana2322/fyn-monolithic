import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meetup_model.dart';
import '../../data/repositories/meetup_repository.dart';
import '../providers/meetup_provider.dart';

/// Shows confirmation dialog 12-24h after meetup for both parties to confirm
class MeetupConfirmationDialog extends ConsumerStatefulWidget {
  final MeetupModel meetup;

  const MeetupConfirmationDialog({
    super.key,
    required this.meetup,
  });

  @override
  ConsumerState<MeetupConfirmationDialog> createState() =>
      _MeetupConfirmationDialogState();

  /// Show the dialog
  static Future<void> show(BuildContext context, MeetupModel meetup) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MeetupConfirmationDialog(meetup: meetup),
    );
  }
}

class _MeetupConfirmationDialogState
    extends ConsumerState<MeetupConfirmationDialog> {
  bool _isSubmitting = false;

  Future<void> _submitConfirmation(String result) async {
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(meetupRepositoryProvider);
      await repository.confirmMeetup(
        widget.meetup.id,
        result, // "SUCCESS" or "NO_SHOW"
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result == 'SUCCESS'
                ? 'Thank you for confirming! ✅'
                : 'Marked as no-show. We\'ll review this.'),
            backgroundColor: result == 'SUCCESS' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.event_available, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Confirm Meetup')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Did "${widget.meetup.title}" happen as planned?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your confirmation helps build trust in the community and affects reputation scores.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirming gives +1 reputation to all participants.\nReporting no-show gives -2 to the absent party.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : () => _submitConfirmation('NO_SHOW'),
          icon: const Icon(Icons.report_problem),
          label: const Text('No-Show'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : () => _submitConfirmation('SUCCESS'),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle),
          label: const Text('Yes, Confirm'),
        ),
      ],
    );
  }
}

/// Widget that checks if meetup needs confirmation and shows dialog
class MeetupConfirmationChecker extends ConsumerWidget {
  const MeetupConfirmationChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement periodic check for meetups needing confirmation
    // This would typically be called from a background service or
    // when the app comes to foreground
    
    // For now, this is a placeholder that would be integrated with
    // push notifications or a polling mechanism
    return const SizedBox.shrink();
  }

  /// Check if any meetups need confirmation and show dialog
  static Future<void> checkAndShowConfirmations(
    BuildContext context,
    List<MeetupModel> userMeetups,
  ) async {
    final now = DateTime.now();

    for (final meetup in userMeetups) {
      // Check if meetup ended 12+ hours ago
      final hoursSinceMeet = now.difference(meetup.scheduledAt).inHours;
      
      if (hoursSinceMeet >= 12 &&
          hoursSinceMeet <= 48 &&
          meetup.status == MeetupStatus.matched &&
          meetup.confirmationStatus == ConfirmationStatus.none) {
        // Show confirmation dialog
        await MeetupConfirmationDialog.show(context, meetup);
      }
    }
  }
}
