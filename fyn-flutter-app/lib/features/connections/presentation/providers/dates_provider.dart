import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/models/date_model.dart';
import '../../data/models/meetup_model.dart';
import '../../data/repositories/date_repository.dart';

// Repository provider
final dateRepositoryProvider = Provider<DateRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DateRepository(apiClient);
});

/// State for public dates browsing
class PublicDatesState {
  final List<DateModel> dates;
  final bool isLoading;
  final String? error;
  final String? placeTypeFilter;
  final ConnectionType? connectionTypeFilter;

  const PublicDatesState({
    this.dates = const [],
    this.isLoading = false,
    this.error,
    this.placeTypeFilter,
    this.connectionTypeFilter,
  });

  PublicDatesState copyWith({
    List<DateModel>? dates,
    bool? isLoading,
    String? error,
    String? placeTypeFilter,
    ConnectionType? connectionTypeFilter,
    bool clearError = false,
  }) {
    return PublicDatesState(
      dates: dates ?? this.dates,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      placeTypeFilter: placeTypeFilter ?? this.placeTypeFilter,
      connectionTypeFilter: connectionTypeFilter ?? this.connectionTypeFilter,
    );
  }
}

/// Notifier for public dates
class PublicDatesNotifier extends StateNotifier<PublicDatesState> {
  final DateRepository _repository;

  PublicDatesNotifier(this._repository) : super(const PublicDatesState());

  /// Load public dates
  Future<void> loadDates({
    String? placeType,
    ConnectionType? connectionType,
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      placeTypeFilter: placeType,
      connectionTypeFilter: connectionType,
    );
    try {
      final dates = await _repository.getPublicDates(
        placeType: placeType,
        connectionType: connectionType?.value,
        lat: lat,
        lng: lng,
      );
      state = state.copyWith(
        dates: dates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh dates
  Future<void> refresh() => loadDates(
    placeType: state.placeTypeFilter,
    connectionType: state.connectionTypeFilter,
  );
}

// Provider for public dates
final publicDatesProvider = StateNotifierProvider<PublicDatesNotifier, PublicDatesState>((ref) {
  final repository = ref.watch(dateRepositoryProvider);
  return PublicDatesNotifier(repository);
});

/// State for user's own dates
class MyDatesState {
  final List<DateModel> dates;
  final bool isLoading;
  final String? error;

  const MyDatesState({
    this.dates = const [],
    this.isLoading = false,
    this.error,
  });

  MyDatesState copyWith({
    List<DateModel>? dates,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MyDatesState(
      dates: dates ?? this.dates,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for user's dates
class MyDatesNotifier extends StateNotifier<MyDatesState> {
  final DateRepository _repository;

  MyDatesNotifier(this._repository) : super(const MyDatesState());

  /// Load user's dates
  Future<void> loadDates({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dates = await _repository.getMyDates(status: status);
      state = state.copyWith(dates: dates, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new date
  Future<DateModel?> createDate(Map<String, dynamic> data) async {
    try {
      final date = await _repository.createDate(data);
      state = state.copyWith(dates: [date, ...state.dates]);
      return date;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Cancel a date
  Future<void> cancelDate(String id) async {
    try {
      await _repository.cancelDate(id);
      state = state.copyWith(
        dates: state.dates.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider for user's dates
final myDatesProvider = StateNotifierProvider<MyDatesNotifier, MyDatesState>((ref) {
  final repository = ref.watch(dateRepositoryProvider);
  return MyDatesNotifier(repository);
});

/// State for proposals
class ProposalsState {
  final List<ProposalModel> proposals;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ProposalsState({
    this.proposals = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ProposalsState copyWith({
    List<ProposalModel>? proposals,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ProposalsState(
      proposals: proposals ?? this.proposals,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for proposals
class ProposalsNotifier extends StateNotifier<ProposalsState> {
  final DateRepository _repository;
  final String dateId;

  ProposalsNotifier(this._repository, this.dateId) : super(const ProposalsState());

  /// Load proposals for a date
  Future<void> loadProposals() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final proposals = await _repository.getProposals(dateId);
      state = state.copyWith(proposals: proposals, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send a proposal
  Future<bool> sendProposal({String? message, DateTime? proposedTime}) async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      await _repository.sendProposal(
        dateId: dateId,
        message: message,
        proposedTime: proposedTime,
      );
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  /// Accept a proposal
  Future<void> acceptProposal(String proposalId) async {
    try {
      await _repository.acceptProposal(proposalId);
      await loadProposals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reject a proposal
  Future<void> rejectProposal(String proposalId) async {
    try {
      await _repository.rejectProposal(proposalId);
      state = state.copyWith(
        proposals: state.proposals.where((p) => p.id != proposalId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider for proposals (family provider for different dates)
final proposalsProvider = StateNotifierProvider.family<ProposalsNotifier, ProposalsState, String>((ref, dateId) {
  final repository = ref.watch(dateRepositoryProvider);
  return ProposalsNotifier(repository, dateId);
});
