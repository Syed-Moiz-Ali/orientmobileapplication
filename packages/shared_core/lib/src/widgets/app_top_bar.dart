import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';
import 'package:shared_core/src/widgets/notification_bell.dart';

/// Legacy compact top bar (Phase 01.2: **deprecated**).
///
/// New screens must use [WorkspaceAppBar] (workspace chrome) or
/// [AppPageHeader] (in-page headings). This widget is retained for API
/// compatibility with existing customer/staff screens owned by Phases 06–18;
/// the deprecation guard (`deprecation_guard_test.dart`) fails on any new
/// usage outside the documented allowlist.
@Deprecated('Use WorkspaceAppBar (chrome) or AppPageHeader (headings)')
class AppTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showBack;

  /// Overrides the default back behaviour (pop the current route). Used by
  /// contextual pages that can be opened directly by a deep link and therefore
  /// have nothing to pop.
  final VoidCallback? onBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = SharedCoreL10n.of(context);

    return Container(
      color: colorScheme.surface,
      // A minimum, not a fixed height: at large text scales the title may need
      // two lines, and clipping a page title is worse than a slightly taller
      // bar. At normal scale this still measures exactly 60.
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack ?? () => Navigator.maybePop(context),
              tooltip: t.topBarBackTooltip,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLow,
                side: BorderSide(color: colorScheme.outline),
                minimumSize: const Size.square(AppDimensions.touchTarget),
              ),
              icon: const DirectionalIcon(Icons.arrow_back_rounded),
            ),
          if (showBack) const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              softWrap: true,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

@Deprecated('Use WorkspaceAppBar (chrome) or AppPageHeader (headings)')
class CustomerTopBar extends StatelessWidget {
  final String avatarInitials;
  final String name;
  final int notifCount;
  final VoidCallback onNotif;

  const CustomerTopBar({
    super.key,
    required this.avatarInitials,
    required this.name,
    required this.notifCount,
    required this.onNotif,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = SharedCoreL10n.of(context);

    return Container(
      color: colorScheme.surface,
      height: AppDimensions.s64,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: Text(
                avatarInitials,
                style: TextStyle(
                  fontSize: AppDimensions.s14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.profileWelcomeBack,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          NotificationBell(
            showBadge: notifCount > 0,
            badgeCount: notifCount,
            foregroundColor: colorScheme.onSurfaceVariant,
            onPressed: onNotif,
          ),
        ],
      ),
    );
  }
}
