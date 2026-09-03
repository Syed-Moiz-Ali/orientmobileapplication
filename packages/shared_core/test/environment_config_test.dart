import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  // FE-FIX (owner decision): BASE_URL comes from the bundled .env — the
  // shared assets/.env ships `BASE_URL=https://g.erpmass.com/api/v1` and
  // `APP_ENV=production`, so these asserts guard the .env-driven config.
  test('EnvironmentConfig reads BASE_URL and APP_ENV from the bundled .env',
      () async {
    await EnvironmentConfig.init();

    expect(EnvironmentConfig.baseUrl, 'https://g.erpmass.com/api/v1',
        reason: 'BASE_URL must come from packages/shared_core/assets/.env');
    expect(EnvironmentConfig.appEnv, 'production');
    expect(EnvironmentConfig.isProduction, isTrue);
  });
}
