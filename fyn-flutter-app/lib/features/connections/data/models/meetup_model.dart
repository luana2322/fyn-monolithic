import 'match_model.dart';

/// Meetup model for group activities
class MeetupModel {
  final String id;
  final String title;
  final String? description;
  final String category; // sports, gaming, music, art, food, travel, etc.
  final UserPreview organizer;
  final List<UserPreview> participants;
  final int maxParticipants;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime scheduledAt;
  final String status; // open, full, ongoing, completed, cancelled
  final DateTime createdAt;

  MeetupModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.organizer,
    this.participants = const [],
    this.maxParticipants = 10,
    this.location,
    this.latitude,
    this.longitude,
    required this.scheduledAt,
    this.status = 'open',
    required this.createdAt,
  });

  factory MeetupModel.fromJson(Map<String, dynamic> json) {
    return MeetupModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] ?? 'other',
      organizer: UserPreview.fromJson(json['organizer']),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => UserPreview.fromJson(p))
          .toList() ?? [],
      maxParticipants: json['maxParticipants'] ?? json['max_participants'] ?? 10,
      location: json['location'] as String?,
      latitude: (json['latitude'] ?? json['lat'])?.toDouble(),
      longitude: (json['longitude'] ?? json['lng'])?.toDouble(),
      scheduledAt: DateTime.parse(json['scheduledAt'] ?? json['scheduled_at']),
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Spots left
  int get spotsLeft => maxParticipants - participants.length;
  bool get isFull => spotsLeft <= 0;
  bool get isOpen => status == 'open' && !isFull;

  /// Formatted participant count
  String get participantCount => '${participants.length}/$maxParticipants';
}

/// Connection type enum for filtering
enum ConnectionType {
  dating('dating', 'Dating', '❤️'),
  friendship('friendship', 'Friendship', '🤝'),
  hobbies('hobbies', 'Hobbies', '🎯'),
  groups('groups', 'Groups', '👥'),
  community('community', 'Community', '🌍');

  final String value;
  final String label;
  final String emoji;

  const ConnectionType(this.value, this.label, this.emoji);

  static ConnectionType fromString(String? value) {
    return ConnectionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConnectionType.dating,
    );
  }
}

/// Place type for dates
enum PlaceType {
  restaurant('restaurant', 'Restaurant', '🍽️'),
  cafe('cafe', 'Café', '☕'),
  bar('bar', 'Bar', '🍸'),
  park('park', 'Park', '🌳'),
  cinema('cinema', 'Cinema', '🎬'),
  billiard('billiard', 'Billiard', '🎱'),
  badminton('badminton', 'Badminton', '🏸'),
  gym('gym', 'Gym', '💪'),
  museum('museum', 'Museum', '🏛️'),
  other('other', 'Other', '📍');

  final String value;
  final String label;
  final String emoji;

  const PlaceType(this.value, this.label, this.emoji);

  static PlaceType fromString(String? value) {
    return PlaceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PlaceType.other,
    );
  }
}
