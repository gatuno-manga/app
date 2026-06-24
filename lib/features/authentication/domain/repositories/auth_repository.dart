import '../value_objects/auth_token.dart';
import '../value_objects/email_address.dart';
import '../value_objects/password.dart';

abstract class AuthRepository {
  Future<AuthToken> signIn(EmailAddress email, Password password);
  Future<void> signUp(EmailAddress email, Password password);
  Future<AuthToken> refreshToken();
  Future<void> logout();
}
