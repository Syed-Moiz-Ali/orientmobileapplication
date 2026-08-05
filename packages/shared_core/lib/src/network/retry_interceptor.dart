import 'dart:math';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final Logger _logger;
  final Dio _dio;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    Logger? logger,
  })  : _dio = dio,
        _logger = logger ?? Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (shouldRetry(err) && getRetryCount(err) < maxRetries) {
      final retryCount = getRetryCount(err);
      var delay = baseDelay * (1 << retryCount);
      // Honor Retry-After on 429 responses.
      if (err.response?.statusCode == 429) {
        final retryAfter = err.response?.headers.value('retry-after');
        final seconds = int.tryParse(retryAfter ?? '');
        if (seconds != null) {
          delay = Duration(seconds: seconds);
        }
      }
      // Small jitter to avoid thundering herds.
      delay += Duration(milliseconds: Random().nextInt(300));
      _logger.w(
        'Retrying ${err.requestOptions.path} ($retryCount/$maxRetries) after ${delay.inMilliseconds}ms',
      );
      await Future<void>.delayed(delay);
      try {
        // Re-dispatch through the SAME Dio instance so the envelope /
        // auth interceptors still unwrap and authenticate the retry.
        final options = RequestOptions(
          method: err.requestOptions.method,
          path: err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          headers: {...err.requestOptions.headers},
          responseType: err.requestOptions.responseType,
          contentType: err.requestOptions.contentType,
          extra: err.requestOptions.extra,
          sendTimeout: err.requestOptions.sendTimeout,
          receiveTimeout: err.requestOptions.receiveTimeout,
          connectTimeout: err.requestOptions.connectTimeout,
        );
        options.headers['X-Retry-Count'] = '${retryCount + 1}';
        final response = await _dio.fetch(options);
        handler.resolve(response);
        return;
      } catch (e, st) {
        _logger.e('Retry failed for ${err.requestOptions.path}', error: e, stackTrace: st);
        handler.next(err);
        return;
      }
    }
    handler.next(err);
  }

  bool shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.response?.statusCode == 429 ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  int getRetryCount(DioException error) {
    final header = error.requestOptions.headers['X-Retry-Count'] as String?;
    return int.tryParse(header ?? '0') ?? 0;
  }
}
