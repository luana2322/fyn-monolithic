import '../../../../core/network/api_client.dart';
import '../models/meetup_model.dart';

/// Repository for meetup operations
class MeetupRepository {
  final ApiClient _apiClient;

  MeetupRepository(this._apiClient);

  /// Create a new meetup
  Future<MeetupModel> createMeetup({
    required String title,
    String? description,
    required String category,
    String? location,
    double? latitude,
    double? longitude,
    required DateTime scheduledAt,
    int maxParticipants = 10,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/meetups',
        data: {
          'title': title,
          if (description != null) 'description': description,
          'category': category,
          if (location != null) 'location': location,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'scheduledAt': scheduledAt.toIso8601String(),
          'maxParticipants': maxParticipants,
        },
      );
      return MeetupModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to create meetup: $e');
    }
  }

  /// Get list of meetups
  Future<List<MeetupModel>> getMeetups({
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (category != null && category.isNotEmpty) 'category': category,
      };
      final response = await _apiClient.get(
        '/api/v1/meetups',
        queryParameters: queryParams,
      );
      final data = response.data;
      final List<dynamic> content = data['data']?['content'] ?? data['content'] ?? [];
      return content.map((json) => MeetupModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load meetups: $e');
    }
  }

  /// Get meetup details
  Future<MeetupModel> getMeetupDetails(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/meetups/$id');
      return MeetupModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to load meetup details: $e');
    }
  }

  /// Join a meetup
  Future<void> joinMeetup(String id) async {
    try {
      await _apiClient.post('/api/v1/meetups/$id/join');
    } catch (e) {
      throw Exception('Failed to join meetup: $e');
    }
  }

  /// Leave a meetup
  Future<void> leaveMeetup(String id) async {
    try {
      await _apiClient.delete('/api/v1/meetups/$id/leave');
    } catch (e) {
      throw Exception('Failed to leave meetup: $e');
    }
  }

  /// Cancel a meetup (organizer only)
  Future<void> cancelMeetup(String id) async {
    try {
      await _apiClient.delete('/api/v1/meetups/$id');
    } catch (e) {
      throw Exception('Failed to cancel meetup: $e');
    }
  }
}
