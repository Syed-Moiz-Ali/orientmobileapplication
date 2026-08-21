import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// A consistent task-oriented heading for pages and workspace sections.
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leading;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leading,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
              ],
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.s6),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (actions.isEmpty) return identity;

    final actionBar = Wrap(
      spacing: AppDimensions.s8,
      runSpacing: AppDimensions.s8,
      children: actions,
    );

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          identity,
          const SizedBox(height: AppDimensions.s16),
          Align(alignment: Alignment.centerLeft, child: actionBar),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: identity),
        const SizedBox(width: AppDimensions.s24),
        actionBar,
      ],
    );
  }
}
