import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_state.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;

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
    if (err.response?.statusCode == 401 &&
        err.requestOptions.headers['X-Retry'] != 'true') {
      final notifier = _ref.read(authNotifierProvider.notifier);
      final refreshed = await notifier.refreshSession();
      if (refreshed) {
        final authState = _ref.read(authNotifierProvider);
        if (authState case AuthAuthenticated(:final token)) {
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          err.requestOptions.headers['X-Retry'] = 'true';
          try {
            final response = await Dio().fetch(err.requestOptions);
            handler.resolve(response);
            return;
          } catch (_) {}
        }
      }
    }
    handler.next(err);
  }
}
