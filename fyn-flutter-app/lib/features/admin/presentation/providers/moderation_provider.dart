import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/post_report_model.dart';
import '../../data/models/moderation_action_request.dart';
import '../../data/repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ModerationRepository(apiClient);
});

class ModerationState {
  final List<PostReportModel> reportedPosts;
  final bool isLoading;
  final String? error;

  const ModerationState({
    this.reportedPosts = const [],
    this.isLoading = false,
    this.error,
  });

  ModerationState copyWith({
    List<PostReportModel>? reportedPosts,
    bool? isLoading,
    String? error,
  }) {
    return ModerationState(
      reportedPosts: reportedPosts ?? this.reportedPosts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ModerationNotifier extends StateNotifier<ModerationState> {
  final ModerationRepository _repository;

  ModerationNotifier(this._repository) : super(const ModerationState());

  Future<void> loadReportedPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await _repository.getReportedPosts();
      state = state.copyWith(reportedPosts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> hidePost(String postId, String reason) async {
    try {
      await _repository.hidePost(postId, ModerationActionRequest(reason: reason));
      await loadReportedPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePost(String postId, String reason) async {
    try {
      await _repository.deletePost(postId, ModerationActionRequest(reason: reason));
      await loadReportedPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> restorePost(String postId) async {
    try {
      await _repository.restorePost(postId, ModerationActionRequest());
      await loadReportedPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> markReportValid(String reportId, String? comment) async {
    try {
      await _repository.markReportValid(reportId, ModerationActionRequest(adminComment: comment));
      await loadReportedPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> markReportInvalid(String reportId, String? comment) async {
    try {
      await _repository.markReportInvalid(reportId, ModerationActionRequest(adminComment: comment));
      await loadReportedPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final moderationProvider = StateNotifierProvider<ModerationNotifier, ModerationState>((ref) {
  final repository = ref.watch(moderationRepositoryProvider);
  return ModerationNotifier(repository);
});
