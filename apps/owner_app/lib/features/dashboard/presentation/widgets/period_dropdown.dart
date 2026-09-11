import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';

class PeriodDropdown extends ConsumerWidget {
  const PeriodDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    return PopupMenuButton<String>(
      initialValue: state.period,
      onSelected: (v) => notifier.setPeriod(v),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'Today', child: Text('Today')),
        PopupMenuItem(value: 'This Week', child: Text('This Week')),
        PopupMenuItem(value: 'This Month', child: Text('This Month')),
        PopupMenuItem(value: 'This Year', child: Text('This Year')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 5),
            Text(
              state.period,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
