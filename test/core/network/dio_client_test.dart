import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/core/network/dio_client.dart';
import 'package:orientmobileapplication/core/network/logging_interceptor.dart';
import 'package:orientmobileapplication/core/network/retry_interceptor.dart';

void main() {
  group('createDio', () {
    test('returns Dio with configured baseUrl', () {
      final dio = createDio();
      expect(dio.options.baseUrl, 'https://api.orientworkshop.com/v1');
    });

    test('sets connect timeout from ApiConstants', () {
      final dio = createDio();
      expect(dio.options.connectTimeout, const Duration(milliseconds: 30000));
    });

    test('sets receive timeout from ApiConstants', () {
      final dio = createDio();
      expect(dio.options.receiveTimeout, const Duration(milliseconds: 30000));
    });

    test('sets JSON content-type header', () {
      final dio = createDio();
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('adds LoggingInterceptor and RetryInterceptor', () {
      final dio = createDio();
      expect(dio.interceptors.any((i) => i is LoggingInterceptor), isTrue);
      expect(dio.interceptors.any((i) => i is RetryInterceptor), isTrue);
    });
  });
}
