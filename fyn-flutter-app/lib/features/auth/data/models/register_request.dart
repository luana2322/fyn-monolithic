import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String? phone;
  final String username;
  final String password;
  final String? fullName;

  RegisterRequest({
    required this.email,
    this.phone,
    required this.username,
    required this.password,
    this.fullName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

