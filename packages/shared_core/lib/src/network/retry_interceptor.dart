import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final Logger _logger;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    Logger? logger,
  }) : _logger = logger ?? Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (shouldRetry(err) && getRetryCount(err) < maxRetries) {
      final retryCount = getRetryCount(err);
      final delay = baseDelay * (1 << retryCount);
      _logger.w(
        'Retrying ${err.requestOptions.path} ($retryCount/$maxRetries) after ${delay.inSeconds}s',
      );
      await Future.delayed(delay);
      try {
        final options = err.requestOptions;
        options.headers['X-Retry-Count'] = '${retryCount + 1}';
        final response = await Dio().fetch(options);
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
