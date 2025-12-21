import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/models/user_list_item_response.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../data/models/search_filter.dart';
import '../widgets/user_list_item.dart';
import '../widgets/user_filter_bottom_sheet.dart';
import '../widgets/friend_suggestion_card.dart';
import '../providers/followed_users_provider.dart';
import '../../../../core/network/api_client.dart';

// Provider for UserRepository - creates ApiClient directly
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ApiClient();
  return UserRepository(apiClient);
});

/// Provider cho search filter
final searchFilterProvider = StateProvider<SearchFilter>((ref) => SearchFilter());

/// Provider cho user search list (with keyword)
final userSearchProvider = FutureProvider.autoDispose
    .family<List<UserListItemResponse>, int>((ref, page) async {
  final filter = ref.watch(searchFilterProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  
  final result = await userRepository.searchUsers(
    filter: filter,
    page: page,
    size: 20,
  );
  
  return result.content;
});

/// Provider for friend suggestions (without keyword)
final friendSuggestionsProvider = FutureProvider.autoDispose
    .family<List<UserListItemResponse>, int>((ref, page) async {
  final filter = ref.watch(searchFilterProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final followedUsers = ref.watch(followedUsersProvider);
  
  // Remove keyword from filter for friend suggestions
  final suggestionsFilter = filter.copyWith(clearKeyword: true);
  
  final result = await userRepository.searchUsers(
    filter: suggestionsFilter,
    page: page,
    size: 20,
  );
  
  // Filter out users that are already followed
  final filteredContent = result.content
      .where((user) => !followedUsers.contains(user.id))
      .toList();
  
  return filteredContent;
});

/// Discover screen với list view thay vì swipe cards
class DiscoverListScreen extends ConsumerStatefulWidget {
  const DiscoverListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscoverListScreen> createState() => _DiscoverListScreenState();
}

class _DiscoverListScreenState extends ConsumerState<DiscoverListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserFilterBottomSheet(
        currentFilter: ref.read(searchFilterProvider),
        onApply: (filter) {
          ref.read(searchFilterProvider.notifier).state = filter;
        },
      ),
    );
  }

  void _onSearchChanged(String value) {
    final currentFilter = ref.read(searchFilterProvider);
    ref.read(searchFilterProvider.notifier).state = currentFilter.copyWith(
      keyword: value.isEmpty ? null : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(searchFilterProvider);
    final searchResultsAsync = ref.watch(userSearchProvider(0));
    final suggestionsAsync = ref.watch(friendSuggestionsProvider(0));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Khám phá',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Filter button with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: _showFilterSheet,
              ),
              if (filter.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, sở thích...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Conditionally show search results section when searching
          if (_searchController.text.isNotEmpty) ...[
            // Search Results Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF121212),
              child: Text(
                'Kết quả tìm kiếm',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Search Results List
            Expanded(
              flex: 1,
              child: searchResultsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.pink),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        'Có lỗi xảy ra',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy kết quả',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[850],
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserListItem(
                        user: user,
                        onTap: () {
                          context.push('/profile/${user.id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Divider between sections
            Container(
              height: 8,
              color: const Color(0xFF0D0D0D),
            ),
          ],
          
          // Friend Suggestions Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF121212),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  'Gợi ý kết bạn',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Friend Suggestions List
          Expanded(
            flex: _searchController.text.isEmpty ? 1 : 1,
            child: suggestionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(userSearchProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy người dùng',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thử thay đổi bộ lọc',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _showFilterSheet,
                          icon: const Icon(Icons.tune, color: Colors.pink),
                          label: const Text(
                            'Mở bộ lọc',
                            style: TextStyle(color: Colors.pink),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.pink),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Colors.pink,
                  backgroundColor: const Color(0xFF1E1E1E),
                  onRefresh: () async {
                    ref.invalidate(friendSuggestionsProvider);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate number of columns based on screen width
                      int crossAxisCount;
                      if (constraints.maxWidth < 600) {
                        crossAxisCount = 2; // Mobile
                      } else if (constraints.maxWidth < 900) {
                        crossAxisCount = 3; // Tablet
                      } else {
                        crossAxisCount = 4; // Desktop
                      }

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return FriendSuggestionCard(
                            user: user,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );
  }
}
