import 'package:json_annotation/json_annotation.dart';

part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  final String? bio;
  final String? website;
  final String? location;
  final String? avatarUrl;
  @JsonKey(defaultValue: false)
  final bool isPrivate;
  final String? gender; // MALE, FEMALE, OTHER, PREFER_NOT_TO_SAY
  final int? age; // Calculated from dateOfBirth
  final String? educationLevel; // HIGH_SCHOOL, COLLEGE, UNIVERSITY, etc
  @JsonKey(defaultValue: 100.0)
  final double reputationScore;

  ProfileResponse({
    this.bio,
    this.website,
    this.location,
    this.avatarUrl,
    this.isPrivate = false,
    this.gender,
    this.age,
    this.educationLevel,
    this.reputationScore = 100.0,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProfileResponseFromJson(json);
    } catch (e) {
      // If parsing fails, return default profile with safe parsing
      print('Error parsing ProfileResponse: $e');
      print('JSON: $json');
      return ProfileResponse(
        bio: json['bio'] as String?,
        website: json['website'] as String?,
        location: json['location'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isPrivate: (json['isPrivate'] as bool?) ?? false,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        educationLevel: json['educationLevel'] as String?,
        reputationScore: (json['reputationScore'] as num?)?.toDouble() ?? 100.0,
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}


