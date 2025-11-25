class AppConstants {
  // App Info
  static const String appName = 'FYN Social';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int feedPageSize = 10;
  static const int messagesPageSize = 50;
  
  // File Upload
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}














