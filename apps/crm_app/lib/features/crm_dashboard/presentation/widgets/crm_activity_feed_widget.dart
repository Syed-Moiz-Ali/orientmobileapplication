import 'package:flutter/material.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';

class ActivityFeedWidget extends StatelessWidget {
  final List<ActivityFeedEntity> feed;
  const ActivityFeedWidget({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    if (feed.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CrmColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.history_rounded, size: 30, color: CrmColors.textM),
            SizedBox(height: 10),
            Text(
              'No activity yet',
              style: TextStyle(color: CrmColors.textM, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CrmColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(color: CrmColors.textH, fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...feed.take(6).map((a) {
            final (icon, color) = switch (a.action) {
              'CREATED' || 'IMPORTED' => (Icons.add_circle_outline_rounded, CrmColors.green),
              'STATUS' => (Icons.swap_horiz_rounded, CrmColors.accent),
              'ASSIGNED' => (Icons.person_add_alt_1_rounded, CrmColors.amber),
              _ => (Icons.edit_outlined, CrmColors.textM),
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${a.customerName} \u2014 ${a.actionLabel}',
                          style: const TextStyle(
                            color: CrmColors.textH,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (a.detail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            a.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: CrmColors.textB, fontSize: 11),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          a.createdAt,
                          style: const TextStyle(color: CrmColors.textM, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
