import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message, [this.fieldErrors = const {}]);

  final String message;

  /// Backend validation errors keyed by field (`email`, `password`), used to
  /// render inline messages on the login form.
  final Map<String, String> fieldErrors;
}
