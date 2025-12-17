import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/meetup_model.dart';
import '../providers/discover_provider.dart';
import '../widgets/compact_match_card.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/dating_colors.dart';

/// Matches screen showing all current matches
class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  ConnectionType? _selectedType;
  String _selectedStatus = 'matched';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchesProvider.notifier).loadMatches(status: _selectedStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DatingColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? DatingColors.darkNavBackground : null,
        title: Text(
          'My Matches',
          style: TextStyle(color: isDark ? DatingColors.darkPrimaryText : null),
        ),
        iconTheme: IconThemeData(color: isDark ? DatingColors.darkPrimaryText : null),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilters(isDark),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 700,
        backgroundColor: isDark ? DatingColors.darkBackground : AppColors.background,
        child: _buildBody(state, isDark),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      color: isDark ? DatingColors.darkNavBackground : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Status filter chips
            _FilterChip(
              label: 'Matched',
              isSelected: _selectedStatus == 'matched',
              onTap: () => _setStatus('matched'),
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Liked You',
              isSelected: _selectedStatus == 'liked',
              onTap: () => _setStatus('liked'),
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pending',
              isSelected: _selectedStatus == 'pending',
              onTap: () => _setStatus('pending'),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  void _setStatus(String status) {
    setState(() => _selectedStatus = status);
    ref.read(matchesProvider.notifier).loadMatches(
      status: status,
      type: _selectedType,
    );
  }

  Widget _buildBody(MatchesState state, bool isDark) {
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
              state.error!,
              style: TextStyle(color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(matchesProvider.notifier).loadMatches(status: _selectedStatus),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No matches yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep swiping to find your match!',
              style: TextStyle(color: isDark ? DatingColors.darkSecondaryText : Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/discover'),
              icon: const Icon(Icons.explore),
              label: const Text('Start Discovering'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(matchesProvider.notifier).loadMatches(status: _selectedStatus),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.matches.length,
        itemBuilder: (context, index) {
          final match = state.matches[index];
          return CompactMatchCard(
            match: match,
            status: 'ACCEPTED', // TODO: Get actual status from match
            onTap: () => context.push('/profile/${match.user.id}'),
            onComplete: () => _showActionDialog(
              'Mark as Completed?',
              'This will mark the meetup as successfully completed.',
              () => ref.read(matchesProvider.notifier).completeMatch(match.id),
            ),
            onCancel: () => _showActionDialog(
              'Cancel this match?',
              'You can rematch in the future.',
              () => ref.read(matchesProvider.notifier).cancelMatch(match.id),
            ),
            onNoShow: () => _showActionDialog(
              'Report No-show?',
              'This will apply a penalty to the other user\'s reputation.',
              () => ref.read(matchesProvider.notifier).reportNoShow(match.id),
            ),
          );
        },
      ),
    );
  }

  void _showActionDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(String matchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block this person?'),
        content: const Text('They won\'t be able to contact you anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(matchesProvider.notifier).blockMatch(matchId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final dynamic match;
  final VoidCallback? onTap;
  final VoidCallback? onBlock;

  const _MatchCard({
    required this.match,
    this.onTap,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final user = match.user;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              user.primaryPhoto != null
                  ? Image.network(
                      user.primaryPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(user),
                    )
                  : _buildPlaceholder(user),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              // Info
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${user.displayName}, ${user.age ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (match.commonInterests.isNotEmpty)
                      Text(
                        '${match.commonInterests.length} common interests',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              // Match score badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${match.matchScore.toInt()}%',
                    style: TextStyle(
                      color: _getScoreColor(match.matchScore),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(dynamic user) {
    final colors = [Colors.purple, Colors.blue, Colors.teal, Colors.orange, Colors.pink];
    final color = colors[user.username.hashCode % colors.length];
    
    return Container(
      color: color,
      child: Center(
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.grey;
  }
}
