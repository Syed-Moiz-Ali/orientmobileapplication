import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class FilterChipBar extends StatelessWidget {
  final JobCardStatus? activeFilter;
  final ValueChanged<JobCardStatus?> onFilterChanged;

  const FilterChipBar({super.key, required this.activeFilter, required this.onFilterChanged});

  static const _filters = [
    (null, 'All'),
    (JobCardStatus.inProgress, 'In Progress'),
    (JobCardStatus.waitingParts, 'Waiting Parts'),
    (JobCardStatus.qualityCheck, 'Quality Check'),
    (JobCardStatus.completed, 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (status, label) = _filters[i];
          final isActive = activeFilter == status;
          return GestureDetector(
            onTap: () => onFilterChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
