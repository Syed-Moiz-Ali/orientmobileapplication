import 'package:flutter/material.dart';

class AdvisorWorkflowIndicator extends StatelessWidget {
  final int currentStep;

  const AdvisorWorkflowIndicator({super.key, required this.currentStep});

  static const _steps = <(String, IconData)>[
    ('Intake', Icons.person_search_rounded),
    ('Inspect', Icons.fact_check_outlined),
    ('Estimate', Icons.receipt_long_outlined),
    ('Repair', Icons.build_outlined),
    ('Deliver', Icons.key_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(_steps.length, (index) {
            final completed = index < currentStep;
            final active = index == currentStep;
            final color = completed || active ? colors.primary : colors.outline;
            return Row(
              children: [
                SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: active
                              ? colors.primary
                              : completed
                              ? colors.primaryContainer
                              : colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color,
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          completed ? Icons.check_rounded : _steps[index].$2,
                          size: 17,
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: active
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: active
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 18,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: index < currentStep
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
