import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class CustomerActiveServiceCard extends StatelessWidget {
  final CustomerServiceEntity svc;
  final VoidCallback onTap;

  const CustomerActiveServiceCard({
    super.key,
    required this.svc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.r24),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r24),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusPill(
                  label: 'LIVE TRACKER',
                  showDot: true,
                  bg: colorScheme.primary.withValues(alpha: 0.12),
                  fg: colorScheme.primary,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s14),
            Text(
              svc.service,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              '${svc.vehicleName} • ${svc.plateNumber}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Workshop Progress',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${svc.progressPercent}%',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.rPill),
                        child: LinearProgressIndicator(
                          value: svc.progressPercent / 100,
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerLow,
                          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.r12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Estimated handover: ${svc.estCompletion}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerServiceStatusCard extends StatelessWidget {
  final CustomerServiceEntity svc;

  const CustomerServiceStatusCard({super.key, required this.svc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s18),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      svc.service,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      '${svc.vehicleName} • ${svc.plateNumber}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: 'IN PROGRESS',
                showDot: true,
                bg: colorScheme.primary.withValues(alpha: 0.12),
                fg: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              Text(
                '${svc.progressPercent}%',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Completion',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                      child: LinearProgressIndicator(
                        value: svc.progressPercent / 100,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Container(
            padding: const EdgeInsets.all(AppDimensions.s12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                const SizedBox(width: AppDimensions.s8),
                Text(
                  'Estimated Ready: ${svc.estCompletion}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
