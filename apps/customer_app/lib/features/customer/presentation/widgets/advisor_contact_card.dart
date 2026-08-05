import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorContactCard extends StatelessWidget {
  final String advisorName;
  final String advisorRole;
  final String phone;

  const AdvisorContactCard({
    super.key,
    this.advisorName = 'Ahmed Hassan',
    this.advisorRole = 'Senior Service Advisor',
    this.phone = '+1 800 555 0199',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                advisorName.isNotEmpty ? advisorName.substring(0, 1) : 'A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      advisorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  advisorRole,
                  style: const TextStyle(fontSize: 11, color: AppColors.text3),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling Service Advisor ($phone)...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_rounded, color: AppColors.accent, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
