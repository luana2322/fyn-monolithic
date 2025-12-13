import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart'; // We need to expose ApiClient via provider
import '../models/event_model.dart';

// Provider definition
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventRepository(apiClient);
});

class EventRepository {
  final ApiClient _apiClient;

  EventRepository(this._apiClient);

  Future<List<EventModel>> getEvents({
    double? lat,
    double? lng,
    double radius = 10000,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/events',
        queryParameters: {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          'radius': radius,
        },
      );
      
      // Handle Page response structure if backend returns Page<EventResponse>
      // Assuming structure: { "content": [...], "pageable": ... }
      final data = response.data;
      final List<dynamic> content = data['content'] ?? [];
      
      return content.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      // Error handling managed by interceptors or rethrow
      rethrow;
    }
  }

  Future<EventModel> getEvent(String id) async {
    final response = await _apiClient.get('/api/v1/events/$id');
    return EventModel.fromJson(response.data);
  }

  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    final response = await _apiClient.post('/api/v1/events', data: eventData);
    return EventModel.fromJson(response.data);
  }
}

