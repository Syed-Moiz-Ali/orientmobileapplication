import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBreakdownDetailView extends ConsumerWidget {
  final Map<String, dynamic> breakdown;
  const CustomerBreakdownDetailView({super.key, required this.breakdown});

  (Color, Color) _statusColors(String s) {
    switch (s) {
      case 'resolved':
        return (AppColors.successBg, AppColors.success);
      case 'inProgress':
        return (AppColors.infoBg, AppColors.info);
      default:
        return (AppColors.warningBg, AppColors.warning);
    }
  }

  String _statusLabel(String s) =>
      AppStatusLabels.breakdown(s);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = breakdown['status'] as String? ?? 'pending';
    final (bg, fg) = _statusColors(status);
    final issue = breakdown['issue'] as String? ?? 'Breakdown';
    final vehicleName = breakdown['vehicleName'] as String? ?? '';
    final vehiclePlate = breakdown['vehiclePlate'] as String? ?? '';
    final location = breakdown['location'] as String? ?? '';
    final createdAt = breakdown['createdAt'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'Breakdown Request'),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.s18),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.s20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.danger.withValues(alpha: 0.1), AppColors.danger.withValues(alpha: 0.04)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
                            child: const Icon(Icons.emergency_rounded, color: AppColors.danger, size: 32),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          Text(
                            issue,
                            style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.s6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.r20)),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    AppCard(
                      child: Column(
                        children: [
                          _detailRow(Icons.directions_car_rounded, 'Vehicle', vehicleName.isNotEmpty ? '$vehicleName  \u00b7  $vehiclePlate' : 'Not specified'),
                          if (location.isNotEmpty) ...[
                            const Divider(height: 24),
                            _detailRow(Icons.location_on_outlined, 'Location', location),
                          ],
                          const Divider(height: 24),
                          _detailRow(Icons.access_time_rounded, 'Requested', _formatDate(createdAt)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      decoration: BoxDecoration(
                        color: status == 'resolved' ? AppColors.successBg : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r14),
                        border: Border.all(
                          color: status == 'resolved' ? AppColors.successBorder : AppColors.warningBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status == 'resolved' ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            color: status == 'resolved' ? AppColors.success : AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.s8),
                          Expanded(
                            child: Text(
                              status == 'resolved'
                                  ? 'This breakdown request has been resolved.'
                                  : 'Your request is being processed. We\'ll reach out shortly.',
                              style: TextStyle(
                                color: status == 'resolved' ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
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
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(AppDimensions.r10)),
          child: Icon(icon, color: AppColors.danger, size: 18),
        ),
        const SizedBox(width: AppDimensions.s12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}