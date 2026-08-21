import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBreakdownDetailView extends ConsumerWidget {
  final Map<String, dynamic> breakdown;

  const CustomerBreakdownDetailView({super.key, required this.breakdown});

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'resolved':
        return (const Color(0xFF10B981).withValues(alpha: 0.12), const Color(0xFF10B981));
      case 'inProgress':
        return (const Color(0xFF3B82F6).withValues(alpha: 0.12), const Color(0xFF3B82F6));
      default:
        return (const Color(0xFFD97706).withValues(alpha: 0.12), const Color(0xFFD97706));
    }
  }

  String _statusLabel(String status) => AppStatusLabels.breakdown(status);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final status = breakdown['status'] as String? ?? 'pending';
    final (bg, fg) = _statusColors(status);
    final issue = breakdown['issue'] as String? ?? 'Breakdown';
    final vehicleName = breakdown['vehicleName'] as String? ?? '';
    final vehiclePlate = breakdown['vehiclePlate'] as String? ?? '';
    final location = breakdown['location'] as String? ?? '';
    final createdAt = breakdown['createdAt'] as String? ?? '';
    final resolved = status == 'resolved';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Breakdown Request'),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emergency_rounded,
                              color: colorScheme.onError,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(createdAt),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusPill(
                            label: _statusLabel(status),
                            bg: bg,
                            fg: fg,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),

                    // Details Card
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      borderRadius: AppDimensions.r20,
                      color: colorScheme.surface,
                      borderColor: colorScheme.outlineVariant,
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.directions_car_rounded,
                            label: 'Vehicle',
                            value: vehicleName.isNotEmpty
                                ? '$vehicleName • $vehiclePlate'
                                : 'Not specified',
                          ),
                          if (location.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.s12,
                              ),
                              child: Divider(height: 1, color: colorScheme.outlineVariant),
                            ),
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: location,
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.s12,
                            ),
                            child: Divider(height: 1, color: colorScheme.outlineVariant),
                          ),
                          _DetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'Requested',
                            value: _formatDate(createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),

                    // Resolution Info Box
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.s14),
                      decoration: BoxDecoration(
                        color: resolved
                            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                            : colorScheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(
                          color: resolved
                              ? colorScheme.primary.withValues(alpha: 0.3)
                              : colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            resolved
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            color: resolved
                                ? colorScheme.primary
                                : colorScheme.error,
                            size: 22,
                          ),
                          const SizedBox(width: AppDimensions.s12),
                          Expanded(
                            child: Text(
                              resolved
                                  ? 'This breakdown request has been resolved.'
                                  : 'Dispatch team is en route. Contact helpline for emergency status.',
                              style: textTheme.bodySmall?.copyWith(
                                color: resolved
                                    ? colorScheme.primary
                                    : colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.r12),
          ),
          child: Icon(icon, color: colorScheme.error, size: 18),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
