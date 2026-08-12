import 'dart:async';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/advisor_contact_card.dart';
import 'package:customer_app/features/customer/presentation/widgets/garage_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerServiceStatusTab extends ConsumerStatefulWidget {
  const CustomerServiceStatusTab({super.key});

  @override
  ConsumerState<CustomerServiceStatusTab> createState() =>
      _CustomerServiceStatusTabState();
}

class _CustomerServiceStatusTabState
    extends ConsumerState<CustomerServiceStatusTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted || !TickerMode.of(context)) return;
      final dash = ref.read(customerDashboardProvider);
      final svc = dash.activeService;
      if (svc == null || !svc.hasActiveJob || svc.jobCardId.isEmpty) return;
      ref.read(customerDashboardProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bookings =
        ref.watch(customerBookingsProvider).value ??
        const <CustomerBookingEntity>[];
    final dash = ref.watch(customerDashboardProvider);
    final activeService = dash.activeService;
    final hasActiveLiveJob =
        activeService != null &&
        activeService.hasActiveJob &&
        activeService.jobCardId.isNotEmpty;

    // Filter pending or confirmed bookings
    final activeBookings = bookings
        .where(
          (b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pending,
        )
        .toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(customerDashboardProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PAGE HEADER
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.s12,
                  bottom: AppDimensions.s8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Status Tracker 📡',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasActiveLiveJob
                                ? 'Live telemetry repair stage & completion ETA'
                                : activeBookings.isNotEmpty
                                ? 'Pending appointment awaiting workshop check-in'
                                : 'All systems clear • No pending services',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.text3,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    GestureDetector(
                      onTap: () =>
                          context.push(AppRoutes.customerNotifications),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                          if (dash.unreadCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.rPill,
                                  ),
                                  border: Border.all(
                                    color: AppColors.bg,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  dash.unreadCount > 99
                                      ? '99+'
                                      : '${dash.unreadCount}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              // 2. ACTIVE SERVICE OR PENDING BOOKING CARD
              if (hasActiveLiveJob) ...[
                _ActiveJobTelemetryHero(service: activeService),
                const SizedBox(height: AppDimensions.s16),
                AdvisorContactCard(
                  advisorName: activeService.technicianName.isNotEmpty
                      ? activeService.technicianName
                      : 'Service Advisor',
                ),
                const SizedBox(height: AppDimensions.s24),
              ] else if (activeBookings.isNotEmpty) ...[
                // FIX: SHOW PENDING SERVICE CARD WHEN SERVICE IS PENDING OR CONFIRMED!
                _PendingServiceStatusCard(
                  booking: activeBookings.first,
                  onViewDetails: () => context.push(
                    AppRoutes.customerBookingDetail,
                    extra: activeBookings.first,
                  ),
                ),
                const SizedBox(height: AppDimensions.s24),
              ] else ...[
                _NoActiveJobStatusCard(
                  onBook: () => context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: AppDimensions.s24),
              ],

              // 3. WORKSHOP INFORMATION & LOCATION
              _ExplanatorySectionHeader(
                title: 'Workshop Location & Hours',
                subtitle: 'Visit our main workshop bay or get live directions',
              ),
              const SizedBox(height: AppDimensions.s10),
              const GarageInfoCard(),
              const SizedBox(height: AppDimensions.s24),

              // 4. SERVICE & MAINTENANCE RECORDS
              if (bookings.isNotEmpty) ...[
                _ExplanatorySectionHeader(
                  title: 'Service & Maintenance Records',
                  subtitle: 'Past service receipts & inspection reports',
                  action: 'View All',
                  onAction: () =>
                      ref.read(customerDashboardProvider.notifier).selectTab(2),
                ),
                const SizedBox(height: AppDimensions.s10),
                Column(
                  children: [
                    for (final b in bookings.take(3)) ...[
                      _ServiceRecordCard(
                        booking: b,
                        onTap: () => context.push(
                          AppRoutes.customerBookingDetail,
                          extra: b,
                        ),
                      ),
                      if (b != bookings.take(3).last)
                        const SizedBox(height: AppDimensions.s10),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.s32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// PENDING OR CONFIRMED SERVICE STATUS CARD (Fixes "No Active Job" bug for pending services)
class _PendingServiceStatusCard extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onViewDetails;

  const _PendingServiceStatusCard({
    required this.booking,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isConfirmed = booking.status == BookingStatus.confirmed;

    return AppCard(
      onTap: onViewDetails,
      color: AppColors.surface,
      borderColor: isConfirmed
          ? AppColors.primaryBorder
          : AppColors.warningBorder,
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s18),
      boxShadow: [
        BoxShadow(
          color: (isConfirmed ? AppColors.primary : AppColors.warning)
              .withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isConfirmed
                      ? AppColors.primaryBg
                      : AppColors.warningBg),
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  border: Border.all(
                    color: (isConfirmed
                        ? AppColors.primaryBorder
                        : AppColors.warningBorder),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? AppColors.primary
                            : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Text(
                      isConfirmed
                          ? 'SERVICE CONFIRMED • AWAITING INTAKE'
                          : 'SERVICE PENDING WORKSHOP CONFIRMATION',
                      style: textTheme.labelSmall?.copyWith(
                        color: isConfirmed
                            ? AppColors.primary
                            : AppColors.warning,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              StatusPill(
                label: booking.statusLabel,
                bg: isConfirmed ? AppColors.primaryBg : AppColors.warningBg,
                fg: isConfirmed ? AppColors.primary : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            booking.service.isNotEmpty
                ? booking.service
                : 'Scheduled Service Appointment',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  booking.plateNumber,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Text(
                  booking.vehicleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.text3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),

          // Scheduled Date & Time Pill Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s10,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    'Scheduled for: ${booking.date}${booking.time.isNotEmpty ? " at ${booking.time}" : ""}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s16),

          // Visual Stepper Pipeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _StepCircle(label: 'Booked', isDone: true),
              const _StepLine(isDone: true),
              _StepCircle(
                label: 'Check-In',
                isCurrent: isConfirmed,
                isDone: isConfirmed,
              ),
              const _StepLine(isDone: false),
              const _StepCircle(label: 'Repairs', isDone: false),
              const _StepLine(isDone: false),
              const _StepCircle(label: 'Pick-Up', isDone: false),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),

          // Action Button
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.rPill),
            ),
            child: Center(
              child: Text(
                'View Booking Details & Instructions →',
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// NO ACTIVE JOB CARD (Clear Explanation & Call To Action)
class _NoActiveJobStatusCard extends StatelessWidget {
  final VoidCallback onBook;

  const _NoActiveJobStatusCard({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s20),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Pending or Active Service Jobs',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your vehicle is idle and ready for driving.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due for maintenance or routine checkup?',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s16,
                    vertical: AppDimensions.s10,
                  ),
                ),
                child: const Text(
                  'Book Service →',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ACTIVE JOB TELEMETRY HERO (Clear Visual Stages)
class _ActiveJobTelemetryHero extends StatelessWidget {
  final CustomerServiceEntity service;

  const _ActiveJobTelemetryHero({required this.service});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = (service.progressPercent.clamp(0, 100) / 100).toDouble();

    return AppCard(
      color: AppColors.surface,
      borderColor: AppColors.primaryBorder,
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Text(
                      'STAGE 3 OF 4 • IN PROGRESS',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${service.progressPercent}% Completed',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            service.currentStage.isNotEmpty
                ? service.currentStage
                : 'Service In Progress',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vehicle: ${service.vehicleName} (${service.plateNumber}) • Job #${service.jobCardId}',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.text3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.s14),

          // Visual Stepper Pipeline
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepCircle(label: 'Check-In', isDone: true),
              _StepLine(isDone: true),
              _StepCircle(label: 'Inspection', isDone: true),
              _StepLine(isDone: true),
              _StepCircle(label: 'Repairing', isCurrent: true),
              _StepLine(isDone: false),
              _StepCircle(label: 'Pick-Up', isDone: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;

  const _StepCircle({
    required this.label,
    this.isDone = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : isCurrent
        ? AppColors.primary
        : AppColors.text4;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isCurrent
                ? color.withValues(alpha: 0.15)
                : AppColors.surfaceAlt,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isCurrent ? 2 : 1),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, size: 14, color: color)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent || isDone ? FontWeight.w900 : FontWeight.w500,
            color: isCurrent || isDone
                ? AppColors.textPrimary
                : AppColors.text4,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;

  const _StepLine({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isDone ? AppColors.success : AppColors.border,
      ),
    );
  }
}

class _ServiceRecordCard extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _ServiceRecordCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s14),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.service.isNotEmpty
                      ? booking.service
                      : 'Completed Service',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.vehicleName} • ${booking.date}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.text3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: booking.statusLabel,
            bg: AppColors.successBg,
            fg: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _ExplanatorySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;

  const _ExplanatorySectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.text3,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
