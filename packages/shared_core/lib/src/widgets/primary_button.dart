import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_interaction_states.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Concept A action-system metrics. Every interactive control in the catalog
/// shares the same 8 px chamfer, 48 px minimum touch target and 52 px default
/// control height so buttons never drift out of vertical rhythm.
abstract final class AppButtonMetrics {
  AppButtonMetrics._();

  static const double height = 52.0;
  static const double compactHeight = 40.0;
  static const double inlineHeight = 36.0;
  static const double horizontalPadding = AppDimensions.s20;

  /// Optical size of the leading/trailing glyph (Phase 02).
  static const double iconSize = 18.0;
}

/// Resolves the border side of a control, applying the 2 px focus ring when the
/// control is focused and the resting border otherwise (spec §8.4).
WidgetStateProperty<BorderSide?> _focusableBorder(
  Color ring,
  Color resting, {
  double restingWidth = 1,
}) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.focused)) {
      return BorderSide(
        color: ring,
        width: AppInteractionStates.focusRingWidth,
      );
    }
    return BorderSide(color: resting, width: restingWidth);
  });
}

/// Concept A primary action anchor.
///
/// - Crisp 8 px chamfered corners, Hyper Cobalt fill, white `w700` label.
/// - Micro-haptic feedback on tap (`HapticFeedback.lightImpact()`).
/// - A busy button keeps its active-strength fill and ink so the loading
///   spinner (and any label) stays WCAG-compliant, and the embedded spinner
///   swaps in place with an [AnimatedSwitcher] so its exact dimensions never
///   jump.
/// - [isError] renders the destructive Brembo Crimson treatment.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  /// When true a directional [icon] mirrors horizontally in RTL layouts.
  /// Defaults to false; [AppButton] flips known directional glyphs
  /// automatically.
  final bool mirrorIcon;
  final double height;
  final bool isExpanded;

  /// Renders the destructive crimson treatment (delete / cancel booking).
  final bool isError;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.mirrorIcon = false,
    this.height = AppButtonMetrics.height,
    this.isExpanded = true,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final adaptive = context.adaptive;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    final effectiveBackgroundColor = isError
        ? colorScheme.error
        : (backgroundColor ?? colorScheme.primary);
    final effectiveForegroundColor = isError
        ? colorScheme.onError
        : (foregroundColor ?? colorScheme.onPrimary);
    final effectiveHeight = height == AppButtonMetrics.height
        ? adaptive.controlHeight
        : height;

    final style =
        ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          // A busy button keeps its active-strength fill and ink so the loading
          // spinner and any label remain WCAG-compliant. Genuinely disabled
          // buttons keep the established dimmed treatment (alpha < 1) asserted
          // by `app_button_accessibility_test.dart`.
          disabledBackgroundColor: isLoading
              ? effectiveBackgroundColor
              : effectiveBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: isLoading
              ? effectiveForegroundColor
              : effectiveForegroundColor.withValues(alpha: 0.7),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppButtonMetrics.horizontalPadding,
          ),
          minimumSize: Size(isExpanded ? double.infinity : 0, effectiveHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: arabic ? 0 : 0.2,
          ),
        ).copyWith(
          overlayColor: AppInteractionStates.overlays(
            effectiveBackgroundColor,
            effectiveForegroundColor,
          ),
          side: AppInteractionStates.focusRing(
            context.semanticColors.focusRing,
          ),
        );

    final button = ElevatedButton(
      onPressed: isLoading || onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      style: style,
      child: AnimatedSwitcher(
        duration: AppMotion.resolve(context, AppMotion.standard),
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        child: isLoading
            ? SizedBox(
                key: const ValueKey('loading'),
                width: AppButtonMetrics.iconSize,
                height: AppButtonMetrics.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveForegroundColor,
                  ),
                ),
              )
            : Row(
                key: const ValueKey('label'),
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    DirectionalIcon(
                      icon!,
                      size: AppButtonMetrics.iconSize,
                      color: effectiveForegroundColor,
                      mirrorInRtl: mirrorIcon,
                    ),
                    const SizedBox(width: AppDimensions.s8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: effectiveForegroundColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: arabic ? 0 : 0.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isExpanded ? double.infinity : 0,
        minHeight: effectiveHeight,
      ),
      child: button,
    );
  }
}

