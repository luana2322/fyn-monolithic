import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/attendance_repository.dart';

/// Provider for AttendanceRepository
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AttendanceRepository(apiClient);
});

/// State for attendance confirmation
class AttendanceState {
  final bool isLoading;
  final String? error;
  final AttendanceResult? result;

  AttendanceState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  AttendanceState copyWith({
    bool? isLoading,
    String? error,
    AttendanceResult? result,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

/// Notifier for attendance confirmation
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(AttendanceState());

  Future<bool> confirmAttendance({
    required String meetupId,
    required String status,
    String? feedback,
    double? rating,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.confirmAttendance(
        meetupId: meetupId,
        status: status,
        feedback: feedback,
        rating: rating,
      );
      state = state.copyWith(isLoading: false, result: result);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = AttendanceState();
  }
}

/// Provider for AttendanceNotifier (scoped by meetup ID)
final attendanceProvider = StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>(
  (ref, meetupId) {
    final repository = ref.read(attendanceRepositoryProvider);
    return AttendanceNotifier(repository);
  },
);
