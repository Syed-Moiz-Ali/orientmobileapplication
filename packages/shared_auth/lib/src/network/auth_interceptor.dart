import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_core/src/errors/logger_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final Dio _dio;
  Future<bool>? _refreshing;

  AuthInterceptor(this._ref, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authState = _ref.read(authNotifierProvider);
    if (authState case AuthAuthenticated(:final token)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.headers['X-Retry'] == 'true') {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    final authState = _ref.read(authNotifierProvider);
    if (authState case AuthAuthenticated(:final token)) {
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
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['X-Retry'] = 'true';
      try {
        // Re-dispatch through the SAME Dio instance so the envelope
        // interceptor still unwraps the retried response.
        final response = await _dio.fetch(options);
        handler.resolve(response);
        return;
      } catch (e, st) {
        _ref
            .read(loggerProvider)
            .e(
              'Auth retry failed for ${err.requestOptions.path}',
              error: e,
              stackTrace: st,
            );
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshOnce() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    return notifier.refreshSession();
  }
}
