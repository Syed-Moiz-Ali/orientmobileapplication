import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_durations.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Spec-C8 icon button (phase-1a).
///
/// 20 px glyph in a >= 48 dp circular hit area (C8 says 44; the phase-1 rule
/// of >= 48 dp wins — recorded in DESIGN_SYSTEM.md). Optional bordered and
/// filled variants. Icon-only buttons MUST pass [tooltip] (or
/// [semanticLabel]) so screen readers have a label.
///
/// ```dart
/// AppIconButton(icon: Icons.arrow_back_rounded, onPressed: back, tooltip: 'Back')
/// ```
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  /// Accessible label (required for icon-only buttons).
  final String? tooltip;

  /// Explicit icon color; defaults to textSecondary, accent when [active].
  final Color? color;

  /// Render the active (accent) state.
  final bool active;

  /// Draw a 1 px border ring.
  final bool bordered;

  /// Fill with the subtle surface color.
  final bool filled;

  /// Override mirroring; defaults to auto (directional glyphs mirror).
  final bool? mirrorInRtl;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.active = false,
    this.bordered = false,
    this.filled = false,
    this.mirrorInRtl,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AppTokens.of(context);
    final reducedMotion = AppMotion.reducedMotion(context);
    final enabled = widget.onPressed != null;

    final Color iconColor = !enabled
        ? scheme.onSurface.withValues(alpha: 0.4)
        : widget.color ??
            (widget.active ? scheme.primary : scheme.onSurfaceVariant);
    final Color bg = widget.filled
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.6)
        : Colors.transparent;
    final Color pressedBg = widget.filled
        ? tokens.accentSoft
        : tokens.accentSoft.withValues(alpha: 0.5);

    Widget button = Focus(
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (enabled) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          if (_pressed) setState(() => _pressed = false);
          if (enabled) widget.onPressed!();
        },
        onTapCancel: () {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedScale(
          scale: _pressed && enabled && !reducedMotion ? 0.98 : 1.0,
          duration: reducedMotion ? Duration.zero : AppDurations.fast,
          curve: AppDurations.enter,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _pressed && enabled ? pressedBg : bg,
              shape: BoxShape.circle,
              border: widget.bordered
                  ? Border.all(
                      color:
                          _focused ? scheme.primary : scheme.outlineVariant,
                      width: _focused ? 2 : 1,
                    )
                  : (_focused
                      ? Border.all(color: scheme.primary, width: 2)
                      : null),
            ),
            alignment: Alignment.center,
            child: DirectionalIcon(
              widget.icon,
              size: 20,
              color: iconColor,
              mirrorInRtl: widget.mirrorInRtl ??
                  DirectionalIcon.isDirectional(widget.icon),
            ),
          ),
        ),
      ),
    );

    // Long-press tooltip for sighted users + Semantics label for screen
    // readers (mirrors stock IconButton, which feeds both).
    final tooltip = widget.tooltip;
    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.tooltip,
      child: button,
    );
  }
}
