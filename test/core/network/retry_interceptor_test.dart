import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/core/network/retry_interceptor.dart';

void main() {
  late RetryInterceptor interceptor;

  setUp(() {
    interceptor = RetryInterceptor();
  });

  group('RetryInterceptor', () {
    test('has default maxRetries of 3', () {
      expect(interceptor.maxRetries, 3);
    });

    test('has default baseDelay of 1 second', () {
      expect(interceptor.baseDelay, const Duration(seconds: 1));
    });

    group('_shouldRetry', () {
      test('retries on connectionTimeout', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        expect(interceptor.shouldRetry(err), isTrue);
      });

      test('retries on receiveTimeout', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );
        expect(interceptor.shouldRetry(err), isTrue);
      });

      test('retries on connectionError', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );
        expect(interceptor.shouldRetry(err), isTrue);
      });

      test('retries on HTTP 429', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 429,
          ),
        );
        expect(interceptor.shouldRetry(err), isTrue);
      });

      test('retries on HTTP 5xx', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 503,
          ),
        );
        expect(interceptor.shouldRetry(err), isTrue);
      });

      test('does not retry on HTTP 400', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
          ),
        );
        expect(interceptor.shouldRetry(err), isFalse);
      });

      test('does not retry on cancel', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.cancel,
        );
        expect(interceptor.shouldRetry(err), isFalse);
      });
    });

    group('_getRetryCount', () {
      test('returns 0 when no header', () {
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        expect(interceptor.getRetryCount(err), 0);
      });

      test('returns value from header', () {
        final options = RequestOptions(path: '/test');
        options.headers['X-Retry-Count'] = '2';
        final err = DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
        expect(interceptor.getRetryCount(err), 2);
      });
    });
  });
}
