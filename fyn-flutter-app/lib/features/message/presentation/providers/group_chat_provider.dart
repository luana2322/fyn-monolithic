import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/group_chat_repository.dart';

/// Provider for GroupChatRepository
final groupChatRepositoryProvider = Provider<GroupChatRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return GroupChatRepository(apiClient);
});

/// State for group chat creation
class CreateGroupState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CreateGroupState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CreateGroupState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CreateGroupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Notifier for creating group chats
class CreateGroupNotifier extends StateNotifier<CreateGroupState> {
  final GroupChatRepository _repository;

  CreateGroupNotifier(this._repository) : super(CreateGroupState());

  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _repository.createFriendsGroup(
        name: name,
        memberIds: memberIds,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = CreateGroupState();
  }
}

/// Provider for CreateGroupNotifier
final createGroupProvider =
    StateNotifierProvider<CreateGroupNotifier, CreateGroupState>((ref) {
  final repository = ref.read(groupChatRepositoryProvider);
  return CreateGroupNotifier(repository);
});
