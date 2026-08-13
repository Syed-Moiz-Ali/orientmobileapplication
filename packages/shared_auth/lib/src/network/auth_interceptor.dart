import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_core/src/errors/logger_provider.dart';
import 'package:shared_core/src/local/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final Dio _dio;
  Future<bool>? _refreshing;

  AuthInterceptor(this._ref, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState case AuthAuthenticated(:final token)) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      final storage = _ref.read(tokenStorageProvider);
      final storedToken = await storage.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $storedToken';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // FIX (audit QA BUG-023): never auto-refresh the /auth/logout call. The
    // token may already be expired; refreshing here re-enters the logout flow
    // and (with a revoked/failing refresh token) deadlocks on the single-flight
    // refresh future, leaving the user unable to log out.
    final path = err.requestOptions.path;
    if (err.response?.statusCode != 401 ||
        err.requestOptions.headers['X-Retry'] == 'true' ||
        path.endsWith('/auth/logout') ||
        path.endsWith('/auth/refresh')) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    final storage = _ref.read(tokenStorageProvider);
    final currentToken = await storage.getToken();
    final authState = _ref.read(authNotifierProvider);
    final token = authState is AuthAuthenticated
        ? authState.token
        : currentToken;

    if (token != null && token.isNotEmpty) {
      final options = RequestOptions(
        method: err.requestOptions.method,
        baseUrl: _dio.options.baseUrl,
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
