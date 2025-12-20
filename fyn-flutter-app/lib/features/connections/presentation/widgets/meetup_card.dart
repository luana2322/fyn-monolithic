import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../../../theme/dating_colors.dart';

/// Compact card for displaying meetup information
class MeetupCard extends StatelessWidget {
  final MeetupModel meetup;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onCancel;
  final bool isParticipant;
  final bool isOrganizer;

  const MeetupCard({
    super.key,
    required this.meetup,
    this.onTap,
    this.onJoin,
    this.onLeave,
    this.onCancel,
    this.isParticipant = false,
    this.isOrganizer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDark ? 0 : 2,
      color: isDark ? DatingColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark 
            ? BorderSide(color: DatingColors.darkBorder, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category badge + Status
              Row(
                children: [
                  _buildCategoryBadge(isDark),
                  const Spacer(),
                  _buildStatusBadge(isDark),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                meetup.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (meetup.description != null && meetup.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  meetup.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Info row: Date, Location, Participants
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(meetup.scheduledAt),
                    isDark: isDark,
                  ),
                  if (meetup.location != null)
                    _buildInfoChip(
                      icon: Icons.location_on,
                      label: meetup.location!,
                      isDark: isDark,
                    ),
                  _buildInfoChip(
                    icon: Icons.people,
                    label: meetup.participantCount,
                    color: meetup.isFull ? Colors.red : Colors.green,
                    isDark: isDark,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Organizer
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? DatingColors.darkSurfaceElevated : Colors.blue.shade100,
                    backgroundImage: meetup.organizer.avatarUrl != null
                        ? NetworkImage(meetup.organizer.avatarUrl!)
                        : null,
                    child: meetup.organizer.avatarUrl == null
                        ? Text(
                            meetup.organizer.displayName.isNotEmpty
                                ? meetup.organizer.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'By ${meetup.organizer.displayName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Action buttons
              if (meetup.isOpen && !isOrganizer) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: isParticipant
                      ? OutlinedButton.icon(
                          onPressed: onLeave,
                          icon: const Icon(Icons.exit_to_app, size: 18),
                          label: const Text('Leave'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: meetup.isFull ? null : onJoin,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(meetup.isFull ? 'Full' : 'Join Meetup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                ),
              ],
              
              if (isOrganizer) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel Meetup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(bool isDark) {
    final categoryEmoji = _getCategoryEmoji(meetup.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? DatingColors.darkSurfaceElevated : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$categoryEmoji ${_formatCategoryName(meetup.category)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? DatingColors.darkPrimaryText : Colors.purple.shade700,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    Color color;
    String label;
    
    switch (meetup.status.toLowerCase()) {
      case 'open':
        color = Colors.green;
        label = 'Open';
        break;
      case 'full':
        color = Colors.orange;
        label = 'Full';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = meetup.status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? (isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color ?? (isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(date);
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'outdoor':
        return '🏃';
      case 'food':
        return '🍽️';
      case 'sports':
        return '⚽';
      case 'culture':
        return '🎭';
      case 'social':
        return '🎉';
      case 'gaming':
        return '🎮';
      case 'music':
        return '🎵';
      case 'art':
        return '🎨';
      case 'travel':
        return '✈️';
      default:
        return '📍';
    }
  }

  String _formatCategoryName(String category) {
    return category.substring(0, 1).toUpperCase() + category.substring(1).toLowerCase();
  }
}
