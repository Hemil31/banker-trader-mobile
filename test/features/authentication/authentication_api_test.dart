import 'package:banker_trader/features/authentication/data/sources/authentication_api.dart';
import 'package:banker_trader/features/authentication/domain/exceptions/auth_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _RejectingInterceptor extends Interceptor {
  _RejectingInterceptor(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: statusCode,
          data: body,
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }
}

void main() {
  AuthenticationApi buildApi(Map<String, dynamic> body, int statusCode) {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
    dio.interceptors.add(_RejectingInterceptor(statusCode, body));
    return AuthenticationApi(dio: dio, baseUrl: 'http://api.test');
  }

  group('AuthenticationApi.login errors', () {
    test('surfaces backend field validation errors for a 422', () async {
      final api = buildApi(
        {
          'message': 'The given data was invalid.',
          'errors': {
            'email': ['Username or email is required.'],
            'password': ['Password must be at least 8 characters.'],
          },
        },
        422,
      );

      expect(
        () => api.login(identifier: '', password: 'short'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'The given data was invalid.')
              .having(
                (e) => e.fieldErrors,
                'fieldErrors',
                containsPair('password', 'Password must be at least 8 characters.'),
              ),
        ),
      );
    });

    test('surfaces the backend message for invalid credentials (401)', () async {
      final api = buildApi(
        {'success': false, 'message': 'Invalid credentials.', 'errors': null},
        401,
      );

      expect(
        () => api.login(identifier: 'dev', password: 'wrong'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'Invalid credentials.')
              .having((e) => e.fieldErrors, 'fieldErrors', isEmpty),
        ),
      );
    });

    test('falls back to a generic message when the body is not parseable', () async {
      final api = buildApi({}, 500);

      expect(
        () => api.login(identifier: 'dev', password: 'devpassword'),
        throwsA(
          isA<AuthException>()
              .having(
                (e) => e.message,
                'message',
                'Unable to sign in. Please try again.',
              )
              .having((e) => e.fieldErrors, 'fieldErrors', isEmpty),
        ),
      );
    });
  });
}