import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dates_provider.dart';
import '../widgets/date_card.dart';

/// Screen showing user's own date plans
class MyDatesScreen extends ConsumerStatefulWidget {
  const MyDatesScreen({super.key});

  @override
  ConsumerState<MyDatesScreen> createState() => _MyDatesScreenState();
}

class _MyDatesScreenState extends ConsumerState<MyDatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myDatesProvider.notifier).loadDates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myDatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Date Plans'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Pending'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDatesList(state, filter: 'accepted'),
          _buildDatesList(state, filter: 'open'),
          _buildDatesList(state, filter: 'completed'),
        ],
      ),
    );
  }

  Widget _buildDatesList(MyDatesState state, {required String filter}) {
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
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(myDatesProvider.notifier).loadDates(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter dates based on status
    final filteredDates = state.dates.where((date) {
      if (filter == 'accepted') {
        return date.status == 'accepted' && date.scheduledAt.isAfter(DateTime.now());
      } else if (filter == 'open') {
        return date.status == 'open' || date.status == 'proposal_pending';
      } else {
        return date.status == 'completed' || date.scheduledAt.isBefore(DateTime.now());
      }
    }).toList();

    if (filteredDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter == 'accepted' ? Icons.event_available :
              filter == 'open' ? Icons.pending_actions : Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              filter == 'accepted' ? 'No upcoming dates' :
              filter == 'open' ? 'No pending dates' : 'No past dates',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'open' ? 'Create a new date plan!' : '',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myDatesProvider.notifier).loadDates(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDates.length,
        itemBuilder: (context, index) {
          final date = filteredDates[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DateCard(
              date: date,
              isOwner: true,
              onTap: () => _showDateDetails(date),
              onCancel: date.isOpen ? () => _showCancelDialog(date) : null,
              onViewProposals: date.proposalCount > 0
                  ? () => _showProposals(date)
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showDateDetails(dynamic date) {
    // TODO: Navigate to date detail screen
  }

  void _showCancelDialog(dynamic date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this date?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(myDatesProvider.notifier).cancelDate(date.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Date'),
          ),
        ],
      ),
    );
  }

  void _showProposals(dynamic date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProposalsListSheet(dateId: date.id, dateTitle: date.title),
    );
  }
}

/// Bottom sheet showing proposals for a date
class ProposalsListSheet extends ConsumerStatefulWidget {
  final String dateId;
  final String dateTitle;

  const ProposalsListSheet({
    super.key,
    required this.dateId,
    required this.dateTitle,
  });

  @override
  ConsumerState<ProposalsListSheet> createState() => _ProposalsListSheetState();
}

class _ProposalsListSheetState extends ConsumerState<ProposalsListSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proposalsProvider(widget.dateId).notifier).loadProposals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalsProvider(widget.dateId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Proposals for "${widget.dateTitle}"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Proposals list
          Expanded(
            child: _buildProposalsList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsList(ProposalsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.proposals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No proposals yet'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.proposals.length,
      itemBuilder: (context, index) {
        final proposal = state.proposals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Proposer info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: proposal.proposer.primaryPhoto != null
                          ? NetworkImage(proposal.proposer.primaryPhoto!)
                          : null,
                      child: proposal.proposer.primaryPhoto == null
                          ? Text(proposal.proposer.displayName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proposal.proposer.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatTimeAgo(proposal.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (proposal.isPending) _buildStatusBadge('Pending', Colors.orange),
                    if (proposal.isAccepted) _buildStatusBadge('Accepted', Colors.green),
                  ],
                ),
                // Message
                if (proposal.message != null && proposal.message!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(proposal.message!),
                ],
                // Proposed time
                if (proposal.proposedTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Suggested: ${_formatDateTime(proposal.proposedTime!)}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ],
                // Actions
                if (proposal.isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => ref
                            .read(proposalsProvider(widget.dateId).notifier)
                            .rejectProposal(proposal.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Decline'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(proposalsProvider(widget.dateId).notifier)
                              .acceptProposal(proposal.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
