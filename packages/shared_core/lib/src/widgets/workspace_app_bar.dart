import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/l10n/gen/shared_core_localizations.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';
import 'package:shared_core/src/widgets/offline_status_pill.dart';

/// The single shared workspace header pattern (Phase 04).
///
/// Replaces the four bespoke app bars with one composition: a title with a
/// context subtitle, an optional leading (brand/context icon or a back button),
/// an optional contextual selector (period, branch…), an optional offline
/// telemetry pill, an optional omnichannel search trigger, trailing actions
/// (notifications, profile, refresh) and an optional bottom (tabs/divider).
///
/// It is a plain [PreferredSizeWidget] so it drops straight into
/// `Scaffold.appBar` / `DashboardShell.appBar`.
///
/// Concept A Phase 04 composition:
/// * **Frosted glass** ([frosted]) — translucent surface with a
///   `BackdropFilter(sigma: 10)` blur, permitted only on sticky navigation
///   headers. It falls back to an opaque surface when the platform requests
///   reduced motion/transparency (accessibility), keeping text contrast.
/// * **Offline telemetry pill** ([showOfflineStatus]) — the [OfflineStatusPill],
///   reading the same connectivity source as [OfflineBanner] (never duplicated
///   state).
/// * **Omnichannel search trigger** ([onSearch]) — a discoverable, always-tappable
///   search affordance with a platform-correct shortcut hint. Pair it with
///   [WorkspaceSearchShortcuts] to bind ⌘K / Ctrl+K.
///
/// All three are opt-in so existing callers, downstream behaviour and goldens
/// are preserved by default.
class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;

  /// When true and [leading] is null, renders a localized back button.
  final bool showBack;
  final VoidCallback? onBack;

  /// Contextual control shown before [actions] (e.g. a period/date selector).
  final Widget? contextSelector;

  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  /// Draws a 1 px hairline separator when no [bottom] is supplied.
  final bool showDivider;
  final double toolbarHeight;
  final double titleSpacing;

  /// Renders a translucent frosted-glass surface (Concept A sticky header).
  final bool frosted;

  /// Shows the integrated [OfflineStatusPill].
  final bool showOfflineStatus;

  /// Local changes queued for the next sync pass (drives the pill).
  final int? offlinePendingCount;

  /// When non-null, renders the omnichannel search trigger.
  final VoidCallback? onSearch;

  /// Overrides the shortcut hint shown on the trigger (default: `⌘K` on Apple
  /// platforms, `Ctrl K` elsewhere).
  final String? searchShortcutLabel;

  const WorkspaceAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.showBack = false,
    this.onBack,
    this.contextSelector,
    this.actions = const [],
    this.bottom,
    this.showDivider = true,
    this.toolbarHeight = 64,
    this.titleSpacing = AppDimensions.s16,
    this.frosted = false,
    this.showOfflineStatus = false,
    this.offlinePendingCount,
    this.onSearch,
    this.searchShortcutLabel,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  /// Platform-correct default shortcut hint.
  static String defaultSearchShortcutLabel() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
        return '⌘K';
      default:
        return 'Ctrl K';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    final Widget? resolvedLeading =
        leading ??
        (showBack
            ? IconButton(
                onPressed: onBack ?? () => Navigator.maybePop(context),
                tooltip: t.topBarBackTooltip,
                icon: const DirectionalIcon(Icons.arrow_back_rounded),
              )
            : null);

    // Accessibility: honour the platform's reduced-motion/transparency request.
    final reduceTransparency =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final useFrost = frosted && !reduceTransparency;
    final background = useFrost
        ? colors.surface.withValues(alpha: 0.72)
        : colors.surface;

    final appBar = AppBar(
      backgroundColor: background,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: theme.brightness,
      ),
      toolbarHeight: toolbarHeight,
      titleSpacing: resolvedLeading == null ? titleSpacing : 0,
      leading: resolvedLeading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onSearch != null) _buildSearchTrigger(context, t),
        if (showOfflineStatus) ...[
          const SizedBox(width: AppDimensions.s8),
          OfflineStatusPill(pendingSyncCount: offlinePendingCount),
        ],
        if (onSearch != null || showOfflineStatus)
          const SizedBox(width: AppDimensions.s4),
        if (contextSelector != null) ...[
          contextSelector!,
          const SizedBox(width: AppDimensions.s4),
        ],
        ...actions,
        const SizedBox(width: AppDimensions.s8),
      ],
      bottom:
          bottom ??
          (showDivider
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Divider(height: 1, color: colors.outline),
                )
              : null),
    );

    if (!useFrost) return appBar;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: appBar,
      ),
    );
  }

  Widget _buildSearchTrigger(BuildContext context, SharedCoreLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final shortcut = searchShortcutLabel ?? defaultSearchShortcutLabel();
    final tooltip = '${t.workspaceSearchTooltip} ($shortcut)';

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkWell(
          onTap: onSearch,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Container(
            height: 36,
            width: wide ? null : 36,
            padding: EdgeInsets.symmetric(
              horizontal: wide ? AppDimensions.s10 : 0,
            ),
            decoration: BoxDecoration(
              color: semantic.surfaceRaised,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: semantic.borderDefault),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.onSurfaceVariant,
                ),
                if (wide) ...[
                  const SizedBox(width: AppDimensions.s8),
                  Flexible(
                    child: Text(
                      t.workspaceSearchTooltip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: semantic.surfaceSunken,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                      border: Border.all(color: semantic.borderDefault),
                    ),
                    child: Text(
                      shortcut,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Binds the omnichannel search shortcut (**⌘K** on Apple platforms, **Ctrl+K**
/// elsewhere) to [onSearch] for any focused descendant of [child].
///
/// Wrap the shell (typically the `Scaffold`) with this and pass the same
/// [onSearch] used by [WorkspaceAppBar.onSearch]. The always-visible app-bar
/// search trigger is the discoverable fallback on platforms without a Command
/// key. Registration of both `meta+K` and `control+K` makes the shortcut work
/// across macOS, Windows, Linux and web without platform branching at call
/// sites.
class WorkspaceSearchShortcuts extends StatelessWidget {
  final VoidCallback? onSearch;
  final Widget child;

  /// Requests initial focus so the shortcut is live without the user tapping
  /// first. Defaults to true (keyboard-first shells).
  final bool autofocus;

  const WorkspaceSearchShortcuts({
    super.key,
    required this.onSearch,
    required this.child,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final cb = onSearch;
    if (cb == null) return child;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): cb,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): cb,
      },
      child: Focus(autofocus: autofocus, child: child),
    );
  }
}
