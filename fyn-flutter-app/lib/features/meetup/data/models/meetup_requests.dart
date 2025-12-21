import 'meetup_enums.dart';

class CreateMeetupRequest {
  final String title;
  final String? description;
  final MeetType meetType;
  final String? category;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final DateTime? expiresAt;
  final int? durationMinutes;
  final int maxParticipants;

  CreateMeetupRequest({
    required this.title,
    this.description,
    required this.meetType,
    this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    this.expiresAt,
    this.durationMinutes,
    required this.maxParticipants,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'meetType': meetType.value,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledAt': scheduledAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'durationMinutes': durationMinutes ?? 120,
      'maxParticipants': maxParticipants,
    };
  }
}

class ApplyToMeetupRequest {
  final String? message;

  ApplyToMeetupRequest({this.message});

  Map<String, dynamic> toJson() {
    return {
      if (message != null) 'message': message,
    };
  }
}

class ConfirmMeetupRequest {
  final String result; // "SUCCESS" or "NO_SHOW"

  ConfirmMeetupRequest({required this.result});

  Map<String, dynamic> toJson() {
    return {'result': result};
  }
}
