import 'package:flutter/material.dart';

/// Compact horizontal match card with status and actions
class CompactMatchCard extends StatelessWidget {
  final dynamic match;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onNoShow;

  const CompactMatchCard({
    super.key,
    required this.match,
    this.status = 'ACCEPTED',
    this.onTap,
    this.onMessage,
    this.onComplete,
    this.onCancel,
    this.onNoShow,
  });

  @override
  Widget build(BuildContext context) {
    final user = match.user;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(user),
              const SizedBox(width: 12),
              // User info & status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.displayName ?? user.username ?? 'User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (match.commonInterests != null &&
                        match.commonInterests.isNotEmpty)
                      Text(
                        '${match.commonInterests.length} common interests',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      'Match score: ${match.matchScore?.toInt() ?? 0}%',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (status == 'ACCEPTED') ...[
                _buildActionButton(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  tooltip: 'Complete',
                  onTap: onComplete,
                ),
                _buildActionButton(
                  icon: Icons.cancel_outlined,
                  color: Colors.orange,
                  tooltip: 'Cancel',
                  onTap: onCancel,
                ),
                _buildActionButton(
                  icon: Icons.warning_amber,
                  color: Colors.red,
                  tooltip: 'No-show',
                  onTap: onNoShow,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic user) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.pink
    ];
    final color = colors[(user.username ?? 'A').hashCode % colors.length];
    final displayName = user.displayName ?? user.username ?? 'U';

    if (user.primaryPhoto != null) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(user.primaryPhoto),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: color,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String label;
    IconData icon;

    switch (status) {
      case 'COMPLETED':
        badgeColor = Colors.green;
        label = 'Done';
        icon = Icons.check_circle;
        break;
      case 'CANCELLED':
        badgeColor = Colors.grey;
        label = 'Cancelled';
        icon = Icons.cancel;
        break;
      case 'NO_SHOW':
        badgeColor = Colors.red;
        label = 'No-show';
        icon = Icons.warning;
        break;
      default:
        badgeColor = Colors.blue;
        label = 'Active';
        icon = Icons.favorite;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
