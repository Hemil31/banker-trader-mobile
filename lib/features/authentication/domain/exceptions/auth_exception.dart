/// Signals a failed authentication attempt with the backend's message and any
/// per-field validation errors so the UI can surface them appropriately.
class AuthException implements Exception {
  const AuthException(this.message, [this.fieldErrors = const {}]);

  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}