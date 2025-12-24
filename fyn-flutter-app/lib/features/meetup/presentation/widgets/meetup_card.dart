import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';

class MeetupCard extends StatelessWidget {
  final MeetupModel meetup;
  final VoidCallback? onTap;
  final bool isOwner;
  final VoidCallback? onViewApplicants;

  const MeetupCard({
    super.key,
    required this.meetup,
    this.onTap,
    this.isOwner = false,
    this.onViewApplicants,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and type badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meetup.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (meetup.isPast || meetup.isExpired) 
                    _buildPastBadge(context)
                  else
                    _buildTypeBadge(context),
                ],
              ),
              const SizedBox(height: 8),

              // Organizer
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: meetup.organizer.fullAvatarUrl != null
                        ? NetworkImage(meetup.organizer.fullAvatarUrl!)
                        : null,
                    child: meetup.organizer.fullAvatarUrl == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    meetup.organizer.fullName ?? meetup.organizer.username,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date and location
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(meetup.scheduledAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      meetup.location ?? 'Unknown location',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (meetup.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${meetup.distanceKm!.toStringAsFixed(1)} km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Bottom row with participants and status
              Row(
                children: [
                  _buildParticipantsChip(context),
                  const SizedBox(width: 8),
                  if (meetup.category != null)
                    Chip(
                      label: Text(meetup.category!),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  const Spacer(),
                  if (meetup.userHasApplied)
                    _buildApplicationStatusBadge(context),
                ],
              ),
              // Owner actions row
              if (isOwner && onViewApplicants != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewApplicants,
                        icon: Badge(
                          isLabelVisible: meetup.pendingMatchCount > 0,
                          label: Text('${meetup.pendingMatchCount}'),
                          child: const Icon(Icons.people_alt),
                        ),
                        label: Text('Xem đăng ký (${meetup.pendingMatchCount})'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final color = meetup.meetType == MeetType.oneToOne
        ? Colors.purple
        : Colors.blue;
    final label = meetup.meetType == MeetType.oneToOne ? '1-on-1' : 'Group';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParticipantsChip(BuildContext context) {
    final filled = meetup.acceptedCount;
    final total = meetup.maxParticipants;
    final isFull = filled >= total;

    return Chip(
      avatar: Icon(
        Icons.people,
        size: 16,
        color: isFull ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      label: Text('$filled/$total'),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: isFull ? Colors.red.withOpacity(0.1) : null,
    );
  }

  Widget _buildPastBadge(BuildContext context) {
    String label = 'Past';
    Color color = Colors.grey;

    if (meetup.status == MeetupStatus.completed) {
      label = 'Finished';
      color = Colors.green;
    } else if (meetup.isExpired || meetup.status == MeetupStatus.expired) {
      label = 'Expired';
      color = Colors.red;
    } else if (meetup.status == MeetupStatus.cancelled) {
      label = 'Cancelled';
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildApplicationStatusBadge(BuildContext context) {
    final status = meetup.userMatchStatus;
    if (status == null) return const SizedBox.shrink();

    Color color;
    IconData icon;
    String label;

    switch (status) {
      case MatchStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        label = 'Pending';
        break;
      case MatchStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Accepted';
        break;
      case MatchStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case MatchStatus.cancelled:
        color = Colors.grey;
        icon = Icons.block;
        label = 'Cancelled';
        break;
      case MatchStatus.confirmed:
        color = Colors.blue;
        icon = Icons.verified;
        label = 'Confirmed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
