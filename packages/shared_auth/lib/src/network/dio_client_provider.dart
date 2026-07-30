import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/network/auth_interceptor.dart';
import 'package:shared_core/src/network/api_client.dart';
import 'package:shared_core/src/network/dio_client.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = createDio();
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioClientProvider));
});
