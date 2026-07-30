import 'package:dio/dio.dart';
import 'package:shared_core/src/constants/api_constants.dart';
import 'package:shared_core/src/local/helpers/environment_config.dart';
import 'package:shared_core/src/network/envelope_interceptor.dart';
import 'package:shared_core/src/network/logging_interceptor.dart';
import 'package:shared_core/src/network/retry_interceptor.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: ApiEndpoints.timeout,
      receiveTimeout: ApiEndpoints.timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(EnvelopeInterceptor());
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(RetryInterceptor());

  return dio;
}
