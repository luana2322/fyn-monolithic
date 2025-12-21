import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import 'match_requests_screen.dart';

class MeetupDetailsScreen extends ConsumerStatefulWidget {
  final String meetupId;

  const MeetupDetailsScreen({
    super.key,
    required this.meetupId,
  });

  @override
  ConsumerState<MeetupDetailsScreen> createState() => _MeetupDetailsScreenState();
}

class _MeetupDetailsScreenState extends ConsumerState<MeetupDetailsScreen> {
  final _messageController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _applyToMeetup(MeetupModel meetup) async {
    if (meetup.userHasApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already applied to this meetup')),
      );
      return;
    }

    // Show message dialog
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to Meetup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send a message to the organizer (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Why do you want to join?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _messageController.text.trim()),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (message == null) return;

    setState(() => _isApplying = true);

    try {
      await ref.read(applyToMeetupProvider((
        meetupId: widget.meetupId,
        message: message.isNotEmpty ? message : null,
      )).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application sent successfully!')),
        );
        // Refresh the page
        ref.invalidate(discoveredMeetupsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd fetch the specific meetup by ID
    // For now, we'll find it from the discovered meetups
    final meetupsAsync = ref.watch(discoveredMeetupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup Details'),
      ),
      body: meetupsAsync.when(
        data: (meetups) {
          final meetup = meetups.firstWhere(
            (m) => m.id == widget.meetupId,
            orElse: () => meetups.first, // Fallback
          );
          return _buildDetails(meetup);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDetails(MeetupModel meetup) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a');
    final theme = Theme.of(context);
    
    // TODO: Get current user ID to check if organizer
    final isOrganizer = false; // meetup.organizer.id == currentUser.id

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Type
          Row(
            children: [
              Expanded(
                child: Text(
                  meetup.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTypeBadge(meetup.meetType),
            ],
          ),
          const SizedBox(height: 16),

          // Organizer
          ListTile(
            leading: CircleAvatar(
              backgroundImage: meetup.organizer.avatarUrl != null
                  ? NetworkImage(meetup.organizer.avatarUrl!)
                  : null,
              child: meetup.organizer.avatarUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(meetup.organizer.fullName ?? meetup.organizer.username),
            subtitle: const Text('Organizer'),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),

          // Date & Time
          _buildInfoRow(
            Icons.calendar_today,
            'When',
            dateFormat.format(meetup.scheduledAt),
          ),
          const SizedBox(height: 12),

          // Location
          _buildInfoRow(
            Icons.location_on,
            'Where',
            '${meetup.location}${meetup.distanceKm != null ? " (${meetup.distanceKm!.toStringAsFixed(1)} km away)" : ""}',
          ),
          const SizedBox(height: 12),

          // Participants
          _buildInfoRow(
            Icons.people,
            'Participants',
            '${meetup.acceptedCount}/${meetup.maxParticipants}',
          ),
          const SizedBox(height: 12),

          // Category
          if (meetup.category != null)
            _buildInfoRow(
              Icons.category,
              'Category',
              meetup.category!,
            ),
          const Divider(height: 32),

          // Description
          if (meetup.description != null && meetup.description!.isNotEmpty) ...[
            Text('About', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(meetup.description!),
            const SizedBox(height: 24),
          ],

          // Status badges
          if (meetup.userHasApplied) ...[
            _buildApplicationStatus(meetup.userMatchStatus!),
            const SizedBox(height: 16),
          ],

          // Action buttons
          if (isOrganizer)
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchRequestsScreen(meetupId: meetup.id),
                  ),
                );
              },
              icon: const Icon(Icons.inbox),
              label: Text('View Applications (${meetup.pendingMatchCount})'),
            )
          else if (!meetup.userHasApplied)
            FilledButton.icon(
              onPressed: _isApplying ? null : () => _applyToMeetup(meetup),
              icon: const Icon(Icons.send),
              label: _isApplying
                  ? const Text('Applying...')
                  : const Text('Apply to Join'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(MeetType meetType) {
    final color = meetType == MeetType.oneToOne ? Colors.purple : Colors.blue;
    final label = meetType == MeetType.oneToOne ? '1-on-1' : 'Group';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildApplicationStatus(MatchStatus status) {
    Color color;
    IconData icon;
    String message;

    switch (status) {
      case MatchStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        message = 'Your application is pending review';
        break;
      case MatchStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle;
        message = 'You\'ve been accepted! Check your messages';
        break;
      case MatchStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        message = 'Your application was not accepted';
        break;
      case MatchStatus.cancelled:
        color = Colors.grey;
        icon = Icons.block;
        message = 'Application cancelled';
        break;
      case MatchStatus.confirmed:
        color = Colors.blue;
        icon = Icons.verified;
        message = 'Meetup confirmed!';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
