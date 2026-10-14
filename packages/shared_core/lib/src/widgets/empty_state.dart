import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/primary_button.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  /// True for the [EmptyState.error] constructor: when title/actionLabel are
  /// not supplied they default to localized error copy at build time.
  final bool _isErrorVariant;

  /// True for the [EmptyState.noMatch] constructor (search returned nothing).
  final bool _isNoMatchVariant;

  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  }) : _isErrorVariant = false,
       _isNoMatchVariant = false;

  /// Unified Error state constructor. When [title]/[actionLabel] are omitted
  /// they resolve to the localized "Something went wrong" / "Retry" copy.
  const EmptyState.error({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.error_outline_rounded,
    this.actionLabel,
    required VoidCallback onRetry,
  }) : onAction = onRetry,
       _isErrorVariant = true,
       _isNoMatchVariant = false,
       iconColor = null,
       iconBackgroundColor = null;

  /// No-match state constructor: a search/filter returned nothing. Distinct
  /// from *empty* (no data yet) and *error* (spec §7: distinguish empty vs
  /// no-match vs error). Defaults to the localized "No matches found" title.
  const EmptyState.noMatch({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.search_off_rounded,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  }) : _isErrorVariant = false,
       _isNoMatchVariant = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantic = context.semanticColors;
    final t = SharedCoreL10n.of(context);
    // The unified error variant resolves its crimson plate from the active
    // theme's danger status family (no hard-coded hex).
    final resolvedIconColor =
        iconColor ?? (_isErrorVariant ? semantic.danger.base : null);
    final resolvedIconBackground = iconBackgroundColor ??
        (_isErrorVariant ? semantic.danger.subtle : null);
    final resolvedTitle =
        title ??
        (_isErrorVariant
            ? t.commonErrorTitle
            : (_isNoMatchVariant ? t.commonNoResults : null));
    final resolvedAction =
        actionLabel ?? (_isErrorVariant ? t.commonRetry : null);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s32),
        child: TweenAnimationBuilder<double>(
          duration: AppMotion.resolve(context, AppMotion.emphasized),
          curve: AppMotion.enter,
          tween: Tween<double>(
            begin: AppMotion.reducedMotion(context) ? 1 : 0,
            end: 1,
          ),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Concept A precision icon plate (rounded chamfer, semantic tint,
              // hairline ring) replacing the generic circle.
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color:
                      resolvedIconBackground ??
                      (resolvedIconColor ?? colorScheme.primary).withValues(
                        alpha: 0.10,
                      ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color:
                        (resolvedIconColor ?? colorScheme.primary).withValues(
                          alpha: 0.18,
                        ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 30,
                    color:
                        resolvedIconColor ??
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              // Optional Typographic Title
              if (resolvedTitle != null) ...[
                Text(
                  resolvedTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
              ],

              // Descriptive Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              // Single prominent Concept A CTA.
              if (resolvedAction != null && onAction != null) ...[
                const SizedBox(height: AppDimensions.s24),
                PrimaryButton(
                  label: resolvedAction,
                  isExpanded: false,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
