import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/local/storage/token_storage.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_state.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_providers.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';
import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthDatasource extends Mock implements AuthDatasource {}

/// Creates a [ProviderContainer] with mocked [tokenStorageProvider] and
/// optionally mocked [authDatasourceProvider].
ProviderContainer createContainer({
  FlutterSecureStorage? storage,
  AuthDatasource? datasource,
}) {
  return ProviderContainer(overrides: [
    if (storage != null)
      tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
    if (datasource != null)
      authDatasourceProvider.overrideWithValue(datasource),
  ]);
}

/// Sets up default storage stubs: write and read return null.
void setupStorageDefaults(MockSecureStorage storage) {
  when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});
  when(() => storage.read(key: any(named: 'key')))
      .thenAnswer((_) async => null);
}

void main() {
  group('AuthState classes', () {
    test('AuthAuthenticated stores role and token', () {
      const auth = AuthAuthenticated(role: UserRole.owner, token: 'tok');
      expect(auth.role, UserRole.owner);
      expect(auth.token, 'tok');
    });

    test('AuthUnauthenticated is const', () {
      expect(const AuthUnauthenticated(), const AuthUnauthenticated());
    });

    test('AuthLoading is const', () {
      expect(const AuthLoading(), const AuthLoading());
    });

    test('AuthError stores message', () {
      const err = AuthError('oops');
      expect(err.message, 'oops');
    });
  });

  group('AuthNotifier', () {
    test('initial state is AuthLoading', () {
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);

      final container = createContainer(storage: storage);
      addTearDown(() => container.dispose());

      expect(container.read(authNotifierProvider), isA<AuthLoading>());
    });

    test('authenticate transitions to AuthAuthenticated', () async {
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);

      final container = createContainer(
        storage: storage,
        datasource: MockAuthDatasource(),
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.advisor,
        'advisor-token',
      );

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).role, UserRole.advisor);
      expect(state.token, 'advisor-token');
    });

    test('logout transitions to AuthUnauthenticated', () async {
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);
      when(() => storage.deleteAll()).thenAnswer((_) async {});

      final container = createContainer(
        storage: storage,
        datasource: MockAuthDatasource(),
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'tok',
      );
      await container.read(authNotifierProvider.notifier).logout();

      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });

    test('authenticate persists role and token to storage', () async {
      String? capturedToken;
      String? capturedRole;
      final storage = MockSecureStorage();
      when(() => storage.write(
            key: 'auth_token',
            value: any(named: 'value'),
          )).thenAnswer((invocation) async {
        capturedToken =
            invocation.namedArguments[const Symbol('value')] as String?;
      });
      when(() => storage.write(
            key: 'auth_role',
            value: any(named: 'value'),
          )).thenAnswer((invocation) async {
        capturedRole =
            invocation.namedArguments[const Symbol('value')] as String?;
      });
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final container = createContainer(
        storage: storage,
        datasource: MockAuthDatasource(),
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.technician,
        'tech-token',
      );

      expect(capturedToken, 'tech-token');
      expect(capturedRole, 'technician');
    });

    test('logout clears storage', () async {
      bool deleteAllCalled = false;
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);
      when(() => storage.deleteAll()).thenAnswer((_) async {
        deleteAllCalled = true;
      });

      final container = createContainer(
        storage: storage,
        datasource: MockAuthDatasource(),
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'tok',
      );
      await container.read(authNotifierProvider.notifier).logout();

      expect(deleteAllCalled, isTrue);
    });

    test('updateToken changes token in state', () async {
      String? capturedToken;
      final storage = MockSecureStorage();
      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((invocation) async {
        capturedToken =
            invocation.namedArguments[const Symbol('value')] as String?;
      });
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final container = createContainer(
        storage: storage,
        datasource: MockAuthDatasource(),
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'old-token',
      );
      await container.read(authNotifierProvider.notifier).updateToken('new-token');

      final state = container.read(authNotifierProvider);
      expect((state as AuthAuthenticated).token, 'new-token');
      expect(capturedToken, 'new-token');
    });

    test('refreshSession returns false when datasource fails', () async {
      final datasource = MockAuthDatasource();
      when(() => datasource.refreshToken(any())).thenAnswer(
        (_) async => Failure(NetworkException('refresh failed')),
      );

      final storage = MockSecureStorage();
      setupStorageDefaults(storage);
      when(() => storage.read(key: 'auth_refresh_token'))
          .thenAnswer((_) async => 'refresh-tok');
      when(() => storage.deleteAll()).thenAnswer((_) async {});

      final container = createContainer(
        storage: storage,
        datasource: datasource,
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'tok',
        refreshToken: 'refresh-tok',
      );

      final result =
          await container.read(authNotifierProvider.notifier).refreshSession();
      expect(result, isFalse);
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });

    test('refreshSession returns true when datasource succeeds', () async {
      final datasource = MockAuthDatasource();
      when(() => datasource.refreshToken(any())).thenAnswer(
        (_) async =>
            Success(const AuthResult(role: UserRole.owner, token: 'new-jwt')),
      );

      final storage = MockSecureStorage();
      setupStorageDefaults(storage);
      when(() => storage.read(key: 'auth_refresh_token'))
          .thenAnswer((_) async => 'refresh-tok');

      final container = createContainer(
        storage: storage,
        datasource: datasource,
      );
      addTearDown(() => container.dispose());

      await container.read(authNotifierProvider.notifier).authenticate(
        UserRole.owner,
        'old-jwt',
        refreshToken: 'refresh-tok',
      );

      final result =
          await container.read(authNotifierProvider.notifier).refreshSession();
      expect(result, isTrue);
      final state = container.read(authNotifierProvider);
      expect((state as AuthAuthenticated).token, 'new-jwt');
    });
  });
}
