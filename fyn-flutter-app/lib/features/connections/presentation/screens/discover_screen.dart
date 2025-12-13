import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/meetup_model.dart';
import '../providers/discover_provider.dart';
import '../widgets/swipe_card.dart';

/// Discover screen with swipe cards for matching
/// Tinder-like UI with draggable cards
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  
  // Animation controller for swipe feedback
  late AnimationController _animationController;
  Offset _dragOffset = Offset.zero;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Load initial profiles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoverProvider.notifier).loadProfiles();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          // Connection type filter tabs
          _buildConnectionTypeTabs(state),
          // Main card stack
          Expanded(
            child: _buildCardStack(state),
          ),
          // Action buttons
          if (state.currentProfile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SwipeActionButtons(
                isLoading: state.isLoading,
                onDislike: () => _handleSwipe('DISLIKE'),
                onLike: () => _handleSwipe('LIKE'),
                onSuperlike: () => _handleSwipe('SUPERLIKE'),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DiscoverState state) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text(
            'Discover',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.black54),
          onPressed: () {
            // TODO: Open filters
          },
        ),
      ],
    );
  }

  Widget _buildConnectionTypeTabs(DiscoverState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ConnectionType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ConnectionTypeChip(
              type: type,
              isSelected: state.connectionType == type,
              onTap: () {
                ref.read(discoverProvider.notifier).setConnectionType(type);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardStack(DiscoverState state) {
    // Loading state
    if (state.isLoading && state.profiles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding matches...'),
          ],
        ),
      );
    }

    // Error state
    if (state.error != null && state.profiles.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Oops!',
        subtitle: state.error!,
        actionLabel: 'Retry',
        onAction: () => ref.read(discoverProvider.notifier).loadProfiles(),
      );
    }

    // Empty state
    if (state.profiles.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No matches found',
        subtitle: 'Try adjusting your filters or check back later',
        actionLabel: 'Refresh',
        onAction: () => ref.read(discoverProvider.notifier).loadProfiles(),
      );
    }

    // No more profiles
    if (state.currentProfile == null) {
      return EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: "You've seen everyone!",
        subtitle: 'Come back later for new matches',
        actionLabel: 'Refresh',
        onAction: () => ref.read(discoverProvider.notifier).loadProfiles(),
      );
    }

    // Card stack with draggable top card
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background card (next card preview)
          if (state.hasMoreProfiles)
            Transform.scale(
              scale: 0.95,
              child: Opacity(
                opacity: 0.6,
                child: SwipeCard(
                  match: state.profiles[state.currentIndex + 1],
                ),
              ),
            ),
          // Front card (draggable)
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(_dragOffset.dx, _dragOffset.dy)
                ..rotateZ(_rotation),
              alignment: Alignment.center,
              child: SwipeCard(
                match: state.currentProfile!,
                onTap: () => _showProfileDetails(state.currentProfile!),
              ),
            ),
          ),
          // Swipe indicators
          _buildSwipeIndicators(),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    // Show LIKE/NOPE overlays based on drag position
    final likeOpacity = (_dragOffset.dx / 100).clamp(0.0, 1.0);
    final nopeOpacity = (-_dragOffset.dx / 100).clamp(0.0, 1.0);

    return Stack(
      children: [
        // LIKE indicator (right swipe)
        Positioned(
          top: 50,
          left: 30,
          child: Opacity(
            opacity: likeOpacity,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIKE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        // NOPE indicator (left swipe)
        Positioned(
          top: 50,
          right: 30,
          child: Opacity(
            opacity: nopeOpacity,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NOPE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _rotation = _dragOffset.dx / 500; // Rotate based on horizontal drag
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final screenWidth = MediaQuery.of(context).size.width;

    // Threshold for swipe action
    if (_dragOffset.dx.abs() > screenWidth * 0.3 || velocity.abs() > 1000) {
      if (_dragOffset.dx > 0) {
        _handleSwipe('LIKE');
      } else {
        _handleSwipe('DISLIKE');
      }
    }

    // Reset position
    setState(() {
      _dragOffset = Offset.zero;
      _rotation = 0;
    });
  }

  Future<void> _handleSwipe(String type) async {
    final result = await ref.read(discoverProvider.notifier).swipe(type);
    
    // Show match celebration if matched
    if (result?.isMatch == true) {
      _showMatchDialog();
    }
  }

  void _showMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 64, color: Colors.pink),
            const SizedBox(height: 16),
            const Text(
              "It's a Match! 🎉",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You both liked each other!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Keep Swiping'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to chat
                  },
                  child: const Text('Send Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDetails(dynamic match) {
    // Navigate to full profile view
    context.push('/profile/${match.user.id}');
  }
}
