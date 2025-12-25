import 'package:json_annotation/json_annotation.dart';
import 'profile_response.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  final String id;
  final String username;
  final String? email; // Nullable: hidden when viewing other users' profiles
  final String? phone;
  final String? fullName;
  @JsonKey(defaultValue: 'ACTIVE')
  final String status;
  final String? role;
  @JsonKey(fromJson: _profileFromJson)
  final ProfileResponse profile;

  UserResponse({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.fullName,
    this.status = 'ACTIVE',
    this.role,
    required this.profile,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
  
  // Helper function to handle null or missing profile
  static ProfileResponse _profileFromJson(dynamic json) {
    if (json == null) {
      return ProfileResponse(isPrivate: false);
    }
    if (json is Map<String, dynamic>) {
      try {
        return ProfileResponse.fromJson(json);
      } catch (e) {
        // If parsing fails, return default profile
        print('Error in _profileFromJson: $e');
        return ProfileResponse(isPrivate: false);
      }
    }
    return ProfileResponse(isPrivate: false);
  }

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

