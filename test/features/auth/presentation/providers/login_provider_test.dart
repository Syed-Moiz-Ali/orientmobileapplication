import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/core/local/storage/token_storage.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/domain/usecases/authenticate.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_providers.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_state.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/login_provider.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthenticate extends Mock implements Authenticate {}

/// Sets up default storage stubs: write and read return null.
void setupStorageDefaults(MockSecureStorage storage) {
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => storage.read(key: any(named: 'key')),
  ).thenAnswer((_) async => null);
}

void main() {
  group('LoginState', () {
    test('defaults are correct', () {
      const state = LoginState();
      expect(state.isPasswordVisible, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates isPasswordVisible', () {
      const state = LoginState();
      final copy = state.copyWith(isPasswordVisible: true);
      expect(copy.isPasswordVisible, true);
      expect(copy.isLoading, false);
      expect(copy.errorMessage, isNull);
    });

    test('copyWith updates isLoading', () {
      const state = LoginState();
      final copy = state.copyWith(isLoading: true);
      expect(copy.isLoading, true);
      expect(copy.isPasswordVisible, false);
    });

    test('copyWith updates errorMessage', () {
      const state = LoginState();
      final copy = state.copyWith(errorMessage: 'Error!');
      expect(copy.errorMessage, 'Error!');
    });

    test('copyWith clears errorMessage when passing null', () {
      const state = LoginState(errorMessage: 'Old error');
      final copy = state.copyWith();
      expect(copy.errorMessage, isNull);
    });
  });

  group('LoginNotifier', () {
    test(
      'login with empty username returns false and sets errorMessage',
      () async {
        final storage = MockSecureStorage();
        setupStorageDefaults(storage);

        final container = ProviderContainer(
          overrides: [
            tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
            authenticateProvider.overrideWithValue(MockAuthenticate()),
            authNotifierProvider.overrideWith(() => AuthNotifier()),
          ],
        );
        addTearDown(() => container.dispose());

        final result = await container
            .read(loginNotifierProvider.notifier)
            .login(role: UserRole.owner, username: '', password: 'pass');

        expect(result, isFalse);
        final state = container.read(loginNotifierProvider);
        expect(state.errorMessage, 'Please enter username and password.');
        expect(state.isLoading, isFalse);
      },
    );

    test(
      'login with empty password returns false and sets errorMessage',
      () async {
        final storage = MockSecureStorage();
        setupStorageDefaults(storage);

        final container = ProviderContainer(
          overrides: [
            tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
            authenticateProvider.overrideWithValue(MockAuthenticate()),
            authNotifierProvider.overrideWith(() => AuthNotifier()),
          ],
        );
        addTearDown(() => container.dispose());

        final result = await container
            .read(loginNotifierProvider.notifier)
            .login(role: UserRole.owner, username: 'user', password: '');

        expect(result, isFalse);
        final state = container.read(loginNotifierProvider);
        expect(state.errorMessage, 'Please enter username and password.');
      },
    );

    test(
      'login with auth failure returns false and sets errorMessage',
      () async {
        final storage = MockSecureStorage();
        setupStorageDefaults(storage);

        final authenticate = MockAuthenticate();
        when(
          () => authenticate.call(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Failure(NetworkException('Invalid credentials')),
        );

        final container = ProviderContainer(
          overrides: [
            tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
            authenticateProvider.overrideWithValue(authenticate),
            authNotifierProvider.overrideWith(() => AuthNotifier()),
          ],
        );
        addTearDown(() => container.dispose());

        final result = await container
            .read(loginNotifierProvider.notifier)
            .login(role: UserRole.owner, username: 'user', password: 'wrong');

        expect(result, isFalse);
        final state = container.read(loginNotifierProvider);
        expect(state.errorMessage, 'Invalid credentials');
        expect(state.isLoading, isFalse);
      },
    );

    test('login with auth success returns true and sets auth state', () async {
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);

      final authenticate = MockAuthenticate();
      when(
        () => authenticate.call(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async =>
            Success(const AuthResult(role: UserRole.owner, token: 'jwt-token')),
      );

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
          authenticateProvider.overrideWithValue(authenticate),
          authNotifierProvider.overrideWith(() => AuthNotifier()),
        ],
      );
      addTearDown(() => container.dispose());

      final result = await container
          .read(loginNotifierProvider.notifier)
          .login(role: UserRole.owner, username: 'user', password: 'pass');

      expect(result, isTrue);
      final loginState = container.read(loginNotifierProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.errorMessage, isNull);

      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthAuthenticated>());
      expect((authState as AuthAuthenticated).token, 'jwt-token');
    });

    test('togglePasswordVisibility flips the flag', () {
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
          authenticateProvider.overrideWithValue(MockAuthenticate()),
          authNotifierProvider.overrideWith(() => AuthNotifier()),
        ],
      );
      addTearDown(() => container.dispose());

      expect(container.read(loginNotifierProvider).isPasswordVisible, isFalse);

      container.read(loginNotifierProvider.notifier).togglePasswordVisibility();
      expect(container.read(loginNotifierProvider).isPasswordVisible, isTrue);

      container.read(loginNotifierProvider.notifier).togglePasswordVisibility();
      expect(container.read(loginNotifierProvider).isPasswordVisible, isFalse);
    });

    test('clearError clears the error message', () async {
      final storage = MockSecureStorage();
      setupStorageDefaults(storage);

      final authenticate = MockAuthenticate();
      when(
        () => authenticate.call(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Failure(NetworkException('oops')));

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(TokenStorage(storage)),
          authenticateProvider.overrideWithValue(authenticate),
          authNotifierProvider.overrideWith(() => AuthNotifier()),
        ],
      );
      addTearDown(() => container.dispose());

      await container
          .read(loginNotifierProvider.notifier)
          .login(role: UserRole.owner, username: 'u', password: 'p');

      expect(container.read(loginNotifierProvider).errorMessage, 'oops');

      container.read(loginNotifierProvider.notifier).clearError();
      expect(container.read(loginNotifierProvider).errorMessage, isNull);
    });
  });
}
