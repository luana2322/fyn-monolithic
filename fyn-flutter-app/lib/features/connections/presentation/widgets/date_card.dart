import 'package:flutter/material.dart';
import '../../data/models/date_model.dart';
import '../../data/models/meetup_model.dart';

/// Card widget for displaying a date plan
class DateCard extends StatelessWidget {
  final DateModel date;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onPropose;
  final VoidCallback? onCancel;
  final VoidCallback? onViewProposals;

  const DateCard({
    super.key,
    required this.date,
    this.isOwner = false,
    this.onTap,
    this.onPropose,
    this.onCancel,
    this.onViewProposals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeType = PlaceType.fromString(date.placeType);
    final connectionType = ConnectionType.fromString(date.connectionType);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with type badges
              Row(
                children: [
                  // Place type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPlaceColor(placeType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(placeType.emoji),
                        const SizedBox(width: 4),
                        Text(
                          placeType.label,
                          style: TextStyle(
                            color: _getPlaceColor(placeType),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Connection type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getConnectionColor(connectionType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      connectionType.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                date.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              if (date.description != null && date.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    date.description!,
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // Date and time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    date.formattedDate,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (date.placeName != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        date.placeName!,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Owner info or action buttons
              Row(
                children: [
                  // Owner avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: date.owner.primaryPhoto != null
                        ? NetworkImage(date.owner.primaryPhoto!)
                        : null,
                    child: date.owner.primaryPhoto == null
                        ? Text(
                            date.owner.displayName.isNotEmpty
                                ? date.owner.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOwner ? 'You' : date.owner.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  // Actions
                  if (isOwner && date.proposalCount > 0 && onViewProposals != null)
                    TextButton.icon(
                      onPressed: onViewProposals,
                      icon: const Icon(Icons.inbox, size: 18),
                      label: Text('${date.proposalCount} proposals'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  if (!isOwner && date.isOpen && onPropose != null)
                    ElevatedButton(
                      onPressed: onPropose,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Join'),
                    ),
                  if (isOwner && date.isOpen && onCancel != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onCancel,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (date.status) {
      case 'open':
        color = Colors.green;
        label = 'Open';
        break;
      case 'accepted':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'completed':
        color = Colors.grey;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.orange;
        label = date.status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getPlaceColor(PlaceType type) {
    switch (type) {
      case PlaceType.restaurant:
        return Colors.orange;
      case PlaceType.cafe:
        return Colors.brown;
      case PlaceType.bar:
        return Colors.purple;
      case PlaceType.park:
        return Colors.green;
      case PlaceType.cinema:
        return Colors.red;
      case PlaceType.billiard:
        return Colors.indigo;
      case PlaceType.badminton:
        return Colors.teal;
      case PlaceType.gym:
        return Colors.blue;
      case PlaceType.museum:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _getConnectionColor(ConnectionType type) {
    switch (type) {
      case ConnectionType.dating:
        return Colors.pink;
      case ConnectionType.friendship:
        return Colors.blue;
      case ConnectionType.hobbies:
        return Colors.orange;
      case ConnectionType.groups:
        return Colors.purple;
      case ConnectionType.community:
        return Colors.teal;
    }
  }
}

/// Card widget for displaying a group meetup
class MeetupCard extends StatelessWidget {
  final MeetupModel meetup;
  final bool isOrganizer;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const MeetupCard({
    super.key,
    required this.meetup,
    this.isOrganizer = false,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '👥 ${meetup.category}',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Spots left
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: meetup.isFull
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meetup.isFull ? 'Full' : '${meetup.spotsLeft} spots left',
                      style: TextStyle(
                        color: meetup.isFull ? Colors.red : Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                meetup.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Participants avatars
              if (meetup.participants.isNotEmpty)
                Row(
                  children: [
                    ...meetup.participants.take(5).map((p) {
                      return Align(
                        widthFactor: 0.7,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundImage: p.primaryPhoto != null
                              ? NetworkImage(p.primaryPhoto!)
                              : null,
                          child: p.primaryPhoto == null
                              ? Text(p.displayName[0], style: const TextStyle(fontSize: 10))
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      meetup.participantCount,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              // Join button
              if (!isOrganizer && meetup.isOpen && onJoin != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onJoin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Join Meetup'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
