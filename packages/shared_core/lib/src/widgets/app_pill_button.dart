import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_durations.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Spec-C8 pill button heights (phase-1a).
///
/// The 36 px `small` visual still guarantees a >= 48 dp hit area: the pill
/// is centered inside a transparent 48 dp-tall box, so the look is unchanged.
enum AppPillButtonSize {
  /// Full-width CTAs. 52 px visual.
  large(52),

  /// Default in rows and dialogs. 44 px visual.
  medium(44),

  /// Dense inline actions. 36 px visual, 48 px hit area.
  small(36);

  const AppPillButtonSize(this.height);

  /// Visual pill height.
  final double height;
}

enum _AppPillVariant { primary, secondary, ghost, destructive, success }

/// Spec-C8 pill button (phase-1a).
///
/// Named `AppPillButton` (not `AppButton`) because the legacy
/// `AppButton` factory in `primary_button.dart` owns that name and is
/// off-limits in phase 1. Once the legacy factory is removed in the polish
/// phase, this class is the rename candidate (`AppPillButton` -> `AppButton`).
///
/// ```dart
/// AppPillButton.primary(label: 'Continue', onPressed: save)
/// AppPillButton.success(label: 'Approve', onPressed: approve, size: AppPillButtonSize.small)
/// ```
///
/// - Tokens only, caller-supplied text, RTL-safe (leading icon renders at
///   the `start` side; directional glyphs mirror via [DirectionalIcon]).
/// - Press: scale 0.98 + pressed color, 150 ms ease, no haptics, honors
///   reduced motion (no scale, instant colors).
/// - Loading: width preserved (label kept laid out, spinner overlaid),
///   spinner uses the label color, taps ignored, Semantics reports busy.
/// - Disabled (`onPressed == null`): 40 % opacity + no press response.
///   Enabled is full opacity, so the two are never confusable.
/// - Text scale 1.3: label ellipsizes (max 1 line) instead of overflowing.
class AppPillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppPillButtonSize size;
  final IconData? icon;

  /// Override icon mirroring; defaults to auto (directional glyphs mirror).
  final bool? mirrorIcon;

  /// Full-width (default) or intrinsic width (min 88).
  final bool isExpanded;

  final bool isLoading;

  /// Optional label shown while [isLoading] is true (e.g. "Signing in…").
  /// The rest label stays laid out invisibly behind the busy row so the
  /// button width never shifts; the busy label itself announces the state
  /// change. When null the rest label is kept with an overlaid spinner.
  final String? busyLabel;

  final _AppPillVariant _variant;

  const AppPillButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppPillButtonSize.large,
    this.icon,
    this.mirrorIcon,
    this.isExpanded = true,
    this.isLoading = false,
    this.busyLabel,
  }) : _variant = _AppPillVariant.primary;

  const AppPillButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppPillButtonSize.medium,
    this.icon,
    this.mirrorIcon,
    this.isExpanded = true,
    this.isLoading = false,
    this.busyLabel,
  }) : _variant = _AppPillVariant.secondary;

  const AppPillButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppPillButtonSize.medium,
    this.icon,
    this.mirrorIcon,
    this.isExpanded = false,
    this.isLoading = false,
    this.busyLabel,
  }) : _variant = _AppPillVariant.ghost;

  const AppPillButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppPillButtonSize.large,
    this.icon,
    this.mirrorIcon,
    this.isExpanded = true,
    this.isLoading = false,
    this.busyLabel,
  }) : _variant = _AppPillVariant.destructive;

  const AppPillButton.success({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppPillButtonSize.large,
    this.icon,
    this.mirrorIcon,
    this.isExpanded = true,
    this.isLoading = false,
    this.busyLabel,
  }) : _variant = _AppPillVariant.success;

  @override
  State<AppPillButton> createState() => _AppPillButtonState();
}

class _AppPillButtonState extends State<AppPillButton> {
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AppTokens.of(context);
    final reducedMotion = AppMotion.reducedMotion(context);
    // Resolve variant colors (all AA-verified, see token swatch report).
    late final Color bg;
    late final Color fg;
    late final Color pressedBg;
    late final Color pressedFg;
    bool bordered = false;
    switch (widget._variant) {
      case _AppPillVariant.primary:
        bg = scheme.primary;
        fg = scheme.onPrimary;
        pressedBg = tokens.accentPressed;
        pressedFg = tokens.accentPressedInk;
      case _AppPillVariant.secondary:
        bg = scheme.surface;
        fg = scheme.onSurface;
        pressedBg = tokens.accentSoft;
        pressedFg = tokens.accentInk;
        bordered = true;
      case _AppPillVariant.ghost:
        bg = Colors.transparent;
        fg = scheme.primary;
        pressedBg = tokens.accentSoft;
        pressedFg = tokens.accentInk;
      case _AppPillVariant.destructive:
        bg = scheme.error;
        fg = scheme.onError;
        pressedBg = scheme.error;
        pressedFg = scheme.onError;
      case _AppPillVariant.success:
        bg = Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.successStrong
            : AppColors.successStrong;
        fg = scheme.onPrimary;
        pressedBg = bg;
        pressedFg = scheme.onPrimary;
    }
    final effectiveBg = _pressed && _interactive ? pressedBg : bg;
    final effectiveFg = _pressed && _interactive ? pressedFg : fg;

    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: effectiveFg,
        );

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          DirectionalIcon(
            widget.icon!,
            size: 18,
            color: effectiveFg,
            mirrorInRtl:
                widget.mirrorIcon ?? DirectionalIcon.isDirectional(widget.icon!),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
      ],
    );

    final displayLabel =
        widget.isLoading ? (widget.busyLabel ?? widget.label) : widget.label;
    if (widget.isLoading) {
      // Width preservation: the rest label stays laid out invisibly so the
      // pill never shifts; the busy row (spinner + busy label when set)
      // paints on top. The busy label ellipsizes instead of overflowing.
      content = Stack(
        alignment: Alignment.center,
        children: [
          // Hidden from assistive tech: only the busy row + the outer
          // "<busy>, loading" label announce, never the retired rest label.
          ExcludeSemantics(child: Opacity(opacity: 0, child: content)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
                ),
              ),
              if (widget.busyLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    displayLabel,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    final pill = AnimatedScale(
      scale: _pressed && _interactive && !reducedMotion ? 0.98 : 1.0,
      duration: reducedMotion ? Duration.zero : AppDurations.fast,
      curve: AppDurations.enter,
      child: AnimatedContainer(
        duration: reducedMotion ? Duration.zero : AppDurations.fast,
        curve: AppDurations.enter,
        height: widget.size.height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: bordered
              ? Border.all(
                  color: _focused ? scheme.primary : scheme.outlineVariant,
                  width: _focused ? 2 : 1,
                )
              : (_focused
                  ? Border.all(color: scheme.primary, width: 2)
                  : null),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );

    // Transparent 48 dp hit box around smaller visuals (look unchanged).
    final hitBox = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48,
        minWidth: 88,
      ),
      child: Center(child: pill),
    );

    final button = Opacity(
      opacity: widget.onPressed == null ? 0.4 : 1.0,
      child: SizedBox(
        width: widget.isExpanded ? double.infinity : null,
        child: hitBox,
      ),
    );

    return Semantics(
      button: true,
      enabled: _interactive,
      label: widget.isLoading ? '$displayLabel, loading' : widget.label,
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
          child: button,
        ),
      ),
    );
  }
}
