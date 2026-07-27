import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class CustomerBookingDetailView extends ConsumerWidget {
  final CustomerBookingEntity booking;
  const CustomerBookingDetailView({super.key, required this.booking});

  (Color, Color) _statusColors(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return (const Color(0xFFB2E0E5), AppColors.accent);
      case BookingStatus.completed:
        return (AppColors.successBg, AppColors.success);
      case BookingStatus.pending:
        return (AppColors.warningBg, AppColors.warning);
      case BookingStatus.cancelled:
        return (AppColors.dangerBg, AppColors.danger);
    }
  }

  List<_StatusStep> _steps(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return [
          _StatusStep('Booking Placed', true, true),
          _StatusStep('Awaiting Confirmation', true, false),
          _StatusStep('Service in Progress', false, false),
          _StatusStep('Completed', false, false),
        ];
      case BookingStatus.confirmed:
        return [
          _StatusStep('Booking Placed', true, false),
          _StatusStep('Confirmed', true, false),
          _StatusStep('Service in Progress', true, true),
          _StatusStep('Completed', false, false),
        ];
      case BookingStatus.completed:
        return [
          _StatusStep('Booking Placed', true, false),
          _StatusStep('Confirmed', true, false),
          _StatusStep('Service Completed', true, false),
          _StatusStep('Ready for Collection', true, true),
        ];
      case BookingStatus.cancelled:
        return [
          _StatusStep('Booking Placed', true, false),
          _StatusStep('Confirmed', true, false),
          _StatusStep('Cancelled', false, true),
        ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (bg, fg) = _statusColors(booking.status);
    final steps = _steps(booking.status);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'Booking Details'),
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
                          colors: [fg.withValues(alpha: 0.1), fg.withValues(alpha: 0.04)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(color: fg.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                            child: Icon(
                              booking.status == BookingStatus.completed
                                  ? Icons.check_circle_rounded
                                  : booking.status == BookingStatus.cancelled
                                      ? Icons.cancel_rounded
                                      : Icons.build_circle_outlined,
                              color: fg, size: 32,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          Text(
                            booking.service,
                            style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.s6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.r20)),
                            child: Text(
                              booking.statusLabel,
                              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    _StatusTimeline(steps: steps, fg: fg),
                    const SizedBox(height: AppDimensions.s20),
                    AppCard(
                      child: Column(
                        children: [
                          _detailRow(Icons.directions_car_rounded, 'Vehicle', '${booking.vehicleName}  \u00b7  ${booking.plateNumber}'),
                          const Divider(height: 24),
                          _detailRow(Icons.calendar_month_rounded, 'Date', booking.date),
                          if (booking.time.isNotEmpty) ...[
                            const Divider(height: 24),
                            _detailRow(Icons.schedule_rounded, 'Time', booking.time),
                          ],
                        ],
                      ),
                    ),
                    if (booking.status == BookingStatus.completed)
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.s20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.s16),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(AppDimensions.r14),
                            border: Border.all(color: AppColors.successBorder),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                              SizedBox(width: AppDimensions.s8),
                              Text(
                                'Service completed successfully',
                                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.cyanLight, borderRadius: BorderRadius.circular(AppDimensions.r10)),
          child: Icon(icon, color: AppColors.accent, size: 18),
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

class _StatusStep {
  final String title;
  final bool completed;
  final bool active;
  const _StatusStep(this.title, this.completed, this.active);
}

class _StatusTimeline extends StatelessWidget {
  final List<_StatusStep> steps;
  final Color fg;
  const _StatusTimeline({required this.steps, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: fg, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: AppDimensions.s10),
              Text('Status Flow', style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: AppDimensions.s18),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            final isLast = i == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: step.completed ? AppColors.success : step.active ? fg : AppColors.surfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: step.completed ? AppColors.success : step.active ? fg : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          step.completed ? Icons.check_rounded : step.active ? Icons.autorenew_rounded : Icons.circle_outlined,
                          size: 14,
                          color: step.completed || step.active ? Colors.white : AppColors.text3,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2, height: 36,
                          color: step.completed ? AppColors.success : AppColors.border,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            color: step.active ? fg : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.completed ? 'Done' : step.active ? 'In progress...' : 'Pending',
                          style: TextStyle(color: AppColors.text3, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}