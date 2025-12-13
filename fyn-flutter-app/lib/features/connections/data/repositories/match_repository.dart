import '../../../../core/network/api_client.dart';
import '../models/match_model.dart';

/// Repository for match/discover operations
class MatchRepository {
  final ApiClient _apiClient;

  MatchRepository(this._apiClient);

  /// Get potential matches for swiping
  Future<List<MatchModel>> getDiscoverMatches({
    String? connectionType,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (connectionType != null) 'type': connectionType,
      };
      final response = await _apiClient.get(
        '/api/v1/matches/discover',
        queryParameters: queryParams,
      );
      final data = response.data;
      final List<dynamic> content = data['data']?['content'] ?? data['content'] ?? [];
      return content.map((json) => MatchModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }

  /// Swipe on a user (like/dislike/superlike)
  Future<SwipeResult> swipe({
    required String targetUserId,
    required String swipeType, // LIKE, DISLIKE, SUPERLIKE
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matches/swipe',
        data: {
          'targetUserId': targetUserId,
          'swipeType': swipeType,
        },
      );
      return SwipeResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to swipe: $e');
    }
  }

  /// Get current user's matches
  Future<List<MatchModel>> getMatches({
    String? connectionType,
    String? status, // matched, liked, pending
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (connectionType != null) 'type': connectionType,
        if (status != null) 'status': status,
      };
      final response = await _apiClient.get(
        '/api/v1/matches',
        queryParameters: queryParams,
      );
      final data = response.data;
      final List<dynamic> content = data['data']?['content'] ?? data['content'] ?? [];
      return content.map((json) => MatchModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }

  /// Block a match
  Future<void> blockMatch(String matchId) async {
    try {
      await _apiClient.patch('/api/v1/matches/$matchId/block');
    } catch (e) {
      throw Exception('Failed to block match: $e');
    }
  }
}

/// Result of a swipe action
class SwipeResult {
  final bool success;
  final bool isMatch;
  final String? conversationId;

  SwipeResult({
    required this.success,
    this.isMatch = false,
    this.conversationId,
  });

  factory SwipeResult.fromJson(Map<String, dynamic> json) {
    return SwipeResult(
      success: json['success'] ?? true,
      isMatch: json['isMatch'] ?? json['matched'] ?? false,
      conversationId: json['conversationId'],
    );
  }
}
