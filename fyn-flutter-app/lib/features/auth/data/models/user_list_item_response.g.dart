// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserListItemResponse _$UserListItemResponseFromJson(
        Map<String, dynamic> json) =>
    UserListItemResponse(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      location: json['location'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      isOnline: json['isOnline'] as bool? ?? false,
      reputationScore: (json['reputationScore'] as num?)?.toDouble() ?? 100.0,
    );

Map<String, dynamic> _$UserListItemResponseToJson(
        UserListItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullName': instance.fullName,
      'age': instance.age,
      'gender': instance.gender,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'location': instance.location,
      'distanceKm': instance.distanceKm,
      'isOnline': instance.isOnline,
      'reputationScore': instance.reputationScore,
    };
