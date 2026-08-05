import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_empty_fallbacks.dart';
import 'package:customer_app/features/customer/presentation/widgets/garage_info_card.dart';
import 'package:customer_app/features/customer/presentation/widgets/advisor_contact_card.dart';
import 'package:customer_app/core/router/app_router.dart';

class CustomerServiceStatusTab extends ConsumerStatefulWidget {
  const CustomerServiceStatusTab({super.key});

  @override
  ConsumerState<CustomerServiceStatusTab> createState() => _CustomerServiceStatusTabState();
}

class _CustomerServiceStatusTabState extends ConsumerState<CustomerServiceStatusTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh active service tracking every 60 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      ref.read(customerDashboardProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(customerBookingsProvider).value ?? const <CustomerBookingEntity>[];
    final breakdowns = ref.watch(customerBreakdownsProvider);
    final dash = ref.watch(customerDashboardProvider);
    final activeService = dash.activeService;
    final hasActiveService = activeService != null && activeService.hasActiveJob && activeService.jobCardId.isNotEmpty;
    final activeBookings = bookings.where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(customerDashboardProvider.notifier).refresh();
      },
      color: AppColors.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s16,
          AppDimensions.s16,
          AppDimensions.s16,
          AppDimensions.s32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Tracker',
                        style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Real-time workshop stage monitoring',
                        style: TextStyle(fontSize: 12, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'LIVE UPDATES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),

            // Main Active Job or Idle Section
            if (hasActiveService) ...[
              _ActiveServiceTimelineCard(service: activeService),
              const SizedBox(height: AppDimensions.s14),
              AdvisorContactCard(
                advisorName: activeService.technicianName.isNotEmpty ? activeService.technicianName : 'Ahmed Hassan',
              ),
              const SizedBox(height: AppDimensions.s24),
            ] else if (activeBookings.isNotEmpty) ...[
              _ActiveServiceCard(booking: activeBookings.first),
              const SizedBox(height: AppDimensions.s24),
            ] else ...[
              IdleServiceCard(
                onBook: () => context.push(AppRoutes.customerBookService),
              ),
              const SizedBox(height: AppDimensions.s16),
              EmergencyBreakdownBanner(
                onTap: () => context.push(AppRoutes.customerBreakdownHelp),
              ),
              const SizedBox(height: AppDimensions.s24),
            ],

            // Workshop Location & Direct Contact Card
            _sectionLabel('Workshop Info & Location'),
            const SizedBox(height: AppDimensions.s12),
            const GarageInfoCard(),

            // Booking History List
            if (bookings.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s28),
              _sectionLabel('Booking History'),
              const SizedBox(height: AppDimensions.s12),
              ...bookings.map((b) {
                final (bg, fg) = _statusColors(b.status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.s10),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.customerBookingDetail, extra: b),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.s12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: bg.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppDimensions.r10),
                            ),
                            child: Icon(Icons.build_circle_outlined, color: fg, size: 20),
                          ),
                          const SizedBox(width: AppDimensions.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.service.isNotEmpty ? b.service : 'Service Booking',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${b.vehicleName}  \u00b7  ${b.date}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.text3),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.r20)),
                            child: Text(b.statusLabel, style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],

            // Breakdown Requests History
            if (breakdowns.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s28),
              _sectionLabel('Breakdown Assistance History'),
              const SizedBox(height: AppDimensions.s12),
              ...breakdowns.take(3).map((b) {
                final status = b['status'] as String? ?? 'pending';
                final isResolved = status == 'resolved';
                final clr = isResolved ? AppColors.success : AppColors.warning;
                final bgColor = isResolved ? AppColors.successBg : AppColors.warningBg;
                final statusLabel = isResolved ? 'Resolved' : status == 'inProgress' ? 'In Progress' : 'Pending';
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.s10),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.customerBreakdownDetail, extra: b),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.s12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(AppDimensions.r10),
                            ),
                            child: const Icon(Icons.emergency_rounded, color: AppColors.danger, size: 20),
                          ),
                          const SizedBox(width: AppDimensions.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b['issue'] as String? ?? 'Breakdown Assistance',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b['vehicleName'] as String? ?? '',
                                  style: const TextStyle(fontSize: 11, color: AppColors.text3),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppDimensions.r20)),
                            child: Text(statusLabel, style: TextStyle(color: clr, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: AppDimensions.s10),
      Text(
        text,
        style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
      ),
    ],
  );
}

