import '../../../../core/network/api_client.dart';
import '../models/story_model.dart';

/// Repository for story operations
class StoryRepository {
  final ApiClient _apiClient;

  StoryRepository(this._apiClient);

  /// Get story feed (current user + followed users' stories)
  Future<StoryFeedModel> getStoryFeed() async {
    try {
      final response = await _apiClient.get('/api/v1/stories');
      final data = response.data;
      // Handle both direct response and wrapped response
      final feedData = data is Map && data.containsKey('data') 
          ? data['data'] 
          : data;
      return StoryFeedModel.fromJson(feedData ?? {});
    } catch (e) {
      throw Exception('Failed to load stories: $e');
    }
  }

  /// Create a new story
  Future<StoryModel> createStory({
    required String mediaUrl,
    String mediaType = 'IMAGE',
    String? textContent,
    String? backgroundColor,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/stories',
        data: {
          'mediaUrl': mediaUrl,
          'mediaType': mediaType,
          if (textContent != null) 'textContent': textContent,
          if (backgroundColor != null) 'backgroundColor': backgroundColor,
        },
      );
      return StoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }

  /// Get a single story
  Future<StoryModel> getStory(String storyId) async {
    try {
      final response = await _apiClient.get('/api/v1/stories/$storyId');
      return StoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load story: $e');
    }
  }

  /// Mark story as viewed
  Future<void> viewStory(String storyId) async {
    try {
      await _apiClient.post('/api/v1/stories/$storyId/view');
    } catch (e) {
      // Silently fail for view tracking
    }
  }

  /// Delete own story
  Future<void> deleteStory(String storyId) async {
    try {
      await _apiClient.delete('/api/v1/stories/$storyId');
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  /// Get story viewers (owner only)
  Future<List<StoryUserModel>> getStoryViewers(String storyId) async {
    try {
      final response = await _apiClient.get('/api/v1/stories/$storyId/viewers');
      final data = response.data as List? ?? [];
      return data.map((v) => StoryUserModel.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Failed to load viewers: $e');
    }
  }
}
