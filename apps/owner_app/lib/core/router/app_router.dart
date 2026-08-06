import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:owner_app/features/dashboard/presentation/dashboard_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/accounts_receivable_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/document_expiry_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/feedback_moderation_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/inventory_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/job_status_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/pending_approvals_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/team_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/subscription_view.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_card_detail_view.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String startup = '/';
  static const String login = '/login';
  static const String ownerDashboard = '/owner-dashboard';
  static const String forgotPassword = '/forgot-password';
  static const String accountsReceivable = '/accounts-receivable';
  static const String documentExpiry = '/document-expiry';
  static const String jobStatus = '/job-status';
  static const String pendingApprovals = '/pending-approvals';
  static const String jobCards = '/job-cards';
  static const String jobCardDetail = '/job-cards/detail';
  static const String inventory = '/inventory';
  static const String feedbackModeration = '/feedback-moderation';
  static const String team = '/team';
  static const String subscription = '/subscription';
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
      GoRoute(
        path: AppRoutes.accountsReceivable,
        name: AppRoutes.accountsReceivable,
        builder: (context, state) => const AccountsReceivableView(),
      ),
      GoRoute(
        path: AppRoutes.documentExpiry,
        name: AppRoutes.documentExpiry,
        builder: (context, state) => const DocumentExpiryView(),
      ),
      GoRoute(
        path: AppRoutes.jobStatus,
        name: AppRoutes.jobStatus,
        builder: (context, state) => const JobStatusView(),
      ),
      GoRoute(
        path: AppRoutes.pendingApprovals,
        name: AppRoutes.pendingApprovals,
        builder: (context, state) => const PendingApprovalsView(),
      ),
      GoRoute(
        path: AppRoutes.jobCards,
        name: AppRoutes.jobCards,
        builder: (context, state) => const JobCardsListView(),
      ),
      GoRoute(
        path: AppRoutes.jobCardDetail,
        name: AppRoutes.jobCardDetail,
        builder: (context, state) => const JobCardDetailView(),
      ),
      GoRoute(
        path: AppRoutes.inventory,
        name: AppRoutes.inventory,
        builder: (context, state) => const InventoryView(),
      ),
      GoRoute(
        path: AppRoutes.feedbackModeration,
        name: AppRoutes.feedbackModeration,
        builder: (context, state) => const FeedbackModerationView(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionView(),
      ),
      GoRoute(
        path: AppRoutes.team,
        name: AppRoutes.team,
        builder: (context, state) => const TeamView(),
      ),
    ],
  );
});
