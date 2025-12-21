import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';

class MatchRequestsScreen extends ConsumerStatefulWidget {
  final String meetupId;

  const MatchRequestsScreen({
    super.key,
    required this.meetupId,
  });

  @override
  ConsumerState<MatchRequestsScreen> createState() => _MatchRequestsScreenState();
}

class _MatchRequestsScreenState extends ConsumerState<MatchRequestsScreen> {
  MatchStatus? _filterStatus = MatchStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  void _loadRequests() {
    ref.read(matchRequestsProvider.notifier).loadMatchRequests(
      widget.meetupId,
      status: _filterStatus,
    );
  }

  Future<void> _acceptMatch(String matchId) async {
    try {
      await ref.read(matchRequestsProvider.notifier).acceptMatch(matchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match accepted! Chat created.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectMatch(String matchId) async {
    try {
      await ref.read(matchRequestsProvider.notifier).rejectMatch(matchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Requests'),
        actions: [
          PopupMenuButton<MatchStatus?>(
            initialValue: _filterStatus,
            onSelected: (status) {
              setState(() => _filterStatus = status);
              _loadRequests();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: MatchStatus.pending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: MatchStatus.accepted,
                child: Text('Accepted'),
              ),
              const PopupMenuItem(
                value: MatchStatus.rejected,
                child: Text('Rejected'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_getFilterLabel()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRequests(),
        child: matchesAsync.when(
          data: (matches) {
            if (matches.isEmpty) {
              return _buildEmptyState();
            }
            return _buildMatchesList(matches);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  String _getFilterLabel() {
    switch (_filterStatus) {
      case MatchStatus.pending:
        return 'Pending';
      case MatchStatus.accepted:
        return 'Accepted';
      case MatchStatus.rejected:
        return 'Rejected';
      case null:
        return 'All';
      default:
        return 'Filter';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No match requests',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Applications will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(List<MeetupMatchModel> matches) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _MatchRequestCard(
          match: match,
          onAccept: () => _acceptMatch(match.id),
          onReject: () => _rejectMatch(match.id),
        );
      },
    );
  }
}

class _MatchRequestCard extends StatelessWidget {
  final MeetupMatchModel match;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _MatchRequestCard({
    required this.match,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: match.user.avatarUrl != null
                      ? NetworkImage(match.user.avatarUrl!)
                      : null,
                  child: match.user.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.user.fullName ?? match.user.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Applied ${dateFormat.format(match.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(match.status),
              ],
            ),

            // Message
            if (match.message != null && match.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(match.message!),
              ),
            ],

            // Action buttons
            if (match.status == MatchStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else if (match.respondedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Responded ${dateFormat.format(match.respondedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MatchStatus status) {
    Color color;
    String label;

    switch (status) {
      case MatchStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case MatchStatus.accepted:
        color = Colors.green;
        label = 'Accepted';
        break;
      case MatchStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case MatchStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        break;
      case MatchStatus.confirmed:
        color = Colors.blue;
        label = 'Confirmed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
}
