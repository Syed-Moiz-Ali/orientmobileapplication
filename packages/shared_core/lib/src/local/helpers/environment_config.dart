import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _defaultBaseUrl = 'http://localhost:8080/api/v1';
  static const String _defaultAppEnv = 'development';

  // Values injected at build time via --dart-define=BASE_URL=... / APP_ENV=...
  // These take precedence over the bundled .env file.
  static const String _defineBaseUrl = String.fromEnvironment('BASE_URL');
  static const String _defineAppEnv = String.fromEnvironment('APP_ENV');

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      // Loaded from the package asset path so it works regardless of the
      // current working directory. A missing/corrupt .env must never crash.
      await dotenv.load(
        isOptional: true,
        fileName: 'packages/shared_core/assets/.env',
      );
    } catch (_) {
      // Ignore: fall back to dart-define or defaults below.
    }
    _initialized = true;
  }

  static String get baseUrl {
    if (_defineBaseUrl.isNotEmpty) return _defineBaseUrl;
    final fromEnv = dotenv.get('BASE_URL', fallback: '');
    return fromEnv.isNotEmpty ? fromEnv : _defaultBaseUrl;
  }

  static String get appEnv {
    if (_defineAppEnv.isNotEmpty) return _defineAppEnv;
    return dotenv.get('APP_ENV', fallback: _defaultAppEnv);
  }

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';
}
