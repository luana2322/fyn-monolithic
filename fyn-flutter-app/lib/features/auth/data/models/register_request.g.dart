// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      phone: json['phone'] as String?,
      username: json['username'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'username': instance.username,
      'password': instance.password,
      'fullName': instance.fullName,
    };
