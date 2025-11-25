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

  ProfileResponse({
    this.bio,
    this.website,
    this.location,
    this.avatarUrl,
    this.isPrivate = false,
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
      );
    }
  }

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

