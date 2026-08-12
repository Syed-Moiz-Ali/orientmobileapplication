import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/widgets/exit_confirmation_dialog.dart';
import 'package:shared_core/src/widgets/offline_banner.dart';

class DashboardShell extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const DashboardShell({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExitConfirmationWrapper(
      child: Scaffold(
        appBar: appBar,
        // FE-FIX (pre-deployment): honest offline indicator — offline writes
        // are queued, so users must know they will sync later.
        body: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: FocusTraversalGroup(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}
