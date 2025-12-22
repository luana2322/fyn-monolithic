import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import '../widgets/meetup_card.dart';
import 'create_meetup_screen.dart';
import 'meetup_details_screen.dart';
import 'applicants_screen.dart';
import 'owner_meetup_detail_screen.dart';
import '../../../message/presentation/screens/chat_detail_screen.dart';
import '../../../message/presentation/providers/message_provider.dart';

class DiscoverMeetupsScreen extends ConsumerStatefulWidget {
  const DiscoverMeetupsScreen({super.key});

  @override
  ConsumerState<DiscoverMeetupsScreen> createState() => _DiscoverMeetupsScreenState();
}

class _DiscoverMeetupsScreenState extends ConsumerState<DiscoverMeetupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MeetType? _selectedMeetType;
  String? _selectedCategory;
  String _sortBy = 'soonest';
  double _radiusKm = 10.0;

  final List<String> _categories = [
    'Sports',
    'Gaming',
    'Music',
    'Art',
    'Food',
    'Tech',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiscoverMeetups();
      _loadMyMeetups();
      _loadAppliedMeetups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDiscoverMeetups() async {
    // Try to get current location, fallback to Đà Nẵng
    double lat = 16.0544; // Default: Đà Nẵng
    double lng = 108.2022;
    
    try {
      final position = await _getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (e) {
      // Use default location on error
      debugPrint('Could not get location: $e');
    }
    
    ref.read(discoveredMeetupsProvider.notifier).discoverMeetups(
      latitude: lat,
      longitude: lng,
      radiusKm: _radiusKm,
      meetType: _selectedMeetType,
      category: _selectedCategory,
      sortBy: _sortBy,
    );
  }

  void _loadAppliedMeetups() {
    ref.read(appliedMeetupsProvider.notifier).loadAppliedMeetups();
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  void _loadMyMeetups() {
    ref.read(myMeetupsProvider.notifier).loadMyMeetups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'My Meetups'),
            Tab(text: 'Applied'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildMyMeetupsTab(),
          _buildAppliedTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateMeetupScreen(),
            ),
          ).then((_) {
            _loadDiscoverMeetups();
            _loadMyMeetups();
            _loadAppliedMeetups();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Meetup'),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final meetupsAsync = ref.watch(discoveredMeetupsProvider);
    return RefreshIndicator(
      onRefresh: () async => _loadDiscoverMeetups(),
      child: meetupsAsync.when(
        data: (meetups) {
          if (meetups.isEmpty) {
            return _buildEmptyState('No meetups found nearby');
          }
          return _buildMeetupsList(meetups);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, _loadDiscoverMeetups),
      ),
    );
  }

  Widget _buildMyMeetupsTab() {
    final meetupsAsync = ref.watch(myMeetupsProvider);
    return RefreshIndicator(
      onRefresh: () async => _loadMyMeetups(),
      child: meetupsAsync.when(
        data: (meetups) {
          if (meetups.isEmpty) {
            return _buildEmptyState('You haven\'t created any meetups yet');
          }
          return _buildMeetupsList(meetups, isMyMeetups: true);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, _loadMyMeetups),
      ),
    );
  }

  Widget _buildAppliedTab() {
    final appliedAsync = ref.watch(appliedMeetupsProvider);
    return RefreshIndicator(
      onRefresh: () async => _loadAppliedMeetups(),
      child: appliedAsync.when(
        data: (matches) {
          if (matches.isEmpty) {
            return _buildEmptyState('You haven\'t applied to any meetups yet');
          }
          return _buildAppliedList(matches);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, _loadAppliedMeetups),
      ),
    );
  }

  Widget _buildAppliedList(List<MeetupMatchModel> matches) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isAccepted = match.status == MatchStatus.accepted || match.status == MatchStatus.confirmed;
        final hasChat = match.conversationId != null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                leading: _buildStatusIcon(match.status),
                title: Text('Meetup: ${match.meetupId.substring(0, 8)}...'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${match.status.name.toUpperCase()}'),
                    Text('Applied: ${match.createdAt != null ? _formatDate(match.createdAt!) : 'N/A'}'),
                    if (match.message != null && match.message!.isNotEmpty)
                      Text('Message: ${match.message}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                isThreeLine: true,
                trailing: _buildStatusBadge(match.status),
              ),
              // Chat button when accepted and has conversationId
              if (isAccepted && hasChat)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(match.conversationId!),
                      icon: const Icon(Icons.chat),
                      label: const Text('Mở Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openChat(String conversationId) async {
    try {
      final messageRepo = ref.read(messageRepositoryProvider);
      final conversation = await messageRepo.getConversationById(conversationId);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở chat: $e')),
        );
      }
    }
  }

  Widget _buildStatusIcon(MatchStatus status) {
    switch (status) {
      case MatchStatus.pending:
        return const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.hourglass_empty, color: Colors.white));
      case MatchStatus.accepted:
        return const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white));
      case MatchStatus.rejected:
        return const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.close, color: Colors.white));
      case MatchStatus.cancelled:
        return const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.block, color: Colors.white));
      case MatchStatus.confirmed:
        return const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.verified, color: Colors.white));
    }
  }

  Widget _buildStatusBadge(MatchStatus status) {
    Color color;
    switch (status) {
      case MatchStatus.pending:
        color = Colors.orange;
        break;
      case MatchStatus.accepted:
        color = Colors.green;
        break;
      case MatchStatus.rejected:
        color = Colors.red;
        break;
      case MatchStatus.cancelled:
        color = Colors.grey;
        break;
      case MatchStatus.confirmed:
        color = Colors.blue;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildMeetupsList(List<MeetupModel> meetups, {bool isMyMeetups = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meetups.length,
      itemBuilder: (context, index) {
        final meetup = meetups[index];
        return MeetupCard(
          meetup: meetup,
          isOwner: isMyMeetups,
          onViewApplicants: isMyMeetups ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ApplicantsScreen(meetup: meetup),
              ),
            ).then((_) => _loadMyMeetups());
          } : null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => isMyMeetups
                    ? OwnerMeetupDetailScreen(meetup: meetup)
                    : MeetupDetailsScreen(meetupId: meetup.id),
              ),
            ).then((result) {
              // Always refresh when returning from owner detail screen
              // result == true means meetup was cancelled
              if (isMyMeetups) {
                _loadMyMeetups();
              } else {
                _loadDiscoverMeetups();
              }
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
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
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create one!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading meetups'),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Meet Type Filter
                Text('Meet Type', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<MeetType?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(value: MeetType.oneToOne, label: Text('1-on-1')),
                    ButtonSegment(value: MeetType.group, label: Text('Group')),
                  ],
                  selected: {_selectedMeetType},
                  onSelectionChanged: (Set<MeetType?> newSelection) {
                    setSheetState(() => _selectedMeetType = newSelection.first);
                  },
                ),
                const SizedBox(height: 16),

                // Category Filter
                Text('Category', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setSheetState(() => _selectedCategory = null);
                      },
                    ),
                    ..._categories.map((category) => FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setSheetState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                // Radius Filter
                Text('Radius: ${_radiusKm.toStringAsFixed(0)} km',
                    style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: _radiusKm,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${_radiusKm.toStringAsFixed(0)} km',
                  onChanged: (value) {
                    setSheetState(() => _radiusKm = value);
                  },
                ),
                const SizedBox(height: 16),

                // Sort By
                Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'soonest', label: Text('Soonest')),
                    ButtonSegment(value: 'nearest', label: Text('Nearest')),
                  ],
                  selected: {_sortBy},
                  onSelectionChanged: (Set<String> newSelection) {
                    setSheetState(() => _sortBy = newSelection.first);
                  },
                ),
                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                      _loadDiscoverMeetups();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
