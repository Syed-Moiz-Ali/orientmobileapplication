import 'package:dio/dio.dart';

class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      if (body.containsKey('code') && body.containsKey('data')) {
        final code = body['code'] as int? ?? 200;
        if (code >= 400) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              message: body['message'] as String? ?? 'Request failed',
            ),
          );
          return;
        }
        response.data = body['data'];
      }
    }
    handler.next(response);
  }
}
