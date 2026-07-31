import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_core/src/errors/logger_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  Future<bool>? _refreshing;

  AuthInterceptor(this._ref);

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
      err.requestOptions.headers['Authorization'] = 'Bearer $token';
      err.requestOptions.headers['X-Retry'] = 'true';
      try {
        final response = await Dio().fetch(err.requestOptions);
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
