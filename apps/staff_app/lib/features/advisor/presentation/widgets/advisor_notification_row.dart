import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'advisor_notification_data.dart';

class AdvisorNotificationRow extends StatelessWidget {
  final AdvisorNotificationData n;
  const AdvisorNotificationRow({super.key, required this.n});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.canvas,
      borderRadius: BorderRadius.circular(AppDimensions.r14),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: n.color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(n.icon, color: n.color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                n.body,
                style: const TextStyle(fontSize: 11, color: AppColors.text2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          n.time,
          style: const TextStyle(fontSize: 10, color: AppColors.text3),
        ),
      ],
    ),
  );
}
