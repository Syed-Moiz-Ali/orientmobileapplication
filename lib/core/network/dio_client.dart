import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/constants/api_constants.dart';
import 'package:orientmobileapplication/core/local/helpers/environment_config.dart';
import 'package:orientmobileapplication/core/network/auth_interceptor.dart';
import 'package:orientmobileapplication/core/network/logging_interceptor.dart';
import 'package:orientmobileapplication/core/network/retry_interceptor.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(RetryInterceptor());

  return dio;
}

final dioClientProvider = Provider<Dio>((ref) {
  final dio = createDio();
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});
