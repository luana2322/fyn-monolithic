import 'app_config.dart';

/// API Endpoints constants
class ApiEndpoints {
  static final String baseUrl = AppConfig.baseUrl;
  
  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String verifyAuthOtp = '/api/auth/verify';
  static const String sendAuthOtp = '/api/auth/send-otp';
  
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
  static const String searchUsers = '/api/v1/users/search';
  
  // Post endpoints
  static const String createPost = '/api/posts';
  static const String feed = '/api/posts/feed';
  static const String recommendedFeed = '/api/posts/recommended';
  static String postsByUser(String userId) => '/api/posts/user/$userId';
  static String postsByPlace(String placeCode) => '/api/posts/place/$placeCode';
  static String deletePost(String postId) => '/api/posts/$postId';
  static String reportPost(String postId) => '/api/posts/$postId/report';
  
  // Admin endpoints
  static const String adminReportedPosts = '/api/admin/reported-posts';
  static String adminReportsForPost(String postId) => '/api/admin/posts/$postId/reports';
  static String adminHidePost(String postId) => '/api/admin/posts/$postId/hide';
  static String adminDeletePost(String postId) => '/api/admin/posts/$postId/delete';
  static String adminRestorePost(String postId) => '/api/admin/posts/$postId/restore';
  static String adminMarkReportValid(String reportId) => '/api/admin/reports/$reportId/mark-valid';
  static String adminMarkReportInvalid(String reportId) => '/api/admin/reports/$reportId/mark-invalid';
  
  // Place endpoints
  static const String places = '/api/places';
  
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
  static String conversationById(String conversationId) =>
      '/api/conversations/$conversationId';
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
  
  // Event endpoints (v1 API)
  static const String events = '/api/v1/events';
  static String eventById(String eventId) => '/api/v1/events/$eventId';
  
  // Matching endpoints (v1 API)
  static const String swipe = '/api/v1/matches/swipe';
  
  // Connection endpoints (v1 API)
  static const String followingIds = '/api/v1/connections/following/ids';
  static const String followUser = '/api/v1/connections/follow';
}










