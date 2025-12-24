import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'match_requests_screen.dart';
import 'owner_meetup_detail_screen.dart';
import 'edit_meetup_screen.dart';

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

  @override
  void initState() {
    super.initState();
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
        ref.invalidate(meetupDetailProvider(widget.meetupId));
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data != null && data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _triggerInitialLoad() {
    // This is a bit of a hack since we don't have the user's current location here easily
    // But we can at least call the provider's discover method with defaults
    ref.read(discoveredMeetupsProvider.notifier).discoverMeetups(
      latitude: 16.0544, // Default location fallback
      longitude: 108.2022,
    );
  }

  @override
  Widget build(BuildContext context) {
    final meetupAsync = ref.watch(meetupDetailProvider(widget.meetupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(meetupDetailProvider(widget.meetupId)),
          ),
        ],
      ),
      body: meetupAsync.when(
        data: (meetup) => _buildDetails(meetup),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(meetupDetailProvider(widget.meetupId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(MeetupModel meetup) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a');
    final theme = Theme.of(context);
    final currentUser = ref.watch(authNotifierProvider).user;
    final isOrganizer = meetup.organizer.id == currentUser?.id;
    final isMatched = meetup.status == MeetupStatus.matched;
    final isPast = meetup.scheduledAt.isBefore(DateTime.now());
    final canConfirm = isMatched && isPast;

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
              backgroundImage: meetup.organizer.fullAvatarUrl != null
                  ? NetworkImage(meetup.organizer.fullAvatarUrl!)
                  : null,
              child: meetup.organizer.fullAvatarUrl == null
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
            trailing: IconButton(
              icon: const Icon(Icons.directions),
              onPressed: () => _openMap(meetup),
              tooltip: 'Get Directions',
            ),
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
          if (isOrganizer) ...[
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
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _editMeetup(meetup),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Meetup'),
            ),
          ] else if (!meetup.userHasApplied)
            FilledButton.icon(
              onPressed: _isApplying ? null : () => _applyToMeetup(meetup),
              icon: const Icon(Icons.send),
              label: _isApplying
                  ? const Text('Applying...')
                  : const Text('Apply to Join'),
            ),

          if (canConfirm) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _showConfirmationDialog(meetup),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Meetup Outcome'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _editMeetup(MeetupModel meetup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMeetupScreen(meetup: meetup),
      ),
    ).then((updated) {
      if (updated == true) {
        ref.invalidate(meetupDetailProvider(widget.meetupId));
      }
    });
  }

  Future<void> _showConfirmationDialog(MeetupModel meetup) async {
    double rating = 5.0;
    String? feedback;
    String result = 'SUCCESS';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirm Meetup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your meetup?'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: result,
                items: const [
                  DropdownMenuItem(value: 'SUCCESS', child: Text('Successful')),
                  DropdownMenuItem(value: 'NO_SHOW', child: Text('No Show')),
                ],
                onChanged: (val) => setState(() => result = val!),
                decoration: const InputDecoration(labelText: 'Outcome'),
              ),
              const SizedBox(height: 16),
              const Text('Rating:'),
              Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: rating.toString(),
                onChanged: (val) => setState(() => rating = val),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (val) => feedback = val,
                decoration: const InputDecoration(
                  labelText: 'Feedback (Optional)',
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(confirmMeetupProvider((
                    meetupId: meetup.id,
                    result: result,
                    feedback: feedback,
                    rating: rating,
                  )).future);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback submitted!')),
                    );
                    ref.invalidate(meetupDetailProvider(widget.meetupId));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(MeetupModel meetup) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${meetup.latitude},${meetup.longitude}';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening map: $e')),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? trailing}) {
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
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
