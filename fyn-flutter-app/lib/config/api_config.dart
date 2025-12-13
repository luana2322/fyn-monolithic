import 'app_config.dart';

/// API Endpoints constants
class ApiEndpoints {
  static final String baseUrl = AppConfig.baseUrl;
  
  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  
  // Password endpoints
  static const String changePassword = '/api/auth/password/change';
  static const String forgotPassword = '/api/auth/password/forgot';
  static const String verifyOtp = '/api/auth/password/verify-otp';
  
  // User endpoints
  static const String currentUser = '/api/users/me';
  static String userById(String userId) => '/api/users/$userId';
  static String userByUsername(String username) => '/api/users/username/$username';
  
  // Profile endpoints
  static const String updateProfile = '/api/users/profile';
  static const String changeAvatar = '/api/users/profile/avatar';
  
  // Follower endpoints
  static String follow(String userId) => '/api/users/$userId/follow';
  static String unfollow(String userId) => '/api/users/$userId/follow';
  static String followers(String userId) => '/api/users/$userId/followers';
  static String following(String userId) => '/api/users/$userId/following';
  
  // Post endpoints
  static const String createPost = '/api/posts';
  static const String feed = '/api/posts/feed';
  static String postsByUser(String userId) => '/api/posts/user/$userId';
  static String deletePost(String postId) => '/api/posts/$postId';
  
  // Like endpoints
  static String likePost(String postId) => '/api/posts/$postId/likes';
  static String unlikePost(String postId) => '/api/posts/$postId/likes';
  
  // Comment endpoints
  static String comments(String postId) => '/api/posts/$postId/comments';
  static String addComment(String postId) => '/api/posts/$postId/comments';
  static String deleteComment(String postId, String commentId) => 
      '/api/posts/$postId/comments/$commentId';
  
  // Conversation endpoints
  static const String conversations = '/api/conversations';
  static String conversationMessages(String conversationId) => 
      '/api/conversations/$conversationId/messages';
  static String sendMessage(String conversationId) => 
      '/api/conversations/$conversationId/messages';
  
  // Notification endpoints
  static const String notifications = '/api/notifications';
  static String markNotificationRead(String notificationId) => 
      '/api/notifications/$notificationId/read';
  static const String unreadNotificationCount = '/api/notifications/unread-count';
  
  // Search endpoints
  static const String searchHashtags = '/api/search/hashtags';
  static const String searchUsers = '/api/search/users';
  
  // Event endpoints (v1 API)
  static const String events = '/api/v1/events';
  static String eventById(String eventId) => '/api/v1/events/$eventId';
  
  // Matching endpoints (v1 API)
  static const String swipe = '/api/v1/matches/swipe';
}










