import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meetup_model.dart';
import '../../data/repositories/meetup_repository.dart';
import '../../../../core/network/dio_provider.dart';

// Provider for MeetupRepository
final meetupRepositoryProvider = Provider<MeetupRepository>((ref) {
  return MeetupRepository(ref.read(apiClientProvider));
});

// State for meetups screen
class MeetupsState {
  final List<MeetupModel> meetups;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  MeetupsState({
    this.meetups = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  MeetupsState copyWith({
    List<MeetupModel>? meetups,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return MeetupsState(
      meetups: meetups ?? this.meetups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// Notifier for managing meetups
class MeetupsNotifier extends StateNotifier<MeetupsState> {
  final MeetupRepository _repository;

  MeetupsNotifier(this._repository) : super(MeetupsState());

  Future<void> loadMeetups({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final meetups = await _repository.getMeetups(category: category);
      state = state.copyWith(
        meetups: meetups,
        isLoading: false,
        selectedCategory: category,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> joinMeetup(String id) async {
    try {
      await _repository.joinMeetup(id);
      await loadMeetups(category: state.selectedCategory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> leaveMeetup(String id) async {
    try {
      await _repository.leaveMeetup(id);
      await loadMeetups(category: state.selectedCategory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> cancelMeetup(String id) async {
    try {
      await _repository.cancelMeetup(id);
      await loadMeetups(category: state.selectedCategory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Provider for meetups state
final meetupsProvider = StateNotifierProvider<MeetupsNotifier, MeetupsState>((ref) {
  return MeetupsNotifier(ref.read(meetupRepositoryProvider));
});
