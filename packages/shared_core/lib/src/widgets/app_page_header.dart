import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// A consistent task-oriented heading for pages and workspace sections.
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leading;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final Widget? trailing;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leading,
    this.primaryAction,
    this.secondaryAction,
    this.trailing,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final resolvedActions = <Widget>[
      ...actions,
      if (secondaryAction != null) secondaryAction!,
      if (primaryAction != null) primaryAction!,
      if (trailing != null) trailing!,
    ];

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: colors.primary, size: 24),
            child: leading!,
          ),
          const SizedBox(width: AppDimensions.s12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
              ],
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.s4),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (resolvedActions.isEmpty) return identity;

    final actionBar = Wrap(
      spacing: AppDimensions.s8,
      runSpacing: AppDimensions.s8,
      children: resolvedActions,
    );

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          identity,
          const SizedBox(height: AppDimensions.s14),
          Align(alignment: Alignment.centerLeft, child: actionBar),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: identity),
        const SizedBox(width: AppDimensions.s24),
        actionBar,
      ],
    );
  }
}
