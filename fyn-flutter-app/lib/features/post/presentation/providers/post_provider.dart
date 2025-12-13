import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/page_response.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/create_post_request.dart';
import '../../data/models/post_model.dart';
import '../../data/models/post_reaction.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/post_service.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostRepository(apiClient);
});

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(ref.watch(postRepositoryProvider));
});

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final PostService _postService;
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _initialized = false;

  FeedNotifier(this._postService) : super(const FeedState());

  Future<void> loadInitial() async {
    if (_initialized) return;
    _initialized = true;
    await refresh(isInitial: true);
  }

  Future<void> refresh({bool isInitial = false}) async {
    state = state.copyWith(
      isLoading: isInitial,
      isRefreshing: !isInitial,
      clearError: true,
    );
    try {
      _currentPage = 0;
      final page = await _postService.getFeed(page: _currentPage, size: _pageSize);
      _currentPage += 1;
      state = state.copyWith(
        posts: page.content,
        isLoading: false,
        isRefreshing: false,
        hasMore: page.hasNextPage,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page =
          await _postService.getFeed(page: _currentPage, size: _pageSize);
      _currentPage += 1;
      state = state.copyWith(
        posts: [...state.posts, ...page.content],
        isLoadingMore: false,
        hasMore: page.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createPost(
    CreatePostRequest request, {
    List<XFile>? mediaFiles,
  }) async {
    final newPost =
        await _postService.createPost(request, mediaFiles: mediaFiles);
    state = state.copyWith(posts: [newPost, ...state.posts]);
  }

  Future<void> deletePost(String postId) async {
    await _postService.deletePost(postId);
    state = state.copyWith(
      posts: state.posts.where((post) => post.id != postId).toList(),
    );
  }

  Future<PostReaction> toggleReaction(String postId, bool isLiked) async {
    final reaction = isLiked
        ? await _postService.unlikePost(postId)
        : await _postService.likePost(postId);
    _applyReaction(reaction);
    return reaction;
  }

  void applyReactionSnapshot(PostReaction reaction) {
    _applyReaction(reaction);
  }

  void applyCommentDelta(String postId, int delta) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        final nextCount = post.commentCount + delta;
        return post.copyWith(
          commentCount: nextCount < 0 ? 0 : nextCount,
        );
      }).toList(),
    );
  }

  void _applyReaction(PostReaction reaction) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != reaction.postId) return post;
        return post.copyWith(
          likeCount: reaction.likeCount,
          likedByCurrentUser: reaction.likedByCurrentUser,
        );
      }).toList(),
    );
  }
}

final postFeedProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final service = ref.watch(postServiceProvider);
  return FeedNotifier(service);
});

class UserPostsState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool initialized;

  const UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.initialized = false,
  });

  UserPostsState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool? initialized,
    bool clearError = false,
  }) {
    return UserPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      initialized: initialized ?? this.initialized,
    );
  }
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {
  UserPostsNotifier(this._postService, this.userId)
      : super(const UserPostsState());

  final PostService _postService;
  final String userId;
  int _currentPage = 0;
  static const int _pageSize = 9;

  Future<void> loadInitial() async {
    if (state.initialized && state.posts.isNotEmpty) return;
    await _load(reset: true);
  }

  Future<void> refresh() async {
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    await _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!reset && !state.hasMore) return;

    if (reset) {
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        clearError: true,
      );
      _currentPage = 0;
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    try {
      final page = await _postService.getPostsByUser(
        userId,
        page: _currentPage,
        size: _pageSize,
      );
      _currentPage += 1;
      final posts =
          reset ? page.content : [...state.posts, ...page.content];
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        isLoadingMore: false,
        hasMore: page.hasNextPage,
        initialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deletePost(String postId) async {
    state = state.copyWith(clearError: true);
    try {
      await _postService.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((post) => post.id != postId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<PostReaction> toggleReaction(String postId, bool isLiked) async {
    final reaction = isLiked
        ? await _postService.unlikePost(postId)
        : await _postService.likePost(postId);
    _applyReaction(reaction);
    return reaction;
  }

  void applyReactionSnapshot(PostReaction reaction) {
    _applyReaction(reaction);
  }

  void applyCommentDelta(String postId, int delta) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        final nextCount = post.commentCount + delta;
        return post.copyWith(
          commentCount: nextCount < 0 ? 0 : nextCount,
        );
      }).toList(),
    );
  }

  void _applyReaction(PostReaction reaction) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != reaction.postId) return post;
        return post.copyWith(
          likeCount: reaction.likeCount,
          likedByCurrentUser: reaction.likedByCurrentUser,
        );
      }).toList(),
    );
  }
}

final userPostsProvider = StateNotifierProvider.family<UserPostsNotifier,
    UserPostsState, String>((ref, userId) {
  final service = ref.watch(postServiceProvider);
  return UserPostsNotifier(service, userId);
});

