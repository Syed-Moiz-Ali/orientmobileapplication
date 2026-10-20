import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Standard bar height (spec C8: 56, no elevation).
const double _kBarHeight = 56;

/// Spec-C8 app bar (phase-1e-i).
///
/// 56 high, no elevation, left (default) or centered title (titleLarge),
/// back button with a >= 48 dp hit area that mirrors in RTL, optional
/// hairline below ([showDivider] — wire it to scroll position with a
/// `NotificationListener<ScrollNotification>` in the screen), optional
/// large collapsing title via [AppAppBar.large] (a [SliverAppBar] for
/// `CustomScrollView` slivers, 32 -> 20; NOT for `Scaffold.appBar`).
///
/// Do NOT place [AppAppBar.large] in `Scaffold.appBar`: it builds a
/// [SliverAppBar], which is only valid inside a sliver viewport
/// (`CustomScrollView` slivers). In `Scaffold.appBar` use the default
/// constructor. No runtime throw — misuse surfaces as a framework error
/// from the sliver protocol; this doc line plus the `SliverAppBar`-type
/// test below are the guard.
///
/// Name verified free in `packages/` (neighbours `WorkspaceAppBar` and
/// `AppTopBar` own their names and are untouched); no rename needed.
///
/// ```dart
/// AppScaffold(
///   appBar: AppAppBar(title: 'Bookings', showBack: true, onBack: back),
///   body: ...,
/// )
/// CustomScrollView(slivers: [AppAppBar.large(title: 'Activity'), ...])
/// ```
///
/// - Tokens only (theme `AppBarTheme` + `ColorScheme`), caller-supplied
///   title, Directional-safe back button. Text scale 1.3x: the title
///   ellipsizes (secondary truncation) instead of overflowing.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showDivider;
  final bool _large;

  const AppAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.showDivider = false,
  }) : _large = false;

  /// Large collapsing variant: pinned [SliverAppBar], expanded title at
  /// 32 (titleLarge x 1.6) collapsing to 20. Use in slivers only.
  const AppAppBar.large({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.backgroundColor,
  })  : centerTitle = false,
        showDivider = false,
        _large = true;

  @override
  Size get preferredSize => const Size.fromHeight(_kBarHeight);

  @override
  Widget build(BuildContext context) {
    if (_large) return _buildSliver(context);
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: _kBarHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showBack ? _BackButton(onPressed: onBack) : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: actions,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: scheme.outline),
            )
          : null,
    );
  }

  Widget _buildSliver(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      // 144 = 3 x xxxl hero gap; written via the token so the geometry
      // stays in the spacing scale with identical visuals.
      expandedHeight: AppSpacing.xxxl * 3,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      leading: showBack ? _BackButton(onPressed: onBack) : null,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        // Page padding (start) + standard gap (bottom); values match the
        // previous 20/16 literals exactly.
        titlePadding: const EdgeInsetsDirectional.only(
          start: AppSpacing.screenPaddingPhone,
          bottom: AppSpacing.lg,
        ),
        expandedTitleScale: 1.6,
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

/// Back button: 48 x 48 hit area, 24 px glyph that mirrors in RTL, tooltip
/// from [MaterialLocalizations] (announced by screen readers).
class _BackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _BackButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tooltip = MaterialLocalizations.of(context).backButtonTooltip;
    return Semantics(
      button: true,
      label: tooltip,
      child: SizedBox(
        width: 48,
        height: 48,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: const Center(
            child: DirectionalIcon(Icons.arrow_back_rounded, size: 24),
          ),
        ),
      ),
    );
  }
}
