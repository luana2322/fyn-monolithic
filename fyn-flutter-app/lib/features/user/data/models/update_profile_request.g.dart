// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequest _$UpdateProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequest(
      fullName: json['fullName'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      isPrivate: json['isPrivate'] as bool?,
    );

Map<String, dynamic> _$UpdateProfileRequestToJson(
        UpdateProfileRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'bio': instance.bio,
      'website': instance.website,
      'location': instance.location,
      'isPrivate': instance.isPrivate,
    };
