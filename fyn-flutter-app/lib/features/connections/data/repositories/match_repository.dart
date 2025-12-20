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

  /// Undo the last swipe action
  Future<bool> undoSwipe() async {
    try {
      final response = await _apiClient.delete('/api/v1/matches/swipe/undo');
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      throw Exception('Failed to undo swipe: $e');
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

  /// Cancel a match
  Future<void> cancelMatch(String matchId) async {
    try {
      await _apiClient.patch('/api/v1/matches/$matchId/cancel');
    } catch (e) {
      throw Exception('Failed to cancel match: $e');
    }
  }

  /// Mark match as completed
  Future<void> completeMatch(String matchId) async {
    try {
      await _apiClient.patch('/api/v1/matches/$matchId/complete');
    } catch (e) {
      throw Exception('Failed to complete match: $e');
    }
  }

  /// Report no-show (applies penalty)
  Future<void> reportNoShow(String matchId) async {
    try {
      await _apiClient.patch('/api/v1/matches/$matchId/no-show');
    } catch (e) {
      throw Exception('Failed to report no-show: $e');
    }
  }

  // ==================== Simplified Dating Flow Methods ====================

  /// Create a date for a match (mandatory after matching)
  Future<void> createDateForMatch(String matchId, {
    required DateTime scheduledAt,
    required String description,
    required Map<String, dynamic> location,
  }) async {
    try {
      await _apiClient.post(
        '/api/v1/matches/$matchId/date',
        data: {
          'scheduledAt': scheduledAt.toIso8601String(),
          'description': description,
          'location': location,
        },
      );
    } catch (e) {
      throw Exception('Failed to create date: $e');
    }
  }

  /// Update location for an existing date
  Future<void> updateDateLocation(String matchId, Map<String, dynamic> location) async {
    try {
      await _apiClient.patch(
        '/api/v1/matches/$matchId/location',
        data: location,
      );
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Get match details with full date information
  Future<MatchModel> getMatchById(String matchId) async {
    try {
      final response = await _apiClient.get('/api/v1/matches/$matchId');
      return MatchModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load match details: $e');
    }
  }

  /// Submit post-date feedback (12-24h after date)
  Future<void> submitFeedback(String matchId, {
    required bool didMeet,
    String? noShowReason,
    String? rating,
    String? feedbackText,
  }) async {
    try {
      await _apiClient.post(
        '/api/v1/matches/$matchId/feedback',
        data: {
          'didMeet': didMeet,
          if (noShowReason != null) 'noShowReason': noShowReason,
          if (rating != null) 'rating': rating,
          if (feedbackText != null) 'feedbackText': feedbackText,
        },
      );
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
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
