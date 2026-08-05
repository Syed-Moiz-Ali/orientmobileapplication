sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(error: final error) => failure(error),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

sealed class AppException {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
