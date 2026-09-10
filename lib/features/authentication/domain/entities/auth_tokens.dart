class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 0,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}
