import 'package:json_annotation/json_annotation.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/entities/auth_token.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse extends AuthToken {
  AuthResponse({
    @JsonKey(name: 'access_token', readValue: _readToken) required super.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = _readToken(json, 'token');
    if (token == null || token is! String) {
      throw ValidationException(
        message: 'Invalid or missing access_token in response',
      );
    }
    return _$AuthResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  static Object? _readToken(Map json, String key) =>
      json['access_token'] ?? json['accessToken'];
}
