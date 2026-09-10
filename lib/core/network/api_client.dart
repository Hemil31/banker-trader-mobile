import 'package:dio/dio.dart';

import '../../features/authentication/data/sources/authentication_api.dart';
import '../../features/authentication/domain/entities/auth_tokens.dart';
import '../storage/token_storage.dart';

/// Shared Dio instance configured for the Laravel API.
Dio buildDio({required String baseUrl}) => Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  ),
);

/// Adds `Authorization: Bearer <access>` to requests and transparently refreshes
/// an expired access token using the refresh token, then retries once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
    required String baseUrl,
  }) : _tokenStorage = tokenStorage,
       _dio = dio,
       _baseUrl = baseUrl;

  final TokenStorage _tokenStorage;
  final Dio _dio;
  final String _baseUrl;

  bool _refreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final access = await _tokenStorage.readAccessToken();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        _isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    final refresh = await _tokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      await _tokenStorage.clear();
      return handler.next(err);
    }

    try {
      final updated = await _awaitRefreshIfIdle(refresh);
      if (updated != null) {
        err.requestOptions.headers['Authorization'] =
            'Bearer ${updated.accessToken}';
        final response = await _dio.fetch<Object?>(err.requestOptions);
        return handler.resolve(response);
      }
    } on DioException {
      await _tokenStorage.clear();
      return handler.next(err);
    }
    return handler.next(err);
  }

  Future<AuthTokens?> _awaitRefreshIfIdle(String refreshToken) async {
    if (_refreshing) {
      // Another request is already refreshing; wait briefly.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return null;
    }
    _refreshing = true;
    try {
      final api = AuthenticationApi(dio: _dio, baseUrl: _baseUrl);
      final dto = await api.refresh(refreshToken);
      final tokens = AuthTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      await _tokenStorage.save(tokens);
      return tokens;
    } finally {
      _refreshing = false;
    }
  }

  bool _isAuthEndpoint(String path) {
    final normalized = path.toLowerCase();
    return normalized.contains('/api/login') ||
        normalized.contains('/api/refresh') ||
        normalized.contains('/api/logout');
  }
}
