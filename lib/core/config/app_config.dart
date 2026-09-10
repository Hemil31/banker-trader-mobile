/// Build-time configuration.
///
/// The base URL defaults to the local Laravel dev server and can be overridden
/// at build/run time:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String apiTimeoutSeconds = String.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: '15',
  );
}
