import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/meetups_provider.dart';
import '../widgets/meetup_card.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../../../theme/dating_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

/// Screen for browsing and managing meetups
class MeetupsScreen extends ConsumerStatefulWidget {
  const MeetupsScreen({super.key});

  @override
  ConsumerState<MeetupsScreen> createState() => _MeetupsScreenState();
}

class _MeetupsScreenState extends ConsumerState<MeetupsScreen> {
  String? _selectedCategory;

  final List<Map<String, String>> _categories = [
    {'value': '', 'label': 'All', 'emoji': '📍'},
    {'value': 'OUTDOOR', 'label': 'Outdoor', 'emoji': '🏃'},
    {'value': 'FOOD', 'label': 'Food', 'emoji': '🍽️'},
    {'value': 'SPORTS', 'label': 'Sports', 'emoji': '⚽'},
    {'value': 'CULTURE', 'label': 'Culture', 'emoji': '🎭'},
    {'value': 'SOCIAL', 'label': 'Social', 'emoji': '🎉'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetupsProvider.notifier).loadMeetups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetupsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: isDark ? DatingColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? DatingColors.darkNavBackground : null,
        title: Text(
          'Meetups',
          style: TextStyle(color: isDark ? DatingColors.darkPrimaryText : null),
        ),
        iconTheme: IconThemeData(color: isDark ? DatingColors.darkPrimaryText : null),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildCategoryFilters(isDark),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 700,
        backgroundColor: isDark ? DatingColors.darkBackground : Colors.grey.shade50,
        child: _buildBody(state, isDark, currentUserId),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    return Container(
      color: isDark ? DatingColors.darkNavBackground : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category['value'] ||
                (_selectedCategory == null && category['value'] == '');
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${category['emoji']} ${category['label']}'),
                selected: isSelected,
                onSelected: (_) => _setCategory(category['value']!),
                selectedColor: Colors.purple.withOpacity(0.2),
                checkmarkColor: Colors.purple,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _setCategory(String category) {
    setState(() {
      _selectedCategory = category.isEmpty ? null : category;
    });
    ref.read(meetupsProvider.notifier).loadMeetups(category: _selectedCategory);
  }

  Widget _buildBody(dynamic state, bool isDark, String? currentUserId) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load meetups',
              style: TextStyle(
                color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: TextStyle(
                color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(meetupsProvider.notifier).loadMeetups(
                    category: _selectedCategory,
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.meetups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups,
              size: 64,
              color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No meetups found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategory != null
                  ? 'Try a different category'
                  : 'Be the first to create one!',
              style: TextStyle(
                color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(meetupsProvider.notifier).loadMeetups(
            category: _selectedCategory,
          ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.meetups.length,
        itemBuilder: (context, index) {
          final meetup = state.meetups[index];
          final isOrganizer = currentUserId == meetup.organizer.id;
          final isParticipant = meetup.participants.any((p) => p.id == currentUserId);

          return MeetupCard(
            meetup: meetup,
            isOrganizer: isOrganizer,
            isParticipant: isParticipant,
            onTap: () => _showMeetupDetails(meetup),
            onJoin: () => _joinMeetup(meetup.id),
            onLeave: () => _leaveMeetup(meetup.id),
            onCancel: () => _cancelMeetup(meetup.id),
          );
        },
      ),
    );
  }

  void _showMeetupDetails(dynamic meetup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MeetupDetailsSheet(meetup: meetup),
    );
  }

  Future<void> _joinMeetup(String id) async {
    try {
      await ref.read(meetupsProvider.notifier).joinMeetup(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined meetup!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    }
  }

  Future<void> _leaveMeetup(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meetup?'),
        content: const Text('Are you sure you want to leave this meetup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(meetupsProvider.notifier).leaveMeetup(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Left meetup')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to leave: $e')),
          );
        }
      }
    }
  }

  Future<void> _cancelMeetup(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Meetup?'),
        content: const Text(
          'This will cancel the meetup for all participants. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Meetup'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(meetupsProvider.notifier).cancelMeetup(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meetup cancelled')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel: $e')),
          );
        }
      }
    }
  }
}

/// Bottom sheet showing meetup details
class _MeetupDetailsSheet extends StatelessWidget {
  final dynamic meetup;

  const _MeetupDetailsSheet({required this.meetup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? DatingColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meetup.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (meetup.description != null) ...[
                    Text(
                      meetup.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'When',
                    value: _formatDateTime(meetup.scheduledAt),
                    isDark: isDark,
                  ),
                  if (meetup.location != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Where',
                      value: meetup.location!,
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.people,
                    label: 'Participants',
                    value: meetup.participantCount,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Participants (${meetup.participants.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...meetup.participants.map((participant) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: participant.avatarUrl != null
                              ? NetworkImage(participant.avatarUrl!)
                              : null,
                          child: participant.avatarUrl == null
                              ? Text(participant.displayName[0].toUpperCase())
                              : null,
                        ),
                        title: Text(
                          participant.displayName,
                          style: TextStyle(
                            color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                          ),
                        ),
                        subtitle: participant.id == meetup.organizer.id
                            ? const Text('Organizer')
                            : null,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isDark ? DatingColors.darkSecondaryText : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      dateStr = 'Today';
    } else if (dateOnly == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
