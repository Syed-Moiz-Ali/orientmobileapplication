import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _defaultBaseUrl = 'http://localhost:8080/api/v1';
  static const String _defaultAppEnv = 'development';

  // FE-FIX (owner decision): the bundled .env (packages/shared_core/assets/.env)
  // is the SINGLE source for BASE_URL and APP_ENV — no --dart-define required.
  // The .env is declared as an asset, so it ships inside the APK: production
  // builds are configured at build time by putting the real https API URL in
  // the .env before building (CI does this from the API_BASE_URL variable).
  // Changing the URL still requires a rebuild (both .env and dart-define are
  // baked into the binary) — this is build-time configuration, not runtime.

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
      // Ignore: fall back to defaults below.
    }
    _initialized = true;
  }

  static String get baseUrl {
    final fromEnv = dotenv.get('BASE_URL', fallback: '').trim();
    if (fromEnv.isNotEmpty) {
      // FIX (audit P0): release builds must never fall back to a devtunnel or
      // localhost endpoint — fail loudly instead of silently misrouting.
      if (kReleaseMode && !_isValidReleaseUrl(fromEnv)) {
        throw StateError(
          'BASE_URL is invalid for release: $fromEnv. '
          'Set a valid https URL in packages/shared_core/assets/.env before building.',
        );
      }
      return fromEnv;
    }
    if (kReleaseMode) {
      throw StateError(
        'BASE_URL is not set. Production builds require '
        'BASE_URL=https://api.example.com in packages/shared_core/assets/.env.',
      );
    }
    return _defaultBaseUrl;
  }

  static bool _isValidReleaseUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('https://') &&
        !lower.contains('devtunnels') &&
        !lower.contains('localhost') &&
        !lower.contains('192.168.') &&
        !lower.contains('10.0.') &&
        !lower.contains('127.0.0.1');
  }

  static String get appEnv {
    final fromEnv = dotenv.get('APP_ENV', fallback: _defaultAppEnv).trim();
    return fromEnv.isNotEmpty ? fromEnv : _defaultAppEnv;
  }

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';
}
