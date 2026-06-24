import 'package:json_annotation/json_annotation.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/value_objects/auth_token.dart';

part 'auth_response.g.dart';

class AuthTokenConverter implements JsonConverter<AuthToken, dynamic> {
  const AuthTokenConverter();

  @override
  AuthToken fromJson(dynamic json) {
    if (json == null || json is! String) {
      throw ValidationException(
        message: 'Invalid or missing access_token in response',
      );
    }
    return AuthToken(json);
  }

  @override
  dynamic toJson(AuthToken object) => object.value;
}

@JsonSerializable()
@AuthTokenConverter()
class AuthResponse {
  @JsonKey(name: 'access_token', readValue: _readToken)
  final AuthToken token;

  AuthResponse({
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  static Object? _readToken(Map<dynamic, dynamic> json, String key) =>
      json['access_token'] ?? json['accessToken'];
}
