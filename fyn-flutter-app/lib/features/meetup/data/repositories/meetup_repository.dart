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

  Future<void> acceptMatch(String matchId) {
    return _apiService.acceptMatch(matchId);
  }

  Future<void> rejectMatch(String matchId) {
    return _apiService.rejectMatch(matchId);
  }

  Future<void> confirmMeetup(String meetupId, String result) {
    return _apiService.confirmMeetup(
      meetupId,
      ConfirmMeetupRequest(result: result),
    );
  }

  Future<void> cancelMeetup(String meetupId) {
    return _apiService.cancelMeetup(meetupId);
  }
}
