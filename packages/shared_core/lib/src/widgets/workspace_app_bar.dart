import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// The single shared workspace header pattern (Phase 04).
///
/// Replaces the four bespoke app bars with one composition: a title with a
/// context subtitle, an optional leading (brand/context icon or a back button),
/// an optional contextual selector (period, branch…), trailing actions
/// (notifications, profile, refresh) and an optional bottom (tabs/divider).
///
/// It is a plain [PreferredSizeWidget] so it drops straight into
/// `Scaffold.appBar` / `DashboardShell.appBar`. Existing app bars are migrated
/// to it by their owning feature/app phases; the shared pattern is finalized
/// here.
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
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

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

    return AppBar(
      backgroundColor: colors.surface,
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
  }
}
