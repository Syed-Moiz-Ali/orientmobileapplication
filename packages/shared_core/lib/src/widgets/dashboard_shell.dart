import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/widgets/exit_confirmation_dialog.dart';
import 'package:shared_core/src/widgets/offline_banner.dart';

/// Shared authenticated frame: app bar, offline banner, focus traversal,
/// bottom navigation / drawer, floating action button and exit confirmation.
///
/// System bar styling is provided once here as an [AnnotatedRegion] instead of
/// being pushed imperatively from individual screens, so status/navigation bar
/// contrast stays correct in both light and dark themes.
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        // iOS expresses this as the background brightness.
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: colors.surface,
        systemNavigationBarIconBrightness: iconBrightness,
      ),
      child: ExitConfirmationWrapper(
        child: Scaffold(
          appBar: appBar,
          // FE-FIX (pre-deployment): honest offline indicator — offline writes
          // are queued, so users must know they will sync later.
          body: ColoredBox(
            color: theme.scaffoldBackgroundColor,
            // The app bar owns the status bar inset when it exists. Without one
            // (the Customer workspace has no app bar) the shell must inset the
            // body itself so content never renders under the system status bar.
            child: SafeArea(
              top: appBar == null,
              left: false,
              right: false,
              bottom: false,
              child: Column(
                children: [
                  const OfflineBanner(),
                  Expanded(
                    child: FocusTraversalGroup(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: appBar != null,
                        child: body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        ),
      ),
    );
  }
}
