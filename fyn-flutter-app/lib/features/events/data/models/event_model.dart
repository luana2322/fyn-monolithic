// Simple EventModel without Freezed to avoid build_runner dependency
class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? slug;
  final String? coverImageUrl;
  final String activityType;
  final String visibility;
  final String status;
  final bool isOnline;
  final String? onlineMeetingUrl;
  final double? locationLat;
  final double? locationLng;
  final String? locationName;
  final String? locationAddress;
  final DateTime startTime;
  final DateTime? endTime;
  final String? recurrence;
  final int maxParticipants;
  final int currentParticipants;
  final int waitlistCount;
  final UserModel? createdBy;
  final DateTime? createdAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.slug,
    this.coverImageUrl,
    required this.activityType,
    this.visibility = 'PUBLIC',
    this.status = 'OPEN',
    this.isOnline = false,
    this.onlineMeetingUrl,
    this.locationLat,
    this.locationLng,
    this.locationName,
    this.locationAddress,
    required this.startTime,
    this.endTime,
    this.recurrence,
    this.maxParticipants = 0,
    this.currentParticipants = 0,
    this.waitlistCount = 0,
    this.createdBy,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      activityType: json['activity_type'] as String? ?? json['activityType'] as String? ?? 'OTHER',
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      status: json['status'] as String? ?? 'OPEN',
      isOnline: json['is_online'] as bool? ?? json['isOnline'] as bool? ?? false,
      onlineMeetingUrl: json['online_meeting_url'] as String?,
      locationLat: (json['location_lat'] ?? json['locationLat'])?.toDouble(),
      locationLng: (json['location_lng'] ?? json['locationLng'])?.toDouble(),
      locationName: json['location_name'] as String? ?? json['locationName'] as String?,
      locationAddress: json['location_address'] as String? ?? json['locationAddress'] as String?,
      startTime: DateTime.parse(json['start_time'] ?? json['startTime']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : 
               json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      recurrence: json['recurrence'] as String?,
      maxParticipants: json['max_participants'] as int? ?? json['maxParticipants'] as int? ?? 0,
      currentParticipants: json['current_participants'] as int? ?? json['currentParticipants'] as int? ?? 0,
      waitlistCount: json['waitlist_count'] as int? ?? json['waitlistCount'] as int? ?? 0,
      createdBy: json['created_by'] != null ? UserModel.fromJson(json['created_by']) :
                 json['createdBy'] != null ? UserModel.fromJson(json['createdBy']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) :
                 json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'slug': slug,
      'cover_image_url': coverImageUrl,
      'activity_type': activityType,
      'visibility': visibility,
      'status': status,
      'is_online': isOnline,
      'online_meeting_url': onlineMeetingUrl,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'location_name': locationName,
      'location_address': locationAddress,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'recurrence': recurrence,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'waitlist_count': waitlistCount,
    };
  }
}

class UserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String? ?? json['fullName'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }
}
