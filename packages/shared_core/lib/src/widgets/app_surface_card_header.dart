import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Header row for [AppSurfaceCard] (spec C8, phase-1c-i).
///
/// Small title + optional trailing action, with an optional trailing chevron
/// that mirrors in RTL. Callers show the chevron only on tappable cards.
class AppSurfaceCardHeader extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final bool showChevron;

  const AppSurfaceCardHeader({
    super.key,
    this.title,
    this.trailing,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final heading = title;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          if (heading != null)
            Expanded(
              child: Text(heading, style: textTheme.titleSmall),
            ),
          if (trailing != null) trailing!,
          if (showChevron)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
              child: DirectionalIcon(
                Icons.chevron_right_rounded,
                size: 20, // spec C8: 20 px chevrons.
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
