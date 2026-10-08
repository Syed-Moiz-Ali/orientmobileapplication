import 'package:flutter/material.dart';

class AdvisorWorkflowIndicator extends StatelessWidget {
  final int currentStep;

  const AdvisorWorkflowIndicator({super.key, required this.currentStep});

  static const _steps = <(String, IconData)>[
    ('Job Card', Icons.person_search_rounded),
    ('Inspect', Icons.fact_check_outlined),
    ('Estimate', Icons.receipt_long_outlined),
    ('Repair', Icons.build_outlined),
    ('Deliver', Icons.key_rounded),
  ];

  static const _descriptions = <String>[
    'Add the customer and vehicle details',
    'Check the vehicle and record its condition',
    'Prepare services, parts and pricing',
    'Complete the approved repair work',
    'Hand the completed vehicle to the customer',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeStep = currentStep.clamp(0, _steps.length - 1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _steps[activeStep].$2,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _steps[activeStep].$1,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _descriptions[activeStep],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${activeStep + 1} of ${_steps.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final connectorIndex = i ~/ 2;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 3,
                    margin: const EdgeInsets.only(top: 13),
                    decoration: BoxDecoration(
                      color: connectorIndex < activeStep
                          ? colors.primary
                          : colors.outlineVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                );
              }
              final index = i ~/ 2;
              final completed = index < activeStep;
              final active = index == activeStep;
              return SizedBox(
                width: 48,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: active
                            ? colors.primary
                            : completed
                            ? colors.primaryContainer
                            : colors.surfaceContainerLow,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: completed || active
                              ? colors.primary
                              : colors.outlineVariant,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        completed ? Icons.check_rounded : _steps[index].$2,
                        size: 14,
                        color: active
                            ? colors.onPrimary
                            : completed
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _steps[index].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                        color: active
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
