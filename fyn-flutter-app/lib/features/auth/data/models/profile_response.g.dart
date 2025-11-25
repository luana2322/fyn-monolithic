// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'website': instance.website,
      'location': instance.location,
      'avatarUrl': instance.avatarUrl,
      'isPrivate': instance.isPrivate,
    };
