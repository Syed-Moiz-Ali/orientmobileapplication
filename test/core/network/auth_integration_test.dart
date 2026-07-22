import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orientmobileapplication/core/local/storage/token_storage.dart';
import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/core/network/auth_interceptor.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_providers.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_state.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthDatasource extends Mock implements AuthDatasource {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

/// Sets up storage stubs needed for basic operation.
void setupStorageDefaults(MockSecureStorage storage) {
  when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});
  when(() => storage.read(key: any(named: 'key')))
      .thenAnswer((_) async => null);
  when(() => storage.deleteAll()).thenAnswer((_) async {});
}

final _interceptorProvider =
    Provider<AuthInterceptor>((ref) => AuthInterceptor(ref));

DioException _dioException401({Map<String, dynamic>? data}) {
  final response = Response(
    requestOptions: RequestOptions(path: '/api/some-endpoint'),
    statusCode: 401,
    data: data ?? {'message': 'Unauthorized'},
  );
  return DioException(
    requestOptions: RequestOptions(path: '/api/some-endpoint'),
    response: response,
    message: 'Unauthorized',
  );
}

/// Awaits all pending microtasks so fire-and-forget async work completes.
Future<void> flushMicrotasks() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('Auth integration: login → request → 401 retry → logout', () {
    late MockSecureStorage storage;
    late MockAuthDatasource datasource;
    late ProviderContainer container;
    late AuthInterceptor interceptor;

    setUp(() async {
      storage = MockSecureStorage();
      setupStorageDefaults(storage);

      datasource = MockAuthDatasource();
      when(() => datasource.authenticate(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async =>
              Success(const AuthResult(role: UserRole.owner, token: 'login-jwt')));

      container = ProviderContainer(overrides: [
        tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
        authDatasourceProvider.overrideWithValue(datasource),
        authNotifierProvider.overrideWith(() => AuthNotifier()),
      ]);

      // Let _restoreSession settle so state is stable
      await flushMicrotasks();
      interceptor = container.read(_interceptorProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('login → onRequest adds Bearer header with token', () async {
      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'login-jwt',
      );
      await flushMicrotasks();

      final options = RequestOptions(path: '/api/data');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer login-jwt');
      verify(() => handler.next(options)).called(1);
    });

    test('401 retry → refreshSession called and retry attempted as fallback',
        () async {
      when(() => storage.read(key: 'auth_refresh_token'))
          .thenAnswer((_) async => 'refresh-token');
      when(() => datasource.refreshToken(any())).thenAnswer((_) async =>
          Success(const AuthResult(role: UserRole.owner, token: 'refreshed-jwt')));

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'expired-jwt',
        refreshToken: 'refresh-token',
      );
      await flushMicrotasks();

      final options = RequestOptions(path: '/api/data');
      options.headers['Authorization'] = 'Bearer expired-jwt';
      final err = _dioException401();
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);
      await flushMicrotasks();

      verify(() => datasource.refreshToken('refresh-token')).called(1);

      final authState = container.read(authNotifierProvider);
      expect((authState as AuthAuthenticated).token, 'refreshed-jwt');

      verify(() => handler.next(err)).called(1);
    });

    test('logout → onRequest does NOT add Authorization header', () async {
      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'tok',
      );
      await container.read(authNotifierProvider.notifier).logout();
      await flushMicrotasks();

      final options = RequestOptions(path: '/api/data');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });

    test('session restore from storage on app start', () async {
      when(() => storage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'stored-jwt');
      when(() => storage.read(key: 'auth_role'))
          .thenAnswer((_) async => 'advisor');
      when(() => storage.read(key: 'auth_refresh_token'))
          .thenAnswer((_) async => 'stored-refresh');

      final restoreContainer = ProviderContainer(overrides: [
        tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
        authDatasourceProvider.overrideWithValue(datasource),
        authNotifierProvider.overrideWith(() => AuthNotifier()),
      ]);
      addTearDown(() => restoreContainer.dispose());

      // Reading the provider triggers build() which fires _restoreSession()
      restoreContainer.read(authNotifierProvider);
      // Let _restoreSession complete
      await flushMicrotasks();

      final authState = restoreContainer.read(authNotifierProvider);
      expect(authState, isA<AuthAuthenticated>());
      expect((authState as AuthAuthenticated).token, 'stored-jwt');
      expect(authState.role, UserRole.advisor);
    });
  });
}
