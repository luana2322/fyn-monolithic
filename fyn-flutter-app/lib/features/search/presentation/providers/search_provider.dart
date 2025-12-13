import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/data/models/user_response.dart';
import '../../data/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SearchRepository(apiClient);
});

class UserSearchState {
  final List<UserResponse> results;
  final bool isLoading;
  final String query;
  final String? error;

  UserSearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.error,
  });

  UserSearchState copyWith({
    List<UserResponse>? results,
    bool? isLoading,
    String? query,
    String? error,
  }) {
    return UserSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      error: error,
    );
  }
}

class UserSearchNotifier extends StateNotifier<UserSearchState> {
  UserSearchNotifier(this._repository) : super(UserSearchState());

  final SearchRepository _repository;

  Future<void> search(String query) async {
    final keyword = query.trim();
    state = state.copyWith(query: keyword, isLoading: true, error: null);

    if (keyword.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    try {
      final results = await _repository.searchUsers(keyword);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearResults() {
    state = state.copyWith(results: [], query: '', error: null);
  }
}

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, UserSearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return UserSearchNotifier(repository);
});

