import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_interaction_states.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

/// Bounded numeric stepper for quantities (parts request, inventory adjust,
/// estimate lines).
///
/// Behavior (Phase 03A):
/// - `−` / `+` controls with min/max/step clamping and optional long-press
///   repeat (mobile ergonomics).
/// - Tabular value so digits never jitter as the number changes.
/// - The control mirrors in RTL automatically (the `Row` reverses, so `−`
///   starts on the reading-start edge).
/// - Disabled, loading and error states; each control keeps a ≥48 px target.
class AppQuantityStepper extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final bool enabled;
  final bool isLoading;

  /// Renders the control in its error treatment (danger border).
  final bool hasError;

  /// Allows press-and-hold to repeat the increment/decrement.
  final bool allowLongPressRepeat;

  /// Number of decimal places; 0 for whole quantities (parts, bays).
  final int decimals;

  /// Accessible name of the value being edited (localized by the caller).
  final String? semanticLabel;

  const AppQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.enabled = true,
    this.isLoading = false,
    this.hasError = false,
    this.allowLongPressRepeat = true,
    this.decimals = 0,
    this.semanticLabel,
  }) : assert(step > 0, 'step must be positive'),
       assert(max >= min, 'max must be >= min');

  @override
  State<AppQuantityStepper> createState() => _AppQuantityStepperState();
}

class _AppQuantityStepperState extends State<AppQuantityStepper> {
  Timer? _repeatTimer;

  bool get _interactive => widget.enabled && !widget.isLoading;

  bool get _canDecrement => _interactive && widget.value > widget.min;
  bool get _canIncrement => _interactive && widget.value < widget.max;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _emit(double next) {
    final clamped = next.clamp(widget.min, widget.max).toDouble();
    if (clamped != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(clamped);
    }
  }

  void _step(int direction) => _emit(widget.value + direction * widget.step);

  void _startRepeat(int direction) {
    if (!widget.allowLongPressRepeat) return;
    _repeatTimer?.cancel();
    _repeatTimer = Timer(const Duration(milliseconds: 450), () {
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 110), (_) {
        _step(direction);
      });
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  String _formatted() {
    if (widget.decimals <= 0) return widget.value.round().toString();
    return widget.value.toStringAsFixed(widget.decimals);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    final borderColor = widget.hasError
        ? colors.error
        : (widget.enabled ? colors.outline : colors.outlineVariant);
    final valueColor = widget.enabled
        ? colors.onSurface
        : colors.onSurfaceVariant.withValues(alpha: 0.6);

    return Semantics(
      container: true,
      value: _formatted(),
      label: widget.semanticLabel,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(
            color: borderColor,
            width: widget.hasError ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperButton(
              icon: Icons.remove_rounded,
              label: t.commonDecrease,
              onTap: _canDecrement ? () => _step(-1) : null,
              onLongPressStart: _canDecrement ? () => _startRepeat(-1) : null,
              onLongPressEnd: _stopRepeat,
            ),
            Container(width: 1, height: 24, color: colors.outline),
            SizedBox(
              width: 56,
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : Text(
                        _formatted(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mono(
                          color: valueColor,
                        ).copyWith(fontSize: 15),
                      ),
              ),
            ),
            Container(width: 1, height: 24, color: colors.outline),
            _StepperButton(
              icon: Icons.add_rounded,
              label: t.commonIncrease,
              onTap: _canIncrement ? () => _step(1) : null,
              onLongPressStart: _canIncrement ? () => _startRepeat(1) : null,
              onLongPressEnd: _stopRepeat,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const _StepperButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: onLongPressStart == null
              ? null
              : (_) => onLongPressStart!(),
          onLongPressEnd: onLongPressEnd == null
              ? null
              : (_) => onLongPressEnd!(),
          onLongPressCancel: onLongPressEnd,
          child: InkWell(
            onTap: onTap,
            overlayColor: AppInteractionStates.overlays(
              colors.surface,
              colors.onSurface,
            ),
            child: SizedBox(
              width: AppDimensions.touchTarget,
              height: AppDimensions.touchTarget,
              child: Icon(
                icon,
                size: AppDimensions.iconMd,
                color: enabled
                    ? colors.onSurface
                    : colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
