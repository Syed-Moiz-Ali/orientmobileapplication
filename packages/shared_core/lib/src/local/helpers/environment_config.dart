class EnvironmentConfig {
  EnvironmentConfig._();

  static String get baseUrl {
    return const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://api.orientworkshop.com/v1',
    );
  }

  static bool get useMocks {
    return const bool.fromEnvironment(
      'USE_MOCKS',
      defaultValue: true,
    );
  }

  static String get appEnv {
    return const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
  }

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';
}
