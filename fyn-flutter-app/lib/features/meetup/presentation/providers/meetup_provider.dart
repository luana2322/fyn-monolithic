import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_requests.dart';
import '../../data/models/meetup_enums.dart';
import '../../data/repositories/meetup_repository.dart';

/// Provider for MeetupRepository
final meetupRepositoryProvider = Provider<MeetupRepository>((ref) {
  throw UnimplementedError('MeetupRepository must be overridden');
});

/// State notifier for discovered meetups
class DiscoveredMeetupsNotifier extends StateNotifier<AsyncValue<List<MeetupModel>>> {
  final MeetupRepository _repository;

  DiscoveredMeetupsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> discoverMeetups({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    MeetType? meetType,
    String? category,
    String? sortBy,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.discoverMeetups(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      meetType: meetType,
      category: category,
      sortBy: sortBy,
    ));
  }

  void refresh() {
    state = const AsyncValue.loading();
  }
}

final discoveredMeetupsProvider =
    StateNotifierProvider<DiscoveredMeetupsNotifier, AsyncValue<List<MeetupModel>>>((ref) {
  final repository = ref.watch(meetupRepositoryProvider);
  return DiscoveredMeetupsNotifier(repository);
});

/// State notifier for user's own meetups
class MyMeetupsNotifier extends StateNotifier<AsyncValue<List<MeetupModel>>> {
  final MeetupRepository _repository;

  MyMeetupsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadMyMeetups({String? category}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMyMeetups(
      category: category,
    ));
  }

  void refresh() {
    state = const AsyncValue.loading();
  }
}

final myMeetupsProvider =
    StateNotifierProvider<MyMeetupsNotifier, AsyncValue<List<MeetupModel>>>((ref) {
  final repository = ref.watch(meetupRepositoryProvider);
  return MyMeetupsNotifier(repository);
});

/// State notifier for user's applied meetups
class AppliedMeetupsNotifier extends StateNotifier<AsyncValue<List<MeetupMatchModel>>> {
  final MeetupRepository _repository;

  AppliedMeetupsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadAppliedMeetups({MatchStatus? status}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMyAppliedMeetups(
      status: status,
    ));
  }

  void refresh() {
    state = const AsyncValue.loading();
  }
}

final appliedMeetupsProvider =
    StateNotifierProvider<AppliedMeetupsNotifier, AsyncValue<List<MeetupMatchModel>>>((ref) {
  final repository = ref.watch(meetupRepositoryProvider);
  return AppliedMeetupsNotifier(repository);
});

/// State notifier for match requests (organizer view)
class MatchRequestsNotifier extends StateNotifier<AsyncValue<List<MeetupMatchModel>>> {
  final MeetupRepository _repository;

  MatchRequestsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadMatchRequests(String meetupId, {MatchStatus? status}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        _repository.getMatchRequests(meetupId, status: status));
  }

  Future<void> acceptMatch(String matchId) async {
    await _repository.acceptMatch(matchId);
    // Reload after accepting
    if (state.value != null && state.value!.isNotEmpty) {
      final meetupId = state.value!.first.meetupId;
      await loadMatchRequests(meetupId);
    }
  }

  Future<void> rejectMatch(String matchId) async {
    await _repository.rejectMatch(matchId);
    // Reload after rejecting
    if (state.value != null && state.value!.isNotEmpty) {
      final meetupId = state.value!.first.meetupId;
      await loadMatchRequests(meetupId);
    }
  }

  Future<MeetupMatchModel> initiateChat(String matchId) async {
    final updated = await _repository.initiateMatchChat(matchId);
    // Reload after initiating chat
    if (state.value != null && state.value!.isNotEmpty) {
      final meetupId = state.value!.first.meetupId;
      await loadMatchRequests(meetupId);
    }
    return updated;
  }
}

