import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/constants/api_constants.dart';
import 'package:orientmobileapplication/core/local/helpers/environment_config.dart';
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
  dio.interceptors.add(RetryInterceptor(maxRetries: ApiConstants.maxRetries));

  return dio;
}

final dioClientProvider = Provider<Dio>((ref) => createDio());
