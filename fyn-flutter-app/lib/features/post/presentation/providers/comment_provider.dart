import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/create_comment_request.dart';
import '../../domain/post_service.dart';
import 'post_provider.dart';

class CommentState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  CommentState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CommentProviderArgs {
  final String postId;
  final String ownerId;

  const CommentProviderArgs({
    required this.postId,
    required this.ownerId,
  });
}

class CommentNotifier extends StateNotifier<CommentState> {
  CommentNotifier(this._ref, this._postId, this._ownerId)
      : super(const CommentState());

  final Ref _ref;
  final String _postId;
  final String _ownerId;

  PostService get _service => _ref.read(postServiceProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _service.getComments(_postId);
      state = state.copyWith(comments: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final comment = await _service.addComment(
        _postId,
        CreateCommentRequest(content: content.trim()),
      );
      state = state.copyWith(
        comments: [...state.comments, comment],
        isSubmitting: false,
      );
      _broadcastCommentDelta(1);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    state = state.copyWith(clearError: true);
    try {
      await _service.deleteComment(_postId, commentId);
      state = state.copyWith(
        comments: state.comments
            .where((comment) => comment.id != commentId)
            .toList(),
      );
      _broadcastCommentDelta(-1);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _broadcastCommentDelta(int delta) {
    _ref.read(postFeedProvider.notifier).applyCommentDelta(_postId, delta);
    _ref
        .read(userPostsProvider(_ownerId).notifier)
        .applyCommentDelta(_postId, delta);
  }
}

final postCommentsProvider = StateNotifierProvider.family<
    CommentNotifier,
    CommentState,
    CommentProviderArgs>((ref, args) {
  return CommentNotifier(ref, args.postId, args.ownerId);
});





