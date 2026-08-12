import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBreakdownDetailView extends ConsumerWidget {
  final Map<String, dynamic> breakdown;

  const CustomerBreakdownDetailView({super.key, required this.breakdown});

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'resolved':
        return (AppColors.successBg, AppColors.success);
      case 'inProgress':
        return (AppColors.infoBg, AppColors.info);
      default:
        return (AppColors.warningBg, AppColors.warning);
    }
  }

  String _statusLabel(String status) => AppStatusLabels.breakdown(status);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final status = breakdown['status'] as String? ?? 'pending';
    final (bg, fg) = _statusColors(status);
    final issue = breakdown['issue'] as String? ?? 'Breakdown';
    final vehicleName = breakdown['vehicleName'] as String? ?? '';
    final vehiclePlate = breakdown['vehiclePlate'] as String? ?? '';
    final location = breakdown['location'] as String? ?? '';
    final createdAt = breakdown['createdAt'] as String? ?? '';
    final resolved = status == 'resolved';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Breakdown Request'),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: AppResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact Status Banner
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.s12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emergency_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(createdAt),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.text3,
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
                    const SizedBox(height: AppDimensions.s14),

                    // Details Card
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.s14),
                      color: AppColors.surface,
                      borderColor: AppColors.border,
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.s10,
                              ),
                              child: Divider(height: 1, color: AppColors.line),
                            ),
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: location,
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.s10,
                            ),
                            child: Divider(height: 1, color: AppColors.line),
                          ),
                          _DetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'Requested',
                            value: _formatDate(createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s14),

                    // Resolution Info Box
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.s12),
                      decoration: BoxDecoration(
                        color: resolved
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                        border: Border.all(
                          color: resolved
                              ? AppColors.successBorder
                              : AppColors.warningBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            resolved
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            color: resolved
                                ? AppColors.success
                                : AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.s10),
                          Expanded(
                            child: Text(
                              resolved
                                  ? 'This breakdown request has been resolved.'
                                  : 'Dispatch team is en route. Contact helpline for emergency status.',
                              style: textTheme.bodySmall?.copyWith(
                                color: resolved
                                    ? AppColors.success
                                    : AppColors.warning,
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
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.dangerBg,
            borderRadius: BorderRadius.circular(AppDimensions.r10),
          ),
          child: Icon(icon, color: AppColors.danger, size: 18),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.text3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
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
