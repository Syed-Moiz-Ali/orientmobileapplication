import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class GarageInfoCard extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onMap;

  const GarageInfoCard({
    super.key,
    this.onCall,
    this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: const Icon(
                  Icons.garage_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orient Auto Workshop',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Mon - Sat: 8:00 AM - 7:00 PM',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'OPEN NOW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.s12),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.text3),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Unit 4, Industrial Area 1, Main Workshop Highway',
                  style: TextStyle(fontSize: 12, color: AppColors.text3),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling Workshop Hotline: +1 800 555-AUTO'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Call Workshop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onMap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening Google Maps location...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 24/7 Breakdown Hotline Banner
class EmergencyBreakdownBanner extends StatelessWidget {
  final VoidCallback onTap;
  const EmergencyBreakdownBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: const Color(0xFFDA3633).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: const Color(0xFFDA3633).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDA3633),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24/7 Roadside Assistance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDA3633),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Stranded or car won\'t start? Request emergency breakdown tow',
                  style: TextStyle(fontSize: 11, color: AppColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDA3633),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
            ),
            child: const Text(
              'Get Help',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
