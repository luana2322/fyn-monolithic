import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/connection_repository.dart';
import '../../../../core/network/api_client.dart';

/// Provider for ConnectionRepository
final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final apiClient = ApiClient();
  return ConnectionRepository(apiClient);
});

/// Provider to track followed user IDs
final followedUsersProvider = StateNotifierProvider<FollowedUsersNotifier, Set<String>>((ref) {
  final repository = ref.watch(connectionRepositoryProvider);
  return FollowedUsersNotifier(repository);
});

class FollowedUsersNotifier extends StateNotifier<Set<String>> {
  final ConnectionRepository _repository;
  bool _isInitialized = false;

  FollowedUsersNotifier(this._repository) : super({}) {
    _loadFollowedUsers();
  }

  /// Load followed users from backend
  Future<void> _loadFollowedUsers() async {
    if (_isInitialized) return;
    
    try {
      final followedIds = await _repository.getFollowingUserIds();
      state = followedIds.toSet();
      _isInitialized = true;
    } catch (e) {
      print('Error loading followed users: $e');
      // Keep empty set on error
    }
  }

  /// Add a user to followed list and sync with backend
  Future<void> followUser(String userId) async {
    // Optimistically update UI
    state = {...state, userId};
    
    try {
      await _repository.followUser(userId);
    } catch (e) {
      // Revert on error
      state = state.where((id) => id != userId).toSet();
      print('Error following user: $e');
      rethrow;
    }
  }

  /// Remove a user from followed list and sync with backend
  Future<void> unfollowUser(String userId) async {
    // Optimistically update UI
    final previousState = state;
    state = state.where((id) => id != userId).toSet();
    
    try {
      await _repository.unfollowUser(userId);
    } catch (e) {
      // Revert on error
      state = previousState;
      print('Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Check if user is followed
  bool isFollowing(String userId) {
    return state.contains(userId);
  }

  /// Reload followed users from backend
  Future<void> reload() async {
    _isInitialized = false;
    await _loadFollowedUsers();
  }

  /// Clear all followed users (for testing/reset)
  void clear() {
    state = {};
    _isInitialized = false;
  }
}
