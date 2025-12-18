import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/models/user_list_item_response.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../data/models/search_filter.dart';
import '../widgets/user_list_item.dart';
import '../widgets/user_filter_bottom_sheet.dart';
import '../../../../core/network/api_client.dart';

// Provider for UserRepository - creates ApiClient directly
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ApiClient();
  return UserRepository(apiClient);
});

/// Provider cho search filter
final searchFilterProvider = StateProvider<SearchFilter>((ref) => SearchFilter());

/// Provider cho user search list
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

/// Discover screen với list view thay vì swipe cards
class DiscoverListScreen extends ConsumerStatefulWidget {
  const DiscoverListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscoverListScreen> createState() => _DiscoverListScreenState();
}

class _DiscoverListScreenState extends ConsumerState<DiscoverListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoadingMore = false;
      });
    });
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
          setState(() {
            _currentPage = 0;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(searchFilterProvider);
    final usersAsync = ref.watch(userSearchProvider(_currentPage));

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
      body: usersAsync.when(
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
                      fontSize: 14,
                    ),
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
              ref.invalidate(userSearchProvider);
              setState(() {
                _currentPage = 0;
              });
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: users.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[850],
                indent: 72,
              ),
              itemBuilder: (context, index) {
                if (index >= users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.pink,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final user = users[index];
                return UserListItem(
                  user: user,
                  onTap: () {
                    // Navigate to user profile
                    context.push('/profile/${user.id}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );
  }
}
