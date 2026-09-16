import 'dart:async';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_push_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// The push source the app reacts to; replaced by a fake in tests.
final pushNotificationSourceProvider = Provider<PushNotificationSource>(
  (ref) => PushNotificationService.instance,
);

/// Turns push events into exactly two safe effects.
///
/// * A **foreground** push only refreshes canonical notification state. It never
///   navigates — the customer may be mid-booking or reviewing an estimate — and
///   it never inserts a local row, because the payload has no canonical data.
///   The Home badge follows automatically, since it reads the same state.
/// * A **tapped** push (background, or the one that launched the app) opens the
///   destination its category really leads to, or the Notifications inbox when
///   the category has none. It waits for the session to be authenticated, so no
///   customer route is ever reached before auth resolves, and it never marks
///   anything read, because a push identifies no notification.
///
/// Each message is handled once, keyed on Firebase's message id where present.
class CustomerPushScope extends ConsumerStatefulWidget {
  final Widget child;

  const CustomerPushScope({super.key, required this.child});

  @override
  ConsumerState<CustomerPushScope> createState() => _CustomerPushScopeState();
}

class _CustomerPushScopeState extends ConsumerState<CustomerPushScope> {
  /// Bounded so a long session cannot accumulate ids; duplicates arrive
  /// back-to-back (the launching message, then the same one on open).
  static const int _handledLimit = 16;

  final Set<String> _handled = <String>{};
  bool _handledWithoutId = false;
  PushMessage? _pendingOpen;
  StreamSubscription<PushMessage>? _foregroundSubscription;
  StreamSubscription<PushMessage>? _openedSubscription;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    final source = ref.read(pushNotificationSourceProvider);
    _foregroundSubscription = source.foregroundMessages.listen(_onForeground);
    _openedSubscription = source.openedMessages.listen(_onOpened);
    _authSubscription = ref.listenManual<AuthState>(authNotifierProvider, (
      _,
      next,
    ) {
      // An intent that arrived before the session was ready runs as soon as it
      // is; a signed-out session never receives a customer route.
      if (next is AuthAuthenticated) _flushPendingOpen();
    });
    // The router must be attached before an intent is executed, so the first
    // read of the launch message happens after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumeInitial());
  }

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
    _authSubscription?.close();
    super.dispose();
  }

  void _onForeground(PushMessage message) {
    // Only state converges; navigation is never hijacked by a foreground push.
    // The notifier coalesces concurrent loads, so a burst cannot become a storm.
    ref.read(customerDashboardProvider.notifier).refresh();
  }

  void _onOpened(PushMessage message) {
    if (!_claim(message)) return;
    _pendingOpen = message;
    _flushPendingOpen();
  }

  Future<void> _consumeInitial() async {
    if (!mounted) return;
    final source = ref.read(pushNotificationSourceProvider);
    final message = await source.takeInitialMessage();
    if (message == null || !mounted) return;
    _onOpened(message);
  }

  void _flushPendingOpen() {
    final message = _pendingOpen;
    if (message == null || !mounted) return;
    if (ref.read(authNotifierProvider) is! AuthAuthenticated) {
      // Session still resolving (or signed out): keep waiting rather than
      // bypassing auth. A signed-out session simply never flushes.
      return;
    }
    _pendingOpen = null;

    final route = resolveCustomerPushRoute(message.type);
    // Uses the app's own router instance, so no stale BuildContext is retained
    // across the async push lifecycle.
    ref.read(appRouterProvider).go(route.location);
  }

  /// True for the first sighting of a message. A duplicate delivery — the same
  /// launching message arriving again on `onMessageOpenedApp` — is ignored.
  bool _claim(PushMessage message) {
    final id = message.messageId;
    if (id.isEmpty) {
      if (_handledWithoutId) return false;
      _handledWithoutId = true;
      return true;
    }
    if (_handled.contains(id)) return false;
    _handled.add(id);
    if (_handled.length > _handledLimit) _handled.remove(_handled.first);
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
