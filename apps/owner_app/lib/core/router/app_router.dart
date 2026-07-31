import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:owner_app/features/dashboard/presentation/dashboard_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String startup = '/';
  static const String login = '/login';
  static const String ownerDashboard = '/owner-dashboard';
  static const String forgotPassword = '/forgot-password';
}

final _routerRefreshNotifier = ValueNotifier<int>(0);

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.listen<AuthState>(authNotifierProvider, (_, __) {
    _routerRefreshNotifier.value++;
  });

  return GoRouter(
    refreshListenable: _routerRefreshNotifier,
    initialLocation: AppRoutes.startup,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final matched = state.matchedLocation;

      return switch (authState) {
        AuthUnauthenticated() =>
          matched == AppRoutes.login || matched == AppRoutes.forgotPassword
              ? null
              : AppRoutes.login,
        AuthLoading() =>
          matched == AppRoutes.startup ? null : AppRoutes.startup,
        AuthError() =>
          matched == AppRoutes.login || matched == AppRoutes.forgotPassword
              ? null
              : AppRoutes.login,
        AuthAuthenticated() =>
          matched == AppRoutes.login || matched == AppRoutes.startup
              ? AppRoutes.ownerDashboard
              : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const AuthLoadingView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => LoginView(
          onLoginSuccess: () => context.go(AppRoutes.ownerDashboard),
          onForgotPassword: () => context.push(AppRoutes.forgotPassword),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) =>
            ForgotPasswordView(onBackToLogin: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.ownerDashboard,
        name: AppRoutes.ownerDashboard,
        builder: (context, state) => const DashboardView(),
      ),
    ],
  );
});
