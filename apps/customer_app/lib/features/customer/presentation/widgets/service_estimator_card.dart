import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/core/router/app_router.dart';

class ServiceEstimatorCard extends StatelessWidget {
  const ServiceEstimatorCard({super.key});

  static const List<Map<String, String>> _services = [
    {
      'name': 'Major Service Package',
      'price': 'AED 1,200',
      'duration': '~3 hrs',
      'desc': 'Engine oil, filter, spark plugs & 40-point diagnostic scan',
    },
    {
      'name': 'Synthetic Oil & Filter',
      'price': 'AED 280',
      'duration': '~45 mins',
      'desc': 'Fully synthetic Mobil 1/Castrol engine oil + OEM filter',
    },
    {
      'name': 'Brake Pad Replacement',
      'price': 'AED 450',
      'duration': '~1.5 hrs',
      'desc': 'Front or rear Brembo/OEM brake pads fitting + rotor check',
    },
    {
      'name': 'RTA Inspection Prep',
      'price': 'AED 200',
      'duration': '~1 hr',
      'desc': 'Official vehicle roadworthiness inspection & certification check',
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
                  Icons.price_change_rounded,
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
                      'Popular Workshop Services',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Transparent pricing & turnaround estimates',
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
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusPill(
                              label: s['duration']!,
                              bg: colorScheme.surfaceContainerLow,
                              fg: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['desc']!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 32,
                        child: FilledButton(
                          onPressed: () =>
                              context.push(AppRoutes.customerBookService),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.r10),
                            ),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
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
