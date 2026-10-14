import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Sticky bottom action region for forms, wizards and detail pages.
///
/// - Stacks (primary under secondaries) on compact widths; aligns in a row from
///   medium up (spec §13 / template T4).
/// - Ordering mirrors logically in RTL because the `Row`/`Column` follow the
///   ambient [Directionality].
/// - [isLoading] absorbs interaction and shows an honest busy affordance while
///   the caller's submit is in flight.
class AppActionBar extends StatelessWidget {
  final Widget primary;
  final List<Widget> secondary;
  final bool isLoading;

  /// When true, decorates the bar as a sticky footer (surface background, top
  /// hairline, safe-area bottom inset) so it can float above scrolling content.
  final bool sticky;
  final EdgeInsetsGeometry? padding;

  const AppActionBar({
    super.key,
    required this.primary,
    this.secondary = const [],
    this.isLoading = false,
    this.sticky = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SharedCoreL10n.of(context);

    Widget actions;
    if (context.isCompact) {
      actions = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...secondary.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.s8),
              child: action,
            ),
          ),
          primary,
        ],
      );
    } else {
      actions = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final action in secondary) ...[
            action,
            const SizedBox(width: AppDimensions.s8),
          ],
          primary,
        ],
      );
    }

    if (isLoading) {
      actions = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppDimensions.s8),
              Text(
                t.commonLoading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          actions,
        ],
      );
    }

    final content = AbsorbPointer(absorbing: isLoading, child: actions);

    if (!sticky) {
      return Padding(padding: padding ?? EdgeInsets.zero, child: content);
    }

    final semantic = context.semanticColors;
    final surfaceColor = semantic.surface.withValues(alpha: 0.90);
    final borderColor = semantic.borderDefault;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s16,
                    vertical: AppDimensions.s12,
                  ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
