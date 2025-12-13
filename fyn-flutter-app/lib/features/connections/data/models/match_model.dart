/// Match model representing a potential connection
class MatchModel {
  final String id;
  final UserPreview user;
  final double matchScore;
  final List<String> commonInterests;
  final double distanceKm;
  final String status; // pending, liked, rejected, matched
  final String connectionType; // dating, friendship, hobby, group, community
  final DateTime? matchedAt;

  MatchModel({
    required this.id,
    required this.user,
    required this.matchScore,
    this.commonInterests = const [],
    this.distanceKm = 0,
    this.status = 'pending',
    this.connectionType = 'dating',
    this.matchedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // Backend returns flat structure with userId at top level
    // Handle both nested 'user' object and flat structure
    final hasNestedUser = json.containsKey('user') && json['user'] is Map;
    
    String id;
    UserPreview user;
    
    if (hasNestedUser) {
      // Nested structure: { id: "...", user: { id: "...", username: "..." } }
      id = (json['id'] ?? json['userId'] ?? '').toString();
      user = UserPreview.fromJson(json['user']);
    } else {
      // Flat structure from DiscoverProfileResponse: { userId: "...", username: "...", bio: "..." }
      id = (json['userId'] ?? json['id'] ?? '').toString();
      user = UserPreview.fromJson(json);
    }
    
    return MatchModel(
      id: id,
      user: user,
      matchScore: (json['matchScore'] ?? json['match_score'] ?? 0.0).toDouble(),
      commonInterests: List<String>.from(json['commonInterests'] ?? json['common_interests'] ?? []),
      distanceKm: (json['distanceKm'] ?? json['distance'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      connectionType: json['connectionType']?.toString() ?? json['connection_type']?.toString() ?? 'dating',
      matchedAt: json['matchedAt'] != null ? DateTime.parse(json['matchedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'matchScore': matchScore,
    'commonInterests': commonInterests,
    'distanceKm': distanceKm,
    'status': status,
    'connectionType': connectionType,
    'matchedAt': matchedAt?.toIso8601String(),
  };

  MatchModel copyWith({
    String? id,
    UserPreview? user,
    double? matchScore,
    List<String>? commonInterests,
    double? distanceKm,
    String? status,
    String? connectionType,
    DateTime? matchedAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      user: user ?? this.user,
      matchScore: matchScore ?? this.matchScore,
      commonInterests: commonInterests ?? this.commonInterests,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      connectionType: connectionType ?? this.connectionType,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }
}

/// Simplified user preview for match cards
class UserPreview {
  final String id;
  final String username;
  final String? fullName;
  final int? age;
  final String? bio;
  final List<String> photos;
  final String? gender;
  final List<String> interests;

  UserPreview({
    required this.id,
    required this.username,
    this.fullName,
    this.age,
    this.bio,
    this.photos = const [],
    this.gender,
    this.interests = const [],
  });

  factory UserPreview.fromJson(Map<String, dynamic> json) {
    // Handle photos that might contain nulls or be null
    final rawPhotos = json['photos'] ?? json['avatarUrl'] != null ? [json['avatarUrl']] : [];
    final photos = (rawPhotos as List?)
        ?.where((p) => p != null)
        .map((p) => p.toString())
        .toList() ?? [];
    
    // Handle interests that might contain nulls
    final rawInterests = json['interests'] ?? [];
    final interests = (rawInterests as List?)
        ?.where((i) => i != null)
        .map((i) => i.toString())
        .toList() ?? [];
    
    return UserPreview(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString(),
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
      bio: json['bio']?.toString(),
      photos: photos,
      gender: json['gender']?.toString(),
      interests: interests,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'fullName': fullName,
    'age': age,
    'bio': bio,
    'photos': photos,
    'gender': gender,
    'interests': interests,
  };

  /// Display name (fullName or username)
  String get displayName => fullName ?? username;

  /// Primary photo URL
  String? get primaryPhoto => photos.isNotEmpty ? photos.first : null;
}
