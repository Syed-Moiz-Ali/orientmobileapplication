import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/core/router/app_router.dart';

class SmartSymptomBookingCard extends StatelessWidget {
  const SmartSymptomBookingCard({super.key});

  static const List<Map<String, dynamic>> _symptoms = [
    {
      'icon': Icons.warning_amber_rounded,
      'color': AppColors.warning,
      'title': 'Warning Light On',
      'subtitle': 'Check engine, ABS, oil light',
      'service': 'Diagnostic Check',
    },
    {
      'icon': Icons.volume_up_rounded,
      'color': Color(0xFF8B5CF6),
      'title': 'Strange Noise',
      'subtitle': 'Squeaking, knocking, grinding',
      'service': 'Full Service',
    },
    {
      'icon': Icons.ac_unit_rounded,
      'color': AppColors.info,
      'title': 'AC Not Cooling',
      'subtitle': 'Warm air, weak airflow, odor',
      'service': 'Air Conditioning Service',
    },
    {
      'icon': Icons.no_crash_rounded,
      'color': AppColors.danger,
      'title': 'Brake Issue',
      'subtitle': 'Spongy pedal, squealing, vibration',
      'service': 'Brake Inspection',
    },
    {
      'icon': Icons.battery_charging_full_rounded,
      'color': AppColors.accent,
      'title': 'Battery / Starting',
      'subtitle': 'Slow crank, dead battery, no start',
      'service': 'Battery Replacement',
    },
    {
      'icon': Icons.tire_repair_rounded,
      'color': Color(0xFF10B981),
      'title': 'Tyre / Steering Pull',
      'subtitle': 'Low pressure, pulling left/right',
      'service': 'Wheel Alignment',
    },
  ];

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Having a Car Issue?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select a symptom to find the right service & book',
                      style: TextStyle(fontSize: 12, color: AppColors.text3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.s14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _symptoms.length,
            itemBuilder: (ctx, i) {
              final item = _symptoms[i];
              final Color color = item['color'] as Color;
              return GestureDetector(
                onTap: () {
                  context.push(AppRoutes.customerBookService);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['subtitle'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
