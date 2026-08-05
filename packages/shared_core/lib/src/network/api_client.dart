import 'package:dio/dio.dart';
import 'package:shared_core/src/errors/result.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    return _request<T>(
      () => _dio.get(path, queryParameters: queryParams),
      fromJson,
    );
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request<T>(
      () => _dio.post(path, data: data),
      fromJson,
    );
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request<T>(
      () => _dio.put(path, data: data),
      fromJson,
    );
  }

  Future<Result<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    return _request<T>(
      () => _dio.delete(path),
      fromJson,
    );
  }

  Future<Result<T>> _request<T>(
    Future<Response> Function() request,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map) {
        final code = data['code'];
        if (code is int && code >= 400) {
          return Failure(_mapError(code, data['message']?.toString()));
        }
      }
      if (fromJson != null && data != null) {
        return Success(fromJson(data));
      }
      return Success(data as T);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String? ?? e.message
          : e.message ?? 'Request failed';
      return Failure(_mapError(e.response?.statusCode, msg));
    }
  }

  AppException _mapError(int? statusCode, String? message) {
    if (statusCode == 401) return UnauthorizedException(message ?? 'Unauthorized');
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ValidationException(message ?? 'Request failed');
    }
    if (statusCode != null && statusCode >= 500) {
      return UnknownException(message ?? 'Server error');
    }
    return NetworkException(message ?? 'Request failed');
  }
}
