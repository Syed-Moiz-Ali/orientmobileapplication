import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'advisor_outline_action.dart';
import 'advisor_solid_action.dart';

class AdvisorStatDialog extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const AdvisorStatDialog({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.r20),
    ),
    backgroundColor: AppColors.surface,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap below to view the full list',
            style: TextStyle(fontSize: 12, color: AppColors.text2),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: AdvisorOutlineAction(
                  label: 'Close',
                  icon: Icons.close_rounded,
                  color: AppColors.text3,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdvisorSolidAction(
                  label: 'View all',
                  icon: Icons.arrow_forward_rounded,
                  gradient: [color, color.withValues(alpha: 0.75)],
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
