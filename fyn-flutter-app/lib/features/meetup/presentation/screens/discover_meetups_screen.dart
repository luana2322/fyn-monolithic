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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiscoverMeetups();
      _loadMyMeetups();
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildMyMeetupsTab(),
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
            ).then((_) {
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
