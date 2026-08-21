import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/core/router/app_router.dart';

class SmartSymptomBookingCard extends StatelessWidget {
  const SmartSymptomBookingCard({super.key});

  static const List<Map<String, dynamic>> _symptoms = [
    {
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFD97706),
      'title': 'Warning Light On',
      'subtitle': 'Check engine, ABS, oil alert',
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
      'color': Color(0xFF3B82F6),
      'title': 'AC Not Cooling',
      'subtitle': 'Warm air, weak airflow, odor',
      'service': 'Air Conditioning Service',
    },
    {
      'icon': Icons.no_crash_rounded,
      'color': Color(0xFFEF4444),
      'title': 'Brake Issue',
      'subtitle': 'Spongy pedal, squealing, vibration',
      'service': 'Brake Inspection',
    },
    {
      'icon': Icons.battery_charging_full_rounded,
      'color': Color(0xFFF59E0B),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s18),
      borderRadius: AppDimensions.r24,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Having a Car Issue?',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select a symptom to match the right repair & book',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: AppDimensions.s14),
          AppAdaptiveGrid(
            minChildWidth: 220,
            childAspectRatio: 2.6,
            children: [
              for (final item in _symptoms)
                Builder(
                  builder: (context) {
                    final Color color = item['color'] as Color;
                    return InkWell(
                      onTap: () {
                        context.push(AppRoutes.customerBookService);
                      },
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppDimensions.r16),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppDimensions.r10),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 18,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['subtitle'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
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
        ],
      ),
    );
  }
}
