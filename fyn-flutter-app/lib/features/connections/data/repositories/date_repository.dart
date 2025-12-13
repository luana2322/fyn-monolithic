import '../../../../core/network/api_client.dart';
import '../models/date_model.dart';
import '../models/match_model.dart';

/// Repository for date planning operations
class DateRepository {
  final ApiClient _apiClient;

  DateRepository(this._apiClient);

  /// Create a new date plan
  Future<DateModel> createDate(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/api/v1/dates', data: data);
      return DateModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to create date: $e');
    }
  }

  /// Get user's dates
  Future<List<DateModel>> getMyDates({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (status != null) 'status': status,
      };
      final response = await _apiClient.get(
        '/api/v1/dates',
        queryParameters: queryParams,
      );
      final data = response.data;
      final List<dynamic> content = data['data']?['content'] ?? data['content'] ?? [];
      return content.map((json) => DateModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load dates: $e');
    }
  }

  /// Get public dates for browsing
  Future<List<DateModel>> getPublicDates({
    String? placeType,
    String? connectionType,
    double? lat,
    double? lng,
    double? radiusKm,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (placeType != null) 'placeType': placeType,
        if (connectionType != null) 'type': connectionType,
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        if (radiusKm != null) 'radius': radiusKm.toString(),
      };
      final response = await _apiClient.get(
        '/api/v1/dates/public',
        queryParameters: queryParams,
      );
      final data = response.data;
      final List<dynamic> content = data['data']?['content'] ?? data['content'] ?? [];
      return content.map((json) => DateModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load public dates: $e');
    }
  }

  /// Get date details
  Future<DateModel> getDateDetails(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/dates/$id');
      return DateModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to load date details: $e');
    }
  }

  /// Cancel a date
  Future<void> cancelDate(String id) async {
    try {
      await _apiClient.delete('/api/v1/dates/$id');
    } catch (e) {
      throw Exception('Failed to cancel date: $e');
    }
  }

  /// Mark date as completed
  Future<void> completeDate(String id) async {
    try {
      await _apiClient.patch('/api/v1/dates/$id/complete');
    } catch (e) {
      throw Exception('Failed to complete date: $e');
    }
  }

  /// Send a proposal to a date
  Future<ProposalModel> sendProposal({
    required String dateId,
    String? message,
    DateTime? proposedTime,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/dates/$dateId/proposals',
        data: {
          'message': message,
          if (proposedTime != null) 'proposedTime': proposedTime.toIso8601String(),
        },
      );
      return ProposalModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to send proposal: $e');
    }
  }

  /// Get proposals for a date (owner only)
  Future<List<ProposalModel>> getProposals(String dateId) async {
    try {
      final response = await _apiClient.get('/api/v1/dates/$dateId/proposals');
      final data = response.data;
      final List<dynamic> content = data['data']?['content'] ?? data['content'] ?? data['data'] ?? [];
      return content.map((json) => ProposalModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load proposals: $e');
    }
  }

  /// Accept a proposal
  Future<void> acceptProposal(String proposalId) async {
    try {
      await _apiClient.patch('/api/v1/proposals/$proposalId/accept');
    } catch (e) {
      throw Exception('Failed to accept proposal: $e');
    }
  }

  /// Reject a proposal
  Future<void> rejectProposal(String proposalId) async {
    try {
      await _apiClient.patch('/api/v1/proposals/$proposalId/reject');
    } catch (e) {
      throw Exception('Failed to reject proposal: $e');
    }
  }
}
