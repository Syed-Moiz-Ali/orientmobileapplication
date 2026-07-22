import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 1,
                errorMethodCount: 3,
                lineLength: 120,
                colors: true,
                printEmojis: false,
              ),
            );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('${options.method} ${options.path}');
    if (options.data != null) {
      _logger.t('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('${response.statusCode} ${response.requestOptions.path}');
    if (response.data is Map || response.data is List) {
      _logger.t('Response: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.path}: ${err.message}',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
