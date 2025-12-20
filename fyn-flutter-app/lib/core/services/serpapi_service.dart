import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for SerpAPI place search via backend proxy
/// Avoids CORS issues by routing through backend
class SerpApiService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  /// Search for places using backend proxy
  Future<List<PlaceSearchResult>> searchPlaces(String query, {String? location}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/locations/search').replace(queryParameters: {
        'query': query,
        if (location != null) 'location': location,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serpData = data['data'] as Map<String, dynamic>;
        final results = serpData['local_results'] as List<dynamic>? ?? [];
        
        return results.map((item) => PlaceSearchResult.fromJson(item)).toList();
      } else {
        throw Exception('Backend proxy error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }
  }
}

/// Model for place search result from SerpAPI
class PlaceSearchResult {
  final String title;
  final String? address;
  final double? rating;
  final int? reviews;
  final double? latitude;
  final double? longitude;
  final String? type;
  final String? thumbnail;

  PlaceSearchResult({
    required this.title,
    this.address,
    this.rating,
    this.reviews,
    this.latitude,
    this.longitude,
    this.type,
    this.thumbnail,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    final gps = json['gps_coordinates'] as Map<String, dynamic>?;
    
    return PlaceSearchResult(
      title: json['title'] as String,
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: json['reviews'] as int?,
      latitude: (gps?['latitude'] as num?)?.toDouble(),
      longitude: (gps?['longitude'] as num?)?.toDouble(),
      type: json['type'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}
