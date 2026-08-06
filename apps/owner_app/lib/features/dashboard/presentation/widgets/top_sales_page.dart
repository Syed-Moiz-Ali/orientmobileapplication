import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/sales_category_card.dart';

class TopSalesPage extends ConsumerWidget {
  const TopSalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FE-FIX (audit P1): watch the provider so toggling a category rebuilds
    // the page (was read-only — the expand/collapse did nothing).
    ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);
    final categories = notifier.topSalesCategories;
    final expandedSet = notifier.expandedCategoryIndices;

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              const Icon(Icons.category_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                '${categories.length} Categories',
                style: const TextStyle(
                  color: AppColors.text2,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final cat = categories[i];
              return SalesCategoryCard(
                category: cat,
                isExpanded: expandedSet.contains(i),
                onToggle: () => notifier.toggleCategory(i),
              );
            },
          ),
        ),
      ],
    );
  }
}