/// Concept A secondary action: a neutral surface fill with a 1 px hairline
/// border and a `w600` label. Keeps the same height geometry as
/// [PrimaryButton] so paired buttons align pixel-for-pixel.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool mirrorLeadingIcon;
  final bool mirrorTrailingIcon;
  final Color? foregroundColor;
  final Color? borderColor;
  final double height;
  final bool isExpanded;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.mirrorLeadingIcon = false,
    this.mirrorTrailingIcon = false,
    this.foregroundColor,
    this.borderColor,
    this.height = AppButtonMetrics.height,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final adaptive = context.adaptive;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
    final effectiveBorderColor =
        borderColor ?? context.semanticColors.borderStrong;
    final effectiveHeight = height == AppButtonMetrics.height
        ? adaptive.controlHeight
        : height;

    final button = OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      style:
          OutlinedButton.styleFrom(
            foregroundColor: effectiveForegroundColor,
            backgroundColor: context.semanticColors.surfaceRaised,
            disabledForegroundColor: effectiveForegroundColor.withValues(
              alpha: 0.38,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppButtonMetrics.horizontalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            minimumSize: Size(
              isExpanded ? double.infinity : 0,
              effectiveHeight,
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: arabic ? 0 : 0.1,
            ),
          ).copyWith(
            side: _focusableBorder(
              context.semanticColors.focusRing,
              effectiveBorderColor,
            ),
            overlayColor: AppInteractionStates.overlays(
              colorScheme.surface,
              effectiveForegroundColor,
            ),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            DirectionalIcon(
              leadingIcon!,
              size: AppButtonMetrics.iconSize,
              color: effectiveForegroundColor,
              mirrorInRtl: mirrorLeadingIcon,
            ),
            const SizedBox(width: AppDimensions.s8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                color: effectiveForegroundColor,
                fontWeight: FontWeight.w600,
                letterSpacing: arabic ? 0 : 0.1,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppDimensions.s8),
            DirectionalIcon(
              trailingIcon!,
              size: AppButtonMetrics.iconSize,
              color: effectiveForegroundColor,
              mirrorInRtl: mirrorTrailingIcon,
            ),
          ],
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isExpanded ? double.infinity : 0,
        minHeight: effectiveHeight,
      ),
      child: button,
    );
  }
}

/// Unified Action System representing primary, secondary, tertiary, danger,
/// quietIcon, and compactInline.
class AppButton {
  AppButton._();

  /// Primary prominent button.
  static Widget primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isError = false,
    IconData? icon,
    bool isExpanded = true,
    double height = AppButtonMetrics.height,
  }) {
    return PrimaryButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isError: isError,
      icon: icon,
      mirrorIcon: icon != null && DirectionalIcon.isDirectional(icon),
      isExpanded: isExpanded,
      height: height,
    );
  }

  /// Secondary outlined button.
  static Widget secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isExpanded = true,
    double height = AppButtonMetrics.height,
  }) {
    return SecondaryButton(
      key: key,
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      mirrorLeadingIcon:
          leadingIcon != null && DirectionalIcon.isDirectional(leadingIcon),
      mirrorTrailingIcon:
          trailingIcon != null && DirectionalIcon.isDirectional(trailingIcon),
      isExpanded: isExpanded,
      height: height,
    );
  }

  /// Tertiary / ghost text button with guaranteed 48 px touch target.
  static Widget tertiary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final fg = color ?? theme.colorScheme.primary;
        return TextButton(
          key: key,
          onPressed: onPressed,
          style:
              TextButton.styleFrom(
                foregroundColor: fg,
                minimumSize: const Size(48, AppDimensions.touchTarget),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s12,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ).copyWith(
                overlayColor: AppInteractionStates.overlays(
                  theme.colorScheme.surface,
                  fg,
                ),
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                DirectionalIcon(
                  icon,
                  size: AppButtonMetrics.iconSize,
                  color: fg,
                  mirrorInRtl: DirectionalIcon.isDirectional(icon),
                ),
                const SizedBox(width: AppDimensions.s6),
              ],
              Text(label),
            ],
          ),
        );
      },
    );
  }

  /// Danger / destructive action button.
  ///
  /// Uses the brightness-aware semantic error pair so the label keeps WCAG AA
  /// contrast in both themes.
  static Widget danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isExpanded = true,
    double height = AppButtonMetrics.height,
  }) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return PrimaryButton(
          key: key,
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          mirrorIcon: icon != null && DirectionalIcon.isDirectional(icon),
          backgroundColor: colors.error,
          foregroundColor: colors.onError,
          isExpanded: isExpanded,
          height: height,
        );
      },
    );
  }

  /// Quiet icon button with guaranteed 48 px hit area and soft hover/pressed
  /// feedback.
  static Widget quietIcon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    Color? color,
    double size = 20.0,
  }) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final iconColor = color ?? colors.onSurfaceVariant;
        return IconButton(
          key: key,
          onPressed: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed();
                },
          tooltip: tooltip,
          iconSize: size,
          style: IconButton.styleFrom(
            foregroundColor: iconColor,
            minimumSize: const Size.square(AppDimensions.touchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
          ),
          icon: Icon(icon, color: iconColor),
        );
      },
    );
  }

  /// Compact inline action for table rows or cards (36 px visual height, 48 px
  /// touch target hit area). Directional [icon]s flip in RTL.
  static Widget compactInline({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isPrimary = false,
  }) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final fg = isPrimary ? colors.onPrimary : colors.onSurface;
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
          child: Center(
            child: SizedBox(
              height: AppButtonMetrics.inlineHeight,
              child: ElevatedButton(
                key: key,
                onPressed: onPressed == null
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onPressed();
                      },
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: isPrimary
                          ? colors.primary
                          : colors.surface,
                      foregroundColor: fg,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      side: isPrimary
                          ? null
                          : BorderSide(
                              color: context.semanticColors.borderDefault,
                            ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.s12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusControl,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ).copyWith(
                      overlayColor: AppInteractionStates.overlays(
                        isPrimary ? colors.primary : colors.surface,
                        fg,
                      ),
                    ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      DirectionalIcon(
                        icon,
                        size: 14,
                        color: fg,
                        mirrorInRtl: DirectionalIcon.isDirectional(icon),
                      ),
                      const SizedBox(width: AppDimensions.s4),
                    ],
                    Text(label),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
