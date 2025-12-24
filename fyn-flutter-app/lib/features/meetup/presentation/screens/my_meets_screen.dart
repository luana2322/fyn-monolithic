import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import '../widgets/meetup_card.dart';
import 'meetup_details_screen.dart';
import 'owner_meetup_detail_screen.dart';

/// Screen showing user's created meetups, applied meetups, and history
class MyMeetsScreen extends ConsumerStatefulWidget {
  const MyMeetsScreen({super.key});

  @override
  ConsumerState<MyMeetsScreen> createState() => _MyMeetsScreenState();
}

class _MyMeetsScreenState extends ConsumerState<MyMeetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myMeetupsProvider.notifier).loadMyMeetups();
      ref.read(appliedMeetupsProvider.notifier).loadAppliedMeetups();
      ref.read(meetupHistoryProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Meets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Organized', icon: Icon(Icons.event_available)),
            Tab(text: 'Applied', icon: Icon(Icons.event_note)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrganizedMeets(),
          _buildAppliedMeets(),
          _buildHistoryMeets(),
        ],
      ),
    );
  }

  Widget _buildOrganizedMeets() {
    final meetupsAsync = ref.watch(myMeetupsProvider);
    
    return meetupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(myMeetupsProvider.notifier).loadMyMeetups(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (meetups) {
        if (meetups.isEmpty) {
          return _buildPlaceholder('No organized meetups yet');
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(myMeetupsProvider.notifier).loadMyMeetups(),
          child: _buildMeetsList(meetups, isOrganizer: true),
        );
      },
    );
  }

  Widget _buildAppliedMeets() {
    final appliedAsync = ref.watch(appliedMeetupsProvider);
    
    return appliedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(appliedMeetupsProvider.notifier).loadAppliedMeetups(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return _buildPlaceholder('No applied meetups yet');
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(appliedMeetupsProvider.notifier).loadAppliedMeetups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: _buildStatusIcon(match.status),
                  title: Text('Meetup: ${match.meetupId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${_getMatchStatusText(match.status)}'),
                      if (match.message != null && match.message!.isNotEmpty)
                        Text('Your message: ${match.message}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetupDetailsScreen(meetupId: match.meetupId),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryMeets() {
    final historyAsync = ref.watch(meetupHistoryProvider);
    
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(meetupHistoryProvider.notifier).loadHistory(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (meetups) {
        if (meetups.isEmpty) {
          return _buildPlaceholder('No meetup history yet');
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(meetupHistoryProvider.notifier).loadHistory(),
          child: _buildHistoryList(meetups),
        );
      },
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetsList(List<MeetupModel> meets, {bool isOrganizer = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meets.length,
      itemBuilder: (context, index) {
        final meet = meets[index];
        return MeetupCard(
          meetup: meet,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => isOrganizer
                    ? OwnerMeetupDetailScreen(meetup: meet)
                    : MeetupDetailsScreen(meetupId: meet.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryList(List<MeetupModel> meets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meets.length,
      itemBuilder: (context, index) {
        final meet = meets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _buildMeetupStatusIcon(meet.status),
            title: Text(meet.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${_getMeetupStatusText(meet.status)}'),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(meet.scheduledAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeetupDetailsScreen(meetupId: meet.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getMatchStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.pending:
        return 'Pending';
      case MatchStatus.accepted:
        return 'Accepted';
      case MatchStatus.rejected:
        return 'Rejected';
      case MatchStatus.cancelled:
        return 'Cancelled';
      case MatchStatus.confirmed:
        return 'Confirmed';
    }
  }

  String _getMeetupStatusText(MeetupStatus status) {
    switch (status) {
      case MeetupStatus.open:
        return 'Open';
      case MeetupStatus.matched:
        return 'Matched';
      case MeetupStatus.waitingConfirmation:
        return 'Waiting Confirmation';
      case MeetupStatus.completed:
        return 'Completed';
      case MeetupStatus.cancelled:
        return 'Cancelled';
      case MeetupStatus.expired:
        return 'Expired';
    }
  }

  Widget _buildStatusIcon(MatchStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case MatchStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
      case MatchStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.green;
      case MatchStatus.rejected:
        icon = Icons.cancel;
        color = Colors.red;
      case MatchStatus.cancelled:
        icon = Icons.block;
        color = Colors.grey;
      case MatchStatus.confirmed:
        icon = Icons.verified;
        color = Colors.blue;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildMeetupStatusIcon(MeetupStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case MeetupStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
      case MeetupStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.red;
      case MeetupStatus.expired:
        icon = Icons.timer_off;
        color = Colors.grey;
      case MeetupStatus.open:
      case MeetupStatus.matched:
      case MeetupStatus.waitingConfirmation:
        icon = Icons.event;
        color = Colors.blue;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }
}
