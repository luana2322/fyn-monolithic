import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/match_model.dart';
import '../../data/models/meetup_model.dart';
import '../../data/repositories/match_repository.dart';

// Repository provider
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MatchRepository(apiClient);
});

/// State for discover screen (swipe cards)
class DiscoverState {
  final List<MatchModel> profiles;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentIndex;
  final ConnectionType connectionType;

  const DiscoverState({
    this.profiles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentIndex = 0,
    this.connectionType = ConnectionType.dating,
  });

  DiscoverState copyWith({
    List<MatchModel>? profiles,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentIndex,
    ConnectionType? connectionType,
    bool clearError = false,
  }) {
    return DiscoverState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentIndex: currentIndex ?? this.currentIndex,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  /// Current profile to display
  MatchModel? get currentProfile => 
      profiles.isNotEmpty && currentIndex < profiles.length 
          ? profiles[currentIndex] 
          : null;

  /// Check if more profiles available
  bool get hasMoreProfiles => currentIndex < profiles.length - 1;
}

/// Notifier for discover screen
class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final MatchRepository _repository;

  DiscoverNotifier(this._repository) : super(const DiscoverState());

  /// Load initial profiles
  Future<void> loadProfiles({ConnectionType? type}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      connectionType: type ?? state.connectionType,
      currentIndex: 0,
    );
    try {
      final profiles = await _repository.getDiscoverMatches(
        connectionType: (type ?? state.connectionType).value,
        size: 20,
      );
      state = state.copyWith(
        profiles: profiles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Swipe action (like/dislike/superlike)
  Future<SwipeResult?> swipe(String swipeType) async {
    final current = state.currentProfile;
    if (current == null) return null;

    try {
      final result = await _repository.swipe(
        targetUserId: current.user.id,
        swipeType: swipeType,
      );
      
      // Move to next profile
      _moveToNext();
      
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Move to next profile
  void _moveToNext() {
    if (state.currentIndex < state.profiles.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      // Reload more profiles when running low
      loadProfiles();
    }
  }

  /// Skip current profile (undo not implemented)
  void skip() => _moveToNext();

  /// Change connection type filter
  void setConnectionType(ConnectionType type) {
    if (type != state.connectionType) {
      loadProfiles(type: type);
    }
  }
}

// Provider for discover screen
final discoverProvider = StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  return DiscoverNotifier(repository);
});

/// State for matches list
class MatchesState {
  final List<MatchModel> matches;
  final bool isLoading;
  final String? error;
  final ConnectionType? filterType;
  final String? filterStatus;

  const MatchesState({
    this.matches = const [],
    this.isLoading = false,
    this.error,
    this.filterType,
    this.filterStatus,
  });

  MatchesState copyWith({
    List<MatchModel>? matches,
    bool? isLoading,
    String? error,
    ConnectionType? filterType,
    String? filterStatus,
    bool clearError = false,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterType: filterType ?? this.filterType,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

/// Notifier for matches list
class MatchesNotifier extends StateNotifier<MatchesState> {
  final MatchRepository _repository;

  MatchesNotifier(this._repository) : super(const MatchesState());

  /// Load matches
  Future<void> loadMatches({
    ConnectionType? type,
    String? status,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      filterType: type,
      filterStatus: status,
    );
    try {
      final matches = await _repository.getMatches(
        connectionType: type?.value,
        status: status,
      );
      state = state.copyWith(
        matches: matches,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Block a match
  Future<void> blockMatch(String matchId) async {
    try {
      await _repository.blockMatch(matchId);
      state = state.copyWith(
        matches: state.matches.where((m) => m.id != matchId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider for matches list
final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  return MatchesNotifier(repository);
});
