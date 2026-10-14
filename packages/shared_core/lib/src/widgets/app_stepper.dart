import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Horizontal stepper (Phase 01.2 foundation primitive).
///
/// Renders [steps] as numbered nodes with connectors; completed nodes fill
/// with the semantic success family, the current node with primary, upcoming
/// nodes with the recessed surface. Taps report via [onStepTap]. The progress
/// is exposed as localized `Step X of Y` semantics.
///
/// Note: intentionally named [AppStepper] (not Flutter's vertical `Stepper`)
/// — a single-row journey indicator for check-in → inspection → delivery.
class AppStepper extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;
  final ValueChanged<int>? onStepTap;

  const AppStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedCoreL10n.of(context);
    final total = steps.length;
    final current = currentIndex.clamp(0, total - 1);

    return Semantics(
      container: true,
      label: t.stepperStepOf(current + 1, total),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s6,
                  ),
                  color: i <= current
                      ? colors.primary
                      : semantic.borderDefault,
                ),
              ),
            _StepNode(
              index: i,
              label: steps[i],
              state: i < current
                  ? _StepState.done
                  : i == current
                      ? _StepState.current
                      : _StepState.upcoming,
              onTap: onStepTap == null ? null : () => onStepTap!(i),
            ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepNode extends StatelessWidget {
  final int index;
  final String label;
  final _StepState state;
  final VoidCallback? onTap;

  const _StepNode({
    required this.index,
    required this.label,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    final Color fill;
    final Color ink;
    final Color ring;
    switch (state) {
      case _StepState.done:
        fill = semantic.success.base;
        ink = colors.onPrimary;
        ring = semantic.success.base;
      case _StepState.current:
        fill = colors.primary;
        ink = colors.onPrimary;
        ring = semantic.focusRing;
      case _StepState.upcoming:
        fill = semantic.surfaceSunken;
        ink = colors.onSurfaceVariant;
        ring = semantic.borderDefault;
    }

    final node = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: ring,
              width: state == _StepState.current ? 2 : 1,
            ),
          ),
          child: Center(
            child: state == _StepState.done
                ? Icon(Icons.check_rounded, size: 18, color: ink)
                : Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 88),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: state == _StepState.upcoming
                  ? colors.onSurfaceVariant
                  : colors.onSurface,
              fontWeight: state == _StepState.current
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (onTap == null) return node;
    return Semantics(
      button: true,
      selected: state == _StepState.current,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s4),
          child: node,
        ),
      ),
    );
  }
}
