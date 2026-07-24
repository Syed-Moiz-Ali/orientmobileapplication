import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

class SalesCategoryCard extends StatelessWidget {
  final TopSalesCategory category;
  final bool isExpanded;
  final VoidCallback onToggle;
  const SalesCategoryCard({
    super.key,
    required this.category,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(
          color: isExpanded
              ? AppColors.accent.withValues(alpha: 0.35)
              : AppColors.border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppDimensions.r16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: isExpanded
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : AppColors.surfaceAlt,
                borderRadius: isExpanded
                    ? BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.r15),
                      )
                    : BorderRadius.circular(AppDimensions.r15),
              ),
              child: Row(
                children: [
                  Text(
                    category.title.toUpperCase(),
                    style: AppTextStyles.rajdhaniLabel(
                      color: isExpanded
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? AppColors.accent : AppColors.text3,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              color: AppColors.surfaceAlt,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      'S.NO',
                      style: AppTextStyles.rajdhaniBodySmall(
                        color: AppColors.text3,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'DESCRIPTION',
                      style: AppTextStyles.rajdhaniBodySmall(
                        color: AppColors.text3,
                      ),
                    ),
                  ),
                  Text(
                    'VALUE',
                    style: AppTextStyles.rajdhaniBodySmall(
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            ...category.items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: i.isEven ? AppColors.surface : AppColors.surfaceAlt,
                  borderRadius: i == category.items.length - 1
                      ? BorderRadius.vertical(
                          bottom: Radius.circular(AppDimensions.r15),
                        )
                      : BorderRadius.zero,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${item.sno}',
                        style: const TextStyle(
                          color: AppColors.text3,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.description,
                        style: const TextStyle(
                          color: AppColors.text2,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: AppTextStyles.orbitronHeadline(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
