import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/user_profile.dart';

part 'api_response.g.dart';

/// A generic response for messages like "OTP sent".
@JsonSerializable()
class MessageResponse {
  final String message;

  MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

/// Response for successful login/signup verification which includes user data.
@JsonSerializable()
class AuthResponse {
  final String message;
  final UserProfile user;

  AuthResponse({required this.message, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// A generic error response from the server, e.g., { "error": "Invalid OTP." }.
@JsonSerializable()
class ErrorResponse {
  final String error;

  ErrorResponse({required this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}
