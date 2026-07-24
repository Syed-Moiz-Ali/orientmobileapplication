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
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (status, label) = _filters[i];
          final isActive = activeFilter == status;
          return GestureDetector(
            onTap: () => onFilterChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.r20),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
              ),
              child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.text3)),
            ),
          );
        },
      ),
    );
  }
}
