import '../../../../core/utils/image_utils.dart';

/// Story model for displaying stories in feed
class StoryModel {
  final String id;
  final StoryUserModel user;
  final String mediaType; // IMAGE, VIDEO
  final String mediaUrl;
  final String? textContent;
  final String? backgroundColor;
  final int viewCount;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool viewedByCurrentUser;

  StoryModel({
    required this.id,
    required this.user,
    required this.mediaType,
    required this.mediaUrl,
    this.textContent,
    this.backgroundColor,
    this.viewCount = 0,
    required this.createdAt,
    required this.expiresAt,
    this.viewedByCurrentUser = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: (json['id'] ?? '').toString(),
      user: StoryUserModel.fromJson(json['user'] ?? {}),
      mediaType: json['mediaType']?.toString() ?? 'IMAGE',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      textContent: json['textContent']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      viewCount: json['viewCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'].toString()) 
          : DateTime.now().add(const Duration(hours: 24)),
      viewedByCurrentUser: json['viewedByCurrentUser'] ?? false,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }
  
  /// Get display URL for media - handles both full presigned URLs and object keys
  String get mediaDisplayUrl {
    // If it's already a full URL (starts with http:// or https://), return as is
    if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
      return mediaUrl;
    }
    
    // Otherwise, it's an old object key - build MinIO URL
    // This is for backwards compatibility with stories created before presigned URL implementation
    return 'http://localhost:9000/fyn-data/$mediaUrl';
  }
}

/// User data for story display
class StoryUserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final bool hasActiveStories;
  final int storyCount;

  StoryUserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.hasActiveStories = false,
    this.storyCount = 0,
  });

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    return StoryUserModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      hasActiveStories: json['hasActiveStories'] ?? false,
      storyCount: json['storyCount'] ?? 0,
    );
  }

  String get displayName => fullName ?? username;
  
  String get avatarDisplayUrl => avatarUrl != null 
      ? ImageUtils.getAvatarUrl(avatarUrl)!
      : '';
}

/// User with their stories for feed display
class StoryUserWithStories {
  final String userId;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final int storyCount;
  final bool allViewed;
  final List<StoryModel> stories;

  StoryUserWithStories({
    required this.userId,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.storyCount = 0,
    this.allViewed = false,
    this.stories = const [],
  });

  factory StoryUserWithStories.fromJson(Map<String, dynamic> json) {
    return StoryUserWithStories(
      userId: (json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      fullName: json['fullName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      storyCount: json['storyCount'] ?? 0,
      allViewed: json['allViewed'] ?? false,
      stories: (json['stories'] as List?)
          ?.map((s) => StoryModel.fromJson(s))
          .toList() ?? [],
    );
  }

  String get displayName => fullName ?? username;
}

/// Story feed response
class StoryFeedModel {
  final List<StoryUserWithStories> users;
  final StoryUserWithStories? currentUser;

  StoryFeedModel({
    this.users = const [],
    this.currentUser,
  });

  factory StoryFeedModel.fromJson(Map<String, dynamic> json) {
    return StoryFeedModel(
      users: (json['users'] as List?)
          ?.map((u) => StoryUserWithStories.fromJson(u))
          .toList() ?? [],
      currentUser: json['currentUser'] != null 
          ? StoryUserWithStories.fromJson(json['currentUser']) 
          : null,
    );
  }
}
