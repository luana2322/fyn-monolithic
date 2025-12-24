import '../models/meetup_model.dart';
import '../models/meetup_requests.dart';
import '../models/meetup_enums.dart';
import '../services/meetup_api_service.dart';

class MeetupRepository {
  final MeetupApiService _apiService;

  MeetupRepository(this._apiService);

  Future<MeetupModel> createMeetup(CreateMeetupRequest request) {
    return _apiService.createMeetup(request);
  }

  Future<MeetupModel> getMeetup(String id) {
    return _apiService.getMeetup(id);
  }

  Future<List<MeetupModel>> discoverMeetups({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    MeetType? meetType,
    String? category,
    DateTime? afterDate,
    String? sortBy,
    int page = 0,
  }) {
    return _apiService.discoverMeetups(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      meetType: meetType,
      category: category,
      afterDate: afterDate,
      sortBy: sortBy,
      page: page,
    );
  }

  Future<List<MeetupModel>> getMyMeetups({
    String? category,
    int page = 0,
  }) {
    return _apiService.getMyMeetups(
      category: category,
      page: page,
    );
  }

  Future<MeetupMatchModel> applyToMeetup(
    String meetupId,
    String? message,
  ) {
    return _apiService.applyToMeetup(
      meetupId,
      ApplyToMeetupRequest(message: message),
    );
  }

  Future<List<MeetupMatchModel>> getMatchRequests(
    String meetupId, {
    MatchStatus? status,
  }) {
    return _apiService.getMatchRequests(meetupId, status: status);
  }

  Future<List<MeetupMatchModel>> getMyAppliedMeetups({
    MatchStatus? status,
  }) {
    return _apiService.getMyAppliedMeetups(status: status);
  }

  Future<void> acceptMatch(String matchId) {
    return _apiService.acceptMatch(matchId);
  }

  Future<void> rejectMatch(String matchId) {
    return _apiService.rejectMatch(matchId);
  }

  Future<MeetupMatchModel> initiateMatchChat(String matchId) {
    return _apiService.initiateMatchChat(matchId);
  }

  Future<void> confirmMeetup(String id, String result, {String? feedback, double? rating}) {
    return _apiService.confirmMeetup(
      id,
      ConfirmMeetupRequest(result: result, feedback: feedback, rating: rating),
    );
  }

  Future<MeetupModel> updateMeetup(String id, UpdateMeetupRequest request) {
    return _apiService.updateMeetup(id, request);
  }

  Future<void> cancelMeetup(String meetupId) {
    return _apiService.cancelMeetup(meetupId);
  }

  Future<List<MeetupModel>> getHistory({int page = 0}) {
    return _apiService.getHistory(page: page);
  }

  Future<List<MeetupModel>> getAwaitingConfirmation({int page = 0}) {
    return _apiService.getAwaitingConfirmation(page: page);
  }
}
