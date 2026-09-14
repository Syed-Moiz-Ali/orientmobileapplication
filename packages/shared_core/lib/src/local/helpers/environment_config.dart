import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _defaultBaseUrl =
      'https://56zk48dj-8080.inc1.devtunnels.ms/api/v1';
  static const String _defaultAppEnv = 'development';

  static bool _initialized = false;
  static String? _overrideBaseUrl;
  static String? _overrideAppEnv;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      // Loaded from the package asset path for consuming apps.
      await dotenv.load(
        isOptional: true,
        fileName: 'packages/shared_core/assets/.env',
      );
      if (dotenv.get('BASE_URL', fallback: '').trim().isEmpty) {
        // Package-local tests run from packages/shared_core, where the asset is
        // available as assets/.env instead of packages/shared_core/assets/.env.
        await dotenv.load(isOptional: true, fileName: 'assets/.env');
      }
    } catch (_) {
      // Ignore: fall back to defaults below.
    }
    _initialized = true;
  }

  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    final fromEnv = dotenv.get('BASE_URL', fallback: '').trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return _defaultBaseUrl;
  }

  static String get appEnv {
    if (_overrideAppEnv != null && _overrideAppEnv!.isNotEmpty) {
      return _overrideAppEnv!;
    }
    final fromEnv = dotenv.get('APP_ENV', fallback: _defaultAppEnv).trim();
    return fromEnv.isNotEmpty ? fromEnv : _defaultAppEnv;
  }

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';

  @visibleForTesting
  static void setBaseUrlForTesting(String? url, {String? env}) {
    _overrideBaseUrl = url;
    if (env != null) _overrideAppEnv = env;
  }
}
