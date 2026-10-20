import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';
import 'package:shared_core/src/widgets/app_text_button.dart';

/// Spec-C8 screen frame (phase-1e-i).
///
/// SafeArea + background token + breakpoint padding via [AppResponsive] +
/// max content width on expanded + optional sticky bottom action bar (ONE
/// primary button, surface with a top hairline) + keyboard-safe
/// (`resizeToAvoidBottomInset` + scrollable body) + pull-to-refresh via
/// [onRefresh] (wraps the scroll body in a [RefreshIndicator]).
///
/// All spec names in this part (`AppScaffold`, `AppAppBar`, `AppBottomNav`,
/// `AppSegmentedControl`, `AppPillTabs`) verified free in `packages/`
/// (neighbours `AppBottomNavigation`, `AppNavigationRail`, `WorkspaceAppBar`,
/// `AppTopBar`, `AppPageHeader`, `AppPageFrame` own their names and are
/// untouched); no rename needed.
///
/// ```dart
/// AppScaffold(
///   appBar: AppAppBar(title: 'Bookings', showBack: true, onBack: back),
///   onRefresh: reload,
///   stickyActionLabel: 'Save changes',
///   onStickyAction: save,
///   bottomNavigationBar: AppBottomNav(items: items, currentIndex: 0, onTap: go),
///   body: Column(children: [...]),
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe padding.
/// - Sticky bar and nav stack (action above nav) when both are given.
/// - Silent no-ops (by design, no asserts): [onRefresh] only wraps the body
///   when [scrollable] is true (an unscrollable body cannot overscroll, so a
///   refresh there is ignored); a sticky label without its callback (or vice
///   versa) shows no bar — both `stickyActionLabel` + `onStickyAction` (and
///   likewise the secondary pair) are required.
/// - Text scale 1.3x: the body scrolls and the bar labels wrap or grow.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final String? stickyActionLabel;
  final VoidCallback? onStickyAction;
  final String? stickySecondaryLabel;
  final VoidCallback? onStickySecondary;
  final Future<void> Function()? onRefresh;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final double? maxContentWidth;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.stickyActionLabel,
    this.onStickyAction,
    this.stickySecondaryLabel,
    this.onStickySecondary,
    this.onRefresh,
    this.scrollable = true,
    this.padding,
    this.maxContentWidth,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final inset = padding ?? adaptive.pagePadding;
    final cap = maxContentWidth ?? adaptive.contentMaxWidth;

    Widget content = Padding(
      padding: inset,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cap),
          child: body,
        ),
      ),
    );
    if (scrollable) {
      content = SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
        physics: onRefresh != null
            ? const AlwaysScrollableScrollPhysics()
            : null,
        child: content,
      );
      if (onRefresh != null) {
        content = RefreshIndicator(onRefresh: onRefresh!, child: content);
      }
    }

    final hasAction = stickyActionLabel != null && onStickyAction != null;
    final hasSecondary =
        stickySecondaryLabel != null && onStickySecondary != null;
    Widget? bottom;
    if (hasAction || bottomNavigationBar != null) {
      bottom = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasAction)
            _StickyActionBar(
              primaryLabel: stickyActionLabel!,
              onPrimary: onStickyAction!,
              secondaryLabel: hasSecondary ? stickySecondaryLabel : null,
              onSecondary: hasSecondary ? onStickySecondary : null,
            ),
          if (bottomNavigationBar != null) bottomNavigationBar!,
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: SafeArea(child: content),
      bottomNavigationBar: bottom,
    );
  }
}

/// Sticky bottom action bar (C9): surface, top hairline, 16 px padding +
/// safe area, ONE primary button plus an optional secondary text button.
class _StickyActionBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _StickyActionBar({
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPillButton.primary(
                label: primaryLabel,
                onPressed: onPrimary,
              ),
              if (secondaryLabel != null && onSecondary != null)
                AppTextButton(label: secondaryLabel!, onPressed: onSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
