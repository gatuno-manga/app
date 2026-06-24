import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/data/models/auth_response.dart';
import 'package:gatuno/features/authentication/domain/value_objects/auth_token.dart';

void main() {
  group('AuthResponse', () {
    test('fromJson returns AuthResponse with correct token', () {
      final json = {'access_token': 'access'};
      final result = AuthResponse.fromJson(json);

      expect(result.token.value, 'access');
    });

    test('fromJson handles snake_case access_token', () {
      final json = {'access_token': 'access'};
      final result = AuthResponse.fromJson(json);
      expect(result.token.value, 'access');
    });

    test('fromJson handles camelCase accessToken', () {
      final json = {'accessToken': 'access'};
      final result = AuthResponse.fromJson(json);
      expect(result.token.value, 'access');
    });

    test('toJson returns correct map', () {
      final response = AuthResponse(token: AuthToken('a'));
      final result = response.toJson();

      expect(result, {'access_token': 'a'});
    });
  });
}
