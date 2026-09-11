import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class AuthenticationRepository {
  /// Logs in using email or username and returns the user + token pair.
  Future<(User, AuthTokens)> login(String identifier, String password);

  /// Exchanges a refresh token for a new token pair.
  Future<AuthTokens> refresh(String refreshToken);

  /// Revokes the current user session.
  Future<void> logout();

  /// Changes the current user's password. Revokes all other sessions/tokens.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Returns the currently authenticated user.
  Future<User> me();
}
