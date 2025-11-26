import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/page_response.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/post_model.dart';
import '../../data/models/post_reaction.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/post_service.dart';

final reelsRepositoryProvider = Provider<PostRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostRepository(apiClient);
});

final reelsServiceProvider = Provider<PostService>((ref) {
  return PostService(ref.watch(reelsRepositoryProvider));
});

class ReelsState {
  final List<PostModel> videos;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ReelsState({
    this.videos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ReelsState copyWith({
    List<PostModel>? videos,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ReelsState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReelsNotifier extends StateNotifier<ReelsState> {
  ReelsNotifier(this._service) : super(const ReelsState());

  final PostService _service;
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _initialized = false;

  Future<void> loadInitial() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
    );
    try {
      _currentPage = 0;
      final page = await _service.getFeed(page: _currentPage, size: _pageSize);
      _currentPage += 1;
      
      // Lọc chỉ lấy posts có video
      final videoPosts = page.content.where((post) {
        return post.media.any((media) => media.isVideo);
      }).toList();
      
      state = state.copyWith(
        videos: videoPosts,
        isLoading: false,
        hasMore: page.hasNextPage,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await _service.getFeed(page: _currentPage, size: _pageSize);
      _currentPage += 1;
      
      // Lọc chỉ lấy posts có video
      final videoPosts = page.content.where((post) {
        return post.media.any((media) => media.isVideo);
      }).toList();
      
      state = state.copyWith(
        videos: [...state.videos, ...videoPosts],
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

  Future<void> toggleReaction(String postId, bool isLiked) async {
    try {
      final reaction = isLiked
          ? await _service.unlikePost(postId)
          : await _service.likePost(postId);
      _applyReaction(reaction);
    } catch (e) {
      // Silent fail
    }
  }

  void _applyReaction(PostReaction reaction) {
    state = state.copyWith(
      videos: state.videos.map((post) {
        if (post.id != reaction.postId) return post;
        return post.copyWith(
          likeCount: reaction.likeCount,
          likedByCurrentUser: reaction.likedByCurrentUser,
        );
      }).toList(),
    );
  }

  void applyCommentDelta(String postId, int delta) {
    state = state.copyWith(
      videos: state.videos.map((post) {
        if (post.id != postId) return post;
        final nextCount = post.commentCount + delta;
        return post.copyWith(
          commentCount: nextCount < 0 ? 0 : nextCount,
        );
      }).toList(),
    );
  }
}

final reelsProvider =
    StateNotifierProvider<ReelsNotifier, ReelsState>((ref) {
  final service = ref.watch(reelsServiceProvider);
  return ReelsNotifier(service);
});

