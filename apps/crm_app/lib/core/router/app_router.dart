import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_dashboard_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String crmDashboard = '/crm_dashboard_view';
}

final _routerRefreshNotifier = ValueNotifier<void>(null);

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.listen<AuthState>(authNotifierProvider, (_, __) {
    _routerRefreshNotifier.value = null;
  });

  return GoRouter(
    refreshListenable: _routerRefreshNotifier,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final matched = state.matchedLocation;

      return switch (authState) {
        AuthUnauthenticated() =>
          matched == AppRoutes.login ? null : AppRoutes.login,
        AuthLoading() => null,
        AuthError() =>
          matched == AppRoutes.login ? null : AppRoutes.login,
        AuthAuthenticated() =>
          matched == AppRoutes.login ? AppRoutes.crmDashboard : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => LoginView(
          onLoginSuccess: () => context.go(AppRoutes.crmDashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.crmDashboard,
        name: AppRoutes.crmDashboard,
        builder: (context, state) => const CrmDashboardView(),
      ),
    ],
  );
});