final matchRequestsProvider =
    StateNotifierProvider<MatchRequestsNotifier, AsyncValue<List<MeetupMatchModel>>>((ref) {
  final repository = ref.watch(meetupRepositoryProvider);
  return MatchRequestsNotifier(repository);
});

/// Provider for creating a meetup
final createMeetupProvider = FutureProvider.family<MeetupModel, CreateMeetupRequest>(
  (ref, request) {
    final repository = ref.watch(meetupRepositoryProvider);
    return repository.createMeetup(request);
  },
);

/// Provider for getting a single meetup
final meetupDetailProvider = FutureProvider.family<MeetupModel, String>(
  (ref, id) {
    final repository = ref.watch(meetupRepositoryProvider);
    return repository.getMeetup(id);
  },
);

/// Provider for updating a meetup
final updateMeetupProvider = FutureProvider.family<MeetupModel, ({String id, UpdateMeetupRequest request})>(
  (ref, params) {
    final repository = ref.watch(meetupRepositoryProvider);
    return repository.updateMeetup(params.id, params.request);
  },
);

/// Provider for applying to a meetup
final applyToMeetupProvider = FutureProvider.family<MeetupMatchModel, ({String meetupId, String? message})>(
  (ref, params) {
    final repository = ref.watch(meetupRepositoryProvider);
    return repository.applyToMeetup(params.meetupId, params.message);
  },
);

/// Notifier for managing applicants of a specific meetup
class ApplicantsNotifier extends StateNotifier<AsyncValue<List<MeetupMatchModel>>> {
  final MeetupRepository _repository;
  final String meetupId;

  ApplicantsNotifier(this._repository, this.meetupId) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMatchRequests(meetupId));
  }

  Future<void> accept(String matchId) async {
    await _repository.acceptMatch(matchId);
    await load();
  }

  Future<void> reject(String matchId) async {
    await _repository.rejectMatch(matchId);
    await load();
  }

  Future<MeetupMatchModel> initiateChat(String matchId) async {
    final updated = await _repository.initiateMatchChat(matchId);
    await load();
    return updated;
  }
}

/// Family provider for applicants per meetup
final applicantsProvider = StateNotifierProvider.family<ApplicantsNotifier, AsyncValue<List<MeetupMatchModel>>, String>(
  (ref, meetupId) {
    final repository = ref.watch(meetupRepositoryProvider);
    return ApplicantsNotifier(repository, meetupId);
  },
);

/// Provider for confirming a meetup
final confirmMeetupProvider = FutureProvider.family<void, ({String meetupId, String result, String? feedback, double? rating})>(
  (ref, params) {
    final repository = ref.watch(meetupRepositoryProvider);
    return repository.confirmMeetup(
      params.meetupId,
      params.result,
      feedback: params.feedback,
      rating: params.rating,
    );
  },
);

/// State notifier for meetup history
class MeetupHistoryNotifier extends StateNotifier<AsyncValue<List<MeetupModel>>> {
  final MeetupRepository _repository;

  MeetupHistoryNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getHistory());
  }

  void refresh() {
    state = const AsyncValue.loading();
  }
}

final meetupHistoryProvider =
    StateNotifierProvider<MeetupHistoryNotifier, AsyncValue<List<MeetupModel>>>((ref) {
  final repository = ref.watch(meetupRepositoryProvider);
  return MeetupHistoryNotifier(repository);
});

/// State notifier for meetups awaiting confirmation
class AwaitingConfirmationNotifier extends StateNotifier<AsyncValue<List<MeetupModel>>> {
  final MeetupRepository _repository;

  AwaitingConfirmationNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadAwaitingConfirmation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAwaitingConfirmation());
  }

  void refresh() {
    state = const AsyncValue.loading();
  }
}

final awaitingConfirmationProvider =
    StateNotifierProvider<AwaitingConfirmationNotifier, AsyncValue<List<MeetupModel>>>((ref) {
  final repository = ref.watch(meetupRepositoryProvider);
  return AwaitingConfirmationNotifier(repository);
});

