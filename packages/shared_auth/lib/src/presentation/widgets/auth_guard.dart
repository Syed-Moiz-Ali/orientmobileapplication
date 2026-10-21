import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/widgets/auth_loading_view.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/src/user_role.dart';

/// Route/session guard for protected surfaces (Phase 01.2, no new backend).
///
/// Reads [authNotifierProvider] and renders:
/// - [loadingView] (default [AuthLoadingView]) while the session restores;
/// - [unauthenticatedBuilder] (or [AuthSessionExpiredView] when
///   [showSessionExpired] is true) when signed out / role-denied;
/// - [child] when authenticated (and, if [allowedRoles] is set, authorized).
///
/// Role denial fails closed to the same unauthenticated surface — never to a
/// privileged fallback.
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final List<UserRole>? allowedRoles;
  final Widget Function(BuildContext context)? unauthenticatedBuilder;
  final Widget? loadingView;
  final bool showSessionExpired;
  final VoidCallback? onSignIn;

  const AuthGuard({
    super.key,
    required this.child,
    this.allowedRoles,
    this.unauthenticatedBuilder,
    this.loadingView,
    this.showSessionExpired = false,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);

    return switch (state) {
      AuthLoading() => loadingView ?? const AuthLoadingView(),
      AuthAuthenticated(:final role) =>
        (allowedRoles == null || allowedRoles!.contains(role))
            ? child
            : _denied(context),
      _ => _denied(context),
    };
  }

  Widget _denied(BuildContext context) {
    if (unauthenticatedBuilder != null) {
      return unauthenticatedBuilder!(context);
    }
    return AuthSessionExpiredView(
      onSignIn: onSignIn,
      compact: !showSessionExpired,
    );
  }
}

/// Session-expired notice (Phase 01.2, no new backend).
///
/// Shown after a 401-driven [AuthNotifier.invalidateSession] or whenever a
/// guard denies access. One message, one primary re-authenticate action plus
/// implicit dismiss — decidable in seconds. [compact] renders the inline
/// notice; expanded renders the full title + message + action.
class AuthSessionExpiredView extends StatelessWidget {
  final VoidCallback? onSignIn;
  final bool compact;

  const AuthSessionExpiredView({
    super.key,
    this.onSignIn,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedAuthL10n.of(context);

    final mark = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: semantic.warning.subtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: semantic.warning.border),
      ),
      child: Icon(
        Icons.timer_off_outlined,
        color: semantic.warning.base,
        size: AppDimensions.iconLg,
      ),
    );

    if (compact) {
      return Row(
        children: [
          mark,
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              t.authSessionExpiredMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      label: t.authSessionExpiredTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pinned start: a stretch column would otherwise force the 44px
          // mark to full width.
          Align(alignment: AlignmentDirectional.centerStart, child: mark),
          const SizedBox(height: AppDimensions.s16),
          Text(
            t.authSessionExpiredTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            t.authSessionExpiredMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
    if (onSignIn != null) ...[
      const SizedBox(height: AppDimensions.s16),
      AppPillButton.primary(
        label: t.authSessionExpiredAction,
        icon: Icons.login_rounded,
        onPressed: onSignIn,
      ),
    ],
        ],
      ),
    );
  }
}
