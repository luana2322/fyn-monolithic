import 'package:dio/dio.dart';
import '../models/meetup_model.dart';
import '../models/meetup_requests.dart';
import '../models/meetup_enums.dart';

class MeetupApiService {
  final Dio _dio;
  static const String _basePath = '/api/v1/meetups';

  MeetupApiService(this._dio);

  /// Create a new meetup
  Future<MeetupModel> createMeetup(CreateMeetupRequest request) async {
    final response = await _dio.post(
      _basePath,
      data: request.toJson(),
    );
    return MeetupModel.fromJson(response.data['data']);
  }

  /// Get a single meetup by ID
  Future<MeetupModel> getMeetup(String id) async {
    final response = await _dio.get('$_basePath/$id');
    return MeetupModel.fromJson(response.data['data']);
  }

  /// Discover nearby meetups
  Future<List<MeetupModel>> discoverMeetups({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    MeetType? meetType,
    String? category,
    DateTime? afterDate,
    String? sortBy,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '$_basePath/discover',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'radiusKm': radiusKm,
        if (meetType != null) 'meetType': meetType.value,
        if (category != null) 'category': category,
        if (afterDate != null) 'afterDate': afterDate.toIso8601String(),
        if (sortBy != null) 'sortBy': sortBy,
        'page': page,
        'size': size,
      },
    );
    
    final List<dynamic> content = response.data['data']['content'];
    return content.map((json) => MeetupModel.fromJson(json)).toList();
  }

  /// Get user's own meetups (organized by current user)
  Future<List<MeetupModel>> getMyMeetups({
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      _basePath,
      queryParameters: {
        if (category != null) 'category': category,
        'page': page,
        'size': size,
      },
    );
    
    final List<dynamic> content = response.data['data']['content'];
    return content.map((json) => MeetupModel.fromJson(json)).toList();
  }

  /// Apply/match to a meetup
  Future<MeetupMatchModel> applyToMeetup(
    String meetupId,
    ApplyToMeetupRequest request,
  ) async {
    final response = await _dio.post(
      '$_basePath/$meetupId/match',
      data: request.toJson(),
    );
    return MeetupMatchModel.fromJson(response.data['data']);
  }

  /// Get match requests for a meetup (organizer)
  Future<List<MeetupMatchModel>> getMatchRequests(
    String meetupId, {
    MatchStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '$_basePath/$meetupId/matches',
      queryParameters: {
        if (status != null) 'status': status.value,
        'page': page,
        'size': size,
      },
    );
    
    final List<dynamic> content = response.data['data']['content'];
    return content.map((json) => MeetupMatchModel.fromJson(json)).toList();
  }

  /// Get meetups the current user has applied to
  Future<List<MeetupMatchModel>> getMyAppliedMeetups({
    MatchStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '$_basePath/my-applied',
      queryParameters: {
        if (status != null) 'status': status.value,
        'page': page,
        'size': size,
      },
    );
    
    final List<dynamic> content = response.data['data']['content'];
    return content.map((json) => MeetupMatchModel.fromJson(json)).toList();
  }

  /// Accept a match request
  Future<void> acceptMatch(String matchId) async {
    await _dio.post('$_basePath/matches/$matchId/accept');
  }

  /// Reject a match request
  Future<void> rejectMatch(String matchId) async {
    await _dio.post('$_basePath/matches/$matchId/reject');
  }

  /// Initiate chat for a match request without accepting it
  Future<MeetupMatchModel> initiateMatchChat(String matchId) async {
    final response = await _dio.post('$_basePath/matches/$matchId/chat');
    return MeetupMatchModel.fromJson(response.data['data']);
  }

  /// Confirm meetup completion
  Future<void> confirmMeetup(
    String meetupId,
    ConfirmMeetupRequest request,
  ) async {
    await _dio.post(
      '$_basePath/$meetupId/confirm',
      data: request.toJson(),
    );
  }

  /// Update an existing meetup
  Future<MeetupModel> updateMeetup(String id, UpdateMeetupRequest request) async {
    final response = await _dio.put(
      '$_basePath/$id',
      data: request.toJson(),
    );
    return MeetupModel.fromJson(response.data['data']);
  }

  /// Cancel meetup
  Future<void> cancelMeetup(String meetupId) async {
    await _dio.delete('$_basePath/$meetupId');
  }
}
