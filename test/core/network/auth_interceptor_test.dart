import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orientmobileapplication/core/local/storage/token_storage.dart';
import 'package:orientmobileapplication/core/network/auth_interceptor.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_state.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_providers.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockDatasource extends Mock implements AuthDatasource {}

final _interceptorProvider =
    Provider<AuthInterceptor>((ref) => AuthInterceptor(ref));

void main() {
  group('AuthInterceptor', () {
    test('onRequest adds Bearer token when authenticated', () async {
      final storage = MockSecureStorage();
      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(overrides: [
        tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
        authDatasourceProvider.overrideWithValue(MockDatasource()),
        authNotifierProvider.overrideWith(() => AuthNotifier()),
      ]);
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'test-token',
      );

      final interceptor = container.read(_interceptorProvider);
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test-token');
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest does not add Authorization when unauthenticated', () {
      final storage = MockSecureStorage();
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(overrides: [
        tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
        authDatasourceProvider.overrideWithValue(MockDatasource()),
        authNotifierProvider.overrideWith(() => AuthNotifier()),
      ]);
      addTearDown(() => container.dispose());

      final interceptor = container.read(_interceptorProvider);
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });
  });
}
