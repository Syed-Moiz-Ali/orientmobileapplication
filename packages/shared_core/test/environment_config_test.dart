import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  test('EnvironmentConfig reads BASE_URL and APP_ENV from the bundled .env',
      () async {
    await EnvironmentConfig.init();

    expect(
      EnvironmentConfig.baseUrl,
      'https://56zk48dj-8080.inc1.devtunnels.ms/api/v1',
      reason: 'BASE_URL must come from packages/shared_core/assets/.env',
    );
    expect(EnvironmentConfig.appEnv, 'development');
    expect(EnvironmentConfig.isDevelopment, isTrue);
  });
}
