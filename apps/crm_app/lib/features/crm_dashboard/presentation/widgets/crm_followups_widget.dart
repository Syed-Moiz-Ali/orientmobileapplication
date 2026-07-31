import 'package:flutter/material.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';

class FollowUpsWidget extends StatelessWidget {
  final List<FollowUpEntity> followUps;
  const FollowUpsWidget({super.key, required this.followUps});

  @override
  Widget build(BuildContext context) {
    if (followUps.isEmpty) {
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
            Icon(Icons.event_available_outlined, size: 30, color: CrmColors.textM),
            SizedBox(height: 10),
            Text(
              'No follow-ups scheduled',
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
            'Upcoming Follow-ups',
            style: TextStyle(color: CrmColors.textH, fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...followUps.take(5).map((f) {
            final (color, bg) = switch (f.status.toUpperCase()) {
              'WON' => (CrmColors.green, CrmColors.greenBg),
              'LOST' => (CrmColors.red, CrmColors.redBg),
              'UNANSWERED' => (CrmColors.amber, CrmColors.amberBg),
              _ => (CrmColors.accent, CrmColors.accentLight),
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_rounded, size: 17, color: CrmColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.customerName,
                          style: const TextStyle(
                            color: CrmColors.textH,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${f.followUpDate}  \u00b7  ${f.source}',
                          style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      f.status,
                      style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
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
