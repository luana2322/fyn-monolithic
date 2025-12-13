import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/story_model.dart';
import '../../data/repositories/story_repository.dart';

/// Story repository provider
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StoryRepository(apiClient);
});

/// Story feed state
class StoryFeedState {
  final StoryFeedModel? feed;
  final bool isLoading;
  final String? error;

  const StoryFeedState({
    this.feed,
    this.isLoading = false,
    this.error,
  });

  StoryFeedState copyWith({
    StoryFeedModel? feed,
    bool? isLoading,
    String? error,
  }) {
    return StoryFeedState(
      feed: feed ?? this.feed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<StoryUserWithStories> get storyUsers => feed?.users ?? [];
  StoryUserWithStories? get currentUser => feed?.currentUser;
  bool get hasStories => storyUsers.isNotEmpty || (currentUser?.stories.isNotEmpty ?? false);
}

/// Story feed notifier
class StoryFeedNotifier extends StateNotifier<StoryFeedState> {
  final StoryRepository _repository;

  StoryFeedNotifier(this._repository) : super(const StoryFeedState());

  Future<void> loadStories() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final feed = await _repository.getStoryFeed();
      state = state.copyWith(feed: feed, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final feed = await _repository.getStoryFeed();
      state = state.copyWith(feed: feed, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createStory({
    required String mediaUrl,
    String mediaType = 'IMAGE',
    String? textContent,
    String? backgroundColor,
  }) async {
    try {
      await _repository.createStory(
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        textContent: textContent,
        backgroundColor: backgroundColor,
      );
      // Refresh stories after creating
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> viewStory(String storyId) async {
    await _repository.viewStory(storyId);
  }

  Future<void> deleteStory(String storyId) async {
    await _repository.deleteStory(storyId);
    await refresh();
  }
}

/// Story feed provider
final storyFeedProvider = StateNotifierProvider<StoryFeedNotifier, StoryFeedState>((ref) {
  final repository = ref.watch(storyRepositoryProvider);
  return StoryFeedNotifier(repository);
});

/// Selected user's stories provider (for viewing)
final selectedStoryUserProvider = StateProvider<StoryUserWithStories?>((ref) => null);

/// Current story index provider (for story viewer)
final currentStoryIndexProvider = StateProvider<int>((ref) => 0);
