import 'package:dio/dio.dart';

/// Data-transfer objects for the authentication API.
class LoginResponseDto {
  const LoginResponseDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final Map<String, dynamic> user;
  final String accessToken;
  final String refreshToken;

  static LoginResponseDto fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final token = data['token'] as Map<String, dynamic>? ?? const {};
    return LoginResponseDto(
      user: data['user'] as Map<String, dynamic>? ?? data,
      accessToken: _string(token['access_token']),
      refreshToken: _string(token['refresh_token']),
    );
  }
}

/// The Laravel API wraps data under `data` and exposes the user object either
/// at the top of `data` or nested under `data.user`. Helper to keep parsing robust.
String _string(Object? value) => value?.toString() ?? '';

class TokenResponseDto {
  const TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  static TokenResponseDto fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TokenResponseDto(
      accessToken: _string(data['access_token']),
      refreshToken: _string(data['refresh_token']),
    );
  }
}

/// Thin HTTP client for the authentication endpoints. All paths hit the
/// Passport-based API at [baseUrl].
class AuthenticationApi {
  AuthenticationApi({
    required this.dio,
    required this.baseUrl,
    this.onUnauthorized,
  });

  final Dio dio;
  final String baseUrl;
  final Future<void> Function()? onUnauthorized;

  Future<LoginResponseDto> login({
    required String identifier,
    required String password,
  }) async {
    final response = await dio.post(
      '$baseUrl/api/login',
      data: {'email': identifier, 'password': password},
      options: Options(contentType: Headers.jsonContentType),
    );
    return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenResponseDto> refresh(String refreshToken) async {
    final response = await dio.post(
      '$baseUrl/api/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(contentType: Headers.jsonContentType),
    );
    return TokenResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await dio.post('$baseUrl/api/logout');
  }

  Future<Map<String, dynamic>> me() async {
    final response = await dio.get('$baseUrl/api/me');
    final data = response.data as Map<String, dynamic>? ?? const {};
    return (data['data'] as Map<String, dynamic>?) ?? data;
  }
}
