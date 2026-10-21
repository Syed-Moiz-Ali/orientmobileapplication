import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_durations.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Small text-only action (phase-1a): a ghost button for links and tertiary
/// actions ("See all", "Try again", "Forgot password?").
///
/// No fill; accent label (or error for [destructive]); >= 48 dp hit area with
/// a pill touch shape. Taps ignored while [isLoading] (spinner replaces the
/// optional icon, label stays). Honors reduced motion, 1.3x-safe.
///
/// Long labels wrap to a second centered line instead of truncating —
/// primary links must never ellipsize (phase-2 F-7).
///
/// ```dart
/// AppTextButton(label: 'See all', onPressed: openAll)
/// ```
class AppTextButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Override mirroring; defaults to auto (directional glyphs mirror).
  final bool? mirrorIcon;

  /// Error-colored label for destructive text actions.
  final bool destructive;

  final bool isLoading;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.mirrorIcon,
    this.destructive = false,
    this.isLoading = false,
  });

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton> {
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AppTokens.of(context);
    final reducedMotion = AppMotion.reducedMotion(context);

    final Color baseFg =
        widget.destructive ? scheme.error : scheme.primary;
    final Color fg = widget.onPressed == null
        ? baseFg.withValues(alpha: 0.4)
        : baseFg;

    return Semantics(
      button: true,
      enabled: _interactive,
      label: widget.isLoading ? '${widget.label}, loading' : widget.label,
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            if (_interactive) setState(() => _pressed = true);
          },
          onTapUp: (_) {
            if (_pressed) setState(() => _pressed = false);
            if (_interactive) widget.onPressed!();
          },
          onTapCancel: () {
            if (_pressed) setState(() => _pressed = false);
          },
          child: AnimatedScale(
            scale: _pressed && _interactive && !reducedMotion ? 0.98 : 1.0,
            duration: reducedMotion ? Duration.zero : AppDurations.fast,
            curve: AppDurations.enter,
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: _pressed && _interactive
                    ? tokens.accentSoft.withValues(alpha: 0.6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: _focused
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    DirectionalIcon(
                      widget.icon!,
                      size: 18,
                      color: fg,
                      mirrorInRtl: widget.mirrorIcon ??
                          DirectionalIcon.isDirectional(widget.icon!),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: fg,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
