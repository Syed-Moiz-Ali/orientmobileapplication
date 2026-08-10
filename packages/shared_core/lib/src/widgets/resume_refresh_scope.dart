import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FE-FIX (pre-deployment connectivity pass): refreshes app data whenever the
/// app returns to the foreground. Without this, a change made in one app
/// (e.g. a customer approving an estimate) stays invisible in another app
/// until a manual refresh. Wrap the MaterialApp with app-specific actions.
class ResumeRefreshScope extends ConsumerStatefulWidget {
  final Widget child;
  final Future<void> Function()? onResumed;

  const ResumeRefreshScope({super.key, required this.child, this.onResumed});

  @override
  ConsumerState<ResumeRefreshScope> createState() => _ResumeRefreshScopeState();
}

class _ResumeRefreshScopeState extends ConsumerState<ResumeRefreshScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onResumed?.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
