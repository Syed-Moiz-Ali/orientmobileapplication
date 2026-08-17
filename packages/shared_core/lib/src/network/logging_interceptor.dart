import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  /// Field names whose values must be masked in logged request bodies.
  static const Set<String> _piiKeys = {
    'authorization',
    'password',
    'newpassword',
    'otp',
    'phone',
    'mobile',
    'mobilenumber',
    'token',
    'refreshtoken',
  };

  LoggingInterceptor({Logger? logger})
      : _logger =
            logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 1,
                errorMethodCount: 3,
                printEmojis: false,
              ),
            );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('${options.method} ${options.path}');
    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      final token = headers['Authorization'];
      headers['Authorization'] = token is String && token.length > 12
          ? 'Bearer ${token.substring(7, 12)}…'
          : 'Bearer ***';
    }
    if (headers.isNotEmpty) {
      _logger.t('Headers: $headers');
    }
    if (options.data != null) {
      _logger.t('Body: ${_maskBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('${response.statusCode} ${response.requestOptions.path}');
    if (response.data is Map || response.data is List) {
      _logger.t('Response: ${_maskBody(response.data)}');
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

  dynamic _maskBody(dynamic body) {
    if (body is Map) {
      final masked = <String, dynamic>{};
      body.forEach((key, value) {
        final k = key.toString().toLowerCase();
        masked[key.toString()] = _piiKeys.contains(k) ? '***' : _maskBody(value);
      });
      return masked;
    }
    if (body is List) {
      return body.map(_maskBody).toList();
    }
    if (body is FormData) {
      final fields = body.fields.map((f) => _piiKeys.contains(f.key.toLowerCase())
          ? MapEntry(f.key, '***')
          : f);
      return 'FormData(fields: $fields, files: ${body.files.length})';
    }
    return body;
  }
}
