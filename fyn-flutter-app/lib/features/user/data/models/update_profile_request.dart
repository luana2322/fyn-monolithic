import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  final String? fullName;
  final String? bio;
  final String? website;
  final String? location;
  final bool? isPrivate;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? educationLevel;

  UpdateProfileRequest({
    this.fullName,
    this.bio,
    this.website,
    this.location,
    this.isPrivate,
    this.gender,
    this.dateOfBirth,
    this.educationLevel,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}