class _ActiveServiceTimelineCard extends StatelessWidget {
  final CustomerServiceEntity service;
  const _ActiveServiceTimelineCard({required this.service});

  (Color, Color) _stageColors(StageStatus s) {
    switch (s) {
      case StageStatus.done:
        return (AppColors.success, AppColors.successBg);
      case StageStatus.inProgress:
        return (AppColors.warning, AppColors.warningBg);
      case StageStatus.pending:
        return (AppColors.text3, AppColors.surfaceAlt);
    }
  }

  String _stageLabel(StageStatus s) {
    switch (s) {
      case StageStatus.done:
        return 'Completed';
      case StageStatus.inProgress:
        return 'In progress...';
      case StageStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = service.stages;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerServiceStatus),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.s18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF40B3C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.service.isNotEmpty ? service.service : 'Service in Progress',
                        style: AppTextStyles.rajdhaniLabel(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.vehicleName.isNotEmpty
                            ? '${service.vehicleName}  \u00b7  ${service.plateNumber}'
                            : 'Job Card ${service.jobCardId}',
                        style: const TextStyle(fontSize: 12, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyanLight,
                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                  ),
                  child: Text(
                    '${service.progressPercent}%',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                const Icon(Icons.badge_outlined, color: AppColors.text3, size: 12),
                const SizedBox(width: 5),
                Text('Job Card: ${service.jobCardId}', style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                const Spacer(),
                const Text(
                  'Tap for details \u203a',
                  style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s14),
            LinearProgressIndicator(
              value: (service.progressPercent / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceAlt,
              color: AppColors.accent,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: AppDimensions.s18),
            ...stages.asMap().entries.map((e) {
              final i = e.key;
              final stage = e.value;
              final isLast = i == stages.length - 1;
              final (fg, bg) = _stageColors(stage.status);
              final completed = stage.status == StageStatus.done;
              final active = stage.status == StageStatus.inProgress;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: completed ? AppColors.success : active ? fg : AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: completed ? AppColors.success : active ? fg : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            completed ? Icons.check_rounded : active ? Icons.autorenew_rounded : Icons.circle_outlined,
                            size: 12,
                            color: completed || active ? Colors.white : AppColors.text3,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 28,
                            color: completed ? AppColors.success : AppColors.border,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage.name,
                            style: TextStyle(
                              color: active ? fg : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stage.time ?? _stageLabel(stage.status),
                            style: const TextStyle(color: AppColors.text3, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (active)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.r20)),
                      child: Text('Current', style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ActiveServiceCard extends StatelessWidget {
  final CustomerBookingEntity booking;
  const _ActiveServiceCard({required this.booking});

  List<_StepData> get _steps {
    switch (booking.status) {
      case BookingStatus.pending:
        return [
          _StepData('Booking Placed', true, true),
          _StepData('Awaiting Confirmation', true, false),
          _StepData('Service in Progress', false, false),
          _StepData('Completed', false, false),
        ];
      case BookingStatus.confirmed:
        return [
          _StepData('Booking Placed', true, false),
          _StepData('Confirmed', true, false),
          _StepData('Service in Progress', true, true),
          _StepData('Completed', false, false),
        ];
      default:
        return [
          _StepData('Booking Placed', true, false),
          _StepData(booking.statusLabel, true, true),
        ];
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _statusColors(booking.status);
    final steps = _steps;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerBookingDetail, extra: booking),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.s18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [fg, fg.withValues(alpha: 0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appointment', style: AppTextStyles.rajdhaniLabel(color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('${booking.vehicleName}  \u00b7  ${booking.plateNumber}', style: const TextStyle(fontSize: 12, color: AppColors.text3)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.r20)),
                  child: Text(booking.statusLabel, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s20),
            ...steps.asMap().entries.map((e) {
              final i = e.key;
              final step = e.value;
              final isLast = i == steps.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
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
                            size: 12,
                            color: step.completed || step.active ? Colors.white : AppColors.text3,
                          ),
                        ),
                        if (!isLast)
                          Container(width: 2, height: 28, color: step.completed ? AppColors.success : AppColors.border),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              color: step.active ? fg : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.completed ? 'Completed' : step.active ? 'In progress...' : 'Pending',
                            style: const TextStyle(color: AppColors.text3, fontSize: 11),
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
      ),
    );
  }
}

class _StepData {
  final String title;
  final bool completed;
  final bool active;
  const _StepData(this.title, this.completed, this.active);
}