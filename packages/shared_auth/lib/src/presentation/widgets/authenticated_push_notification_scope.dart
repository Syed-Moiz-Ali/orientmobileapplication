import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/network/dio_client_provider.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_core/shared_core.dart';

/// Registers this installation's FCM token after login and rotates it safely
/// when Firebase refreshes the token. Wrap each application's router with it.
class AuthenticatedPushNotificationScope extends ConsumerStatefulWidget {
  const AuthenticatedPushNotificationScope({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AuthenticatedPushNotificationScope> createState() =>
      _AuthenticatedPushNotificationScopeState();
}

class _AuthenticatedPushNotificationScopeState
    extends ConsumerState<AuthenticatedPushNotificationScope> {
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AuthState>(
      authNotifierProvider,
      _onAuthChanged,
      fireImmediately: true,
    );
  }

  void _onAuthChanged(AuthState? previous, AuthState next) {
    if (next is AuthAuthenticated) {
      _wasAuthenticated = true;
      unawaited(
        PushNotificationService.instance.registerForAuthenticatedUser((
          token,
          platform,
        ) async {
          final result = await ref.read(apiClientProvider).post<dynamic>(
            '/notifications/device-token',
            data: {'token': token, 'platform': platform},
          );
          return result is Success<dynamic>;
        }),
      );
    } else if (_wasAuthenticated && next is AuthUnauthenticated) {
      _wasAuthenticated = false;
      unawaited(PushNotificationService.instance.clearAuthenticatedUser());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
