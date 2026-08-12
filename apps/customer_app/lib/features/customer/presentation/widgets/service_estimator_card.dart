import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/core/router/app_router.dart';

class ServiceEstimatorCard extends StatelessWidget {
  const ServiceEstimatorCard({super.key});

  static const List<Map<String, String>> _services = [
    {
      'name': 'Full Service',
      'price': '\u00a3280',
      'duration': '~3 hrs',
      'desc': 'Engine oil, filter, spark plugs & 40-point safety check',
    },
    {
      'name': 'Oil & Filter Change',
      'price': '\u00a365',
      'duration': '~45 mins',
      'desc': 'Synthetic engine oil replacement + new oil filter',
    },
    {
      'name': 'Brake Pad Replacement',
      'price': '\u00a3120',
      'duration': '~1.5 hrs',
      'desc': 'Front or rear OEM brake pads fitting + rotor inspection',
    },
    {
      'name': 'MOT Inspection Test',
      'price': '\u00a354',
      'duration': '~1 hr',
      'desc': 'Official vehicle roadworthiness inspection & certificate',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: const Icon(
                  Icons.price_change_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Workshop Services',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Transparent pricing & turnaround times',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.s10),
          ..._services.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s['name']!,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s['duration']!,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.text3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['desc']!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'From ${s['price']}',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push(AppRoutes.customerBookService),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Book',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
