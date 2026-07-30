import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await dotenv.load(fileName: 'packages/shared_core/assets/.env');
    _initialized = true;
  }

  static String get baseUrl => dotenv.get('BASE_URL', fallback: 'http://localhost:8080/api/v1');
  static String get appEnv => dotenv.get('APP_ENV', fallback: 'development');
  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';
}
