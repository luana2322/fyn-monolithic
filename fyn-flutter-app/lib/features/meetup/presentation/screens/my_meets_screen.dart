import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../widgets/meetup_card.dart';
import 'meetup_details_screen.dart';

/// Screen showing user's created meetups and meetups they've applied to
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
    _tabController = TabController(length: 2, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrganizedMeets(),
          _buildAppliedMeets(),
        ],
      ),
    );
  }

  Widget _buildOrganizedMeets() {
    // TODO: In real implementation, fetch user's organized meetups
    // For now, using discovered meetups filtered by organizer
    return _buildPlaceholder('Your organized meetups will appear here');
  }

  Widget _buildAppliedMeets() {
    // TODO: In real implementation, fetch meetups user has applied to
    // Filter by userHasApplied = true
    return _buildPlaceholder('Meetups you\'ve applied to will appear here');
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

  Widget _buildMeetsList(List<MeetupModel> meets) {
    if (meets.isEmpty) {
      return _buildPlaceholder('No meetups found');
    }

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
                builder: (_) => MeetupDetailsScreen(meetupId: meet.id),
              ),
            );
          },
        );
      },
    );
  }
}
