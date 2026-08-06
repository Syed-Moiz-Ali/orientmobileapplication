import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/card_title.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';

class JobCardRegisterCard extends StatelessWidget {
  final List<JobCardRegisterItem> items;
  const JobCardRegisterCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard.surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Job Card Register'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Category',
                    style: AppTextStyles.rajdhaniBodySmall(
                      color: AppColors.accent,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Open',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.rajdhaniBodySmall(
                      color: AppColors.accent,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.rajdhaniBodySmall(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            // FE-FIX (frontend pass): rows were dead UI — tapping now drills
            // into the full job-card register list.
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JobCardsListView()),
              ),
              borderRadius: BorderRadius.circular(AppDimensions.r8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: i.isEven ? AppColors.surfaceAlt : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.r8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: AppColors.text2,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.open}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.total}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.text3),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
