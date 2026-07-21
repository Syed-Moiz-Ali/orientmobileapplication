import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_providers.dart';

class LoginState {
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isPasswordVisible,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<bool> login({
    required UserRole role,
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter username and password.');
      return false;
    }

    state = state.copyWith(errorMessage: null, isLoading: true);

    final result = await ref.read(authenticateProvider).call(
      role: role,
      username: username,
      password: password,
    );

    state = result.when(
      success: (_) => state.copyWith(isLoading: false),
      failure: (error) => state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
    );

    return result is Success;
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final loginNotifierProvider =
    NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);
