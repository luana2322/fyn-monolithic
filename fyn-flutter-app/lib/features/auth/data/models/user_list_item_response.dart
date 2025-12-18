import 'package:json_annotation/json_annotation.dart';

part 'user_list_item_response.g.dart';

/// User list item for search/discover screens
@JsonSerializable()
class UserListItemResponse {
  final String id;
  final String username;
  final String? fullName;
  final int? age;
  final String? gender;
  final String? bio;
  final String? avatarUrl;
  final String? location;
  final double? distanceKm;
  @JsonKey(defaultValue: false)
  final bool? isOnline;
  @JsonKey(defaultValue: 100.0)
  final double? reputationScore;

  UserListItemResponse({
    required this.id,
    required this.username,
    this.fullName,
    this.age,
    this.gender,
    this.bio,
    this.avatarUrl,
    this.location,
    this.distanceKm,
    this.isOnline,
    this.reputationScore,
  });

  factory UserListItemResponse.fromJson(Map<String, dynamic> json) =>
      _$UserListItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserListItemResponseToJson(this);
}
