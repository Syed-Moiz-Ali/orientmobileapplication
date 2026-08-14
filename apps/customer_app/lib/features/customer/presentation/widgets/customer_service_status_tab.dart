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
    // Retaining the 60-second polling logic for active live jobs
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bookings =
        ref.watch(customerBookingsProvider).value ??
        const <CustomerBookingEntity>[];
    final dash = ref.watch(customerDashboardProvider);
    final activeService = dash.activeService;

    // Core state checks
    final hasActiveLiveJob =
        activeService != null &&
        activeService.hasActiveJob &&
        activeService.jobCardId.isNotEmpty;
    final activeBookings = bookings
        .where(
          (b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pending,
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      // ── FLOATING BOOK ACTION (Consistent with Home Tab) ──────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton.extended(
          heroTag: 'customer-status-book-service-fab',
          onPressed: () => context.push(AppRoutes.customerBookService),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          icon: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
          label: Text(
            'New Booking',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(customerDashboardProvider.notifier).refresh();
          },
          color: colorScheme.primary,
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 1. PREMIUM HEADER ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Tracker',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasActiveLiveJob
                                ? 'Live telemetry repair stage & ETA'
                                : activeBookings.isNotEmpty
                                ? 'Pending appointment awaiting check-in'
                                : 'All systems clear • No active services',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: colorScheme.onSurface,
                              size: 24,
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
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  dash.unreadCount > 99
                                      ? '99+'
                                      : '${dash.unreadCount}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onError,
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
                const SizedBox(height: 32),

                // ── 2. DYNAMIC STATUS CARD ─────────────────────────────────────
                if (hasActiveLiveJob) ...[
                  _ActiveJobTelemetryHero(service: activeService),
                  const SizedBox(height: 16),
                  AdvisorContactCard(
                    advisorName: activeService.technicianName.isNotEmpty
                        ? activeService.technicianName
                        : 'Service Advisor',
                  ),
                  const SizedBox(height: 36),
                ] else if (activeBookings.isNotEmpty) ...[
                  _PendingServiceStatusCard(
                    booking: activeBookings.first,
                    onViewDetails: () => context.push(
                      AppRoutes.customerBookingDetail,
                      extra: activeBookings.first,
                    ),
                  ),
                  const SizedBox(height: 36),
                ] else ...[
                  _NoActiveJobStatusCard(
                    onBook: () => context.push(AppRoutes.customerBookService),
                  ),
                  const SizedBox(height: 36),
                ],

                // ── 3. WORKSHOP INFORMATION ────────────────────────────────────
                _ExplanatorySectionHeader(
                  title: 'Workshop Location',
                  subtitle: 'Visit our main bay or get live directions',
                ),
                const SizedBox(height: 16),
                const GarageInfoCard(), // Assuming this widget internally uses AppCard + outlineVariant now
                const SizedBox(height: 36),

                // ── 4. SERVICE RECORDS ─────────────────────────────────────────
                if (bookings.isNotEmpty) ...[
                  _ExplanatorySectionHeader(
                    title: 'Maintenance Records',
                    subtitle: 'Past service receipts & reports',
                    action: 'View All',
                    onAction: () => ref
                        .read(customerDashboardProvider.notifier)
                        .selectTab(2),
                  ),
                  const SizedBox(height: 16),
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
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                  const SizedBox(
                    height: 80,
                  ), // Padding for Floating Action Button
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PENDING SERVICE STATUS CARD ─────────────────────────────────────────────
class _PendingServiceStatusCard extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onViewDetails;

  const _PendingServiceStatusCard({
    required this.booking,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isConfirmed = booking.status == BookingStatus.confirmed;

    final highlightColor = isConfirmed
        ? colorScheme.primary
        : colorScheme.secondary;

    return AppCard(
      onTap: onViewDetails,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 16,
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
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConfirmed
                          ? 'CONFIRMED • AWAITING INTAKE'
                          : 'PENDING CONFIRMATION',
                      style: textTheme.labelSmall?.copyWith(
                        color: highlightColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              StatusPill(
                label: booking.statusLabel,
                bg: highlightColor.withValues(alpha: 0.15),
                fg: highlightColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            booking.service.isNotEmpty
                ? booking.service
                : 'Scheduled Appointment',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.plateNumber.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.vehicleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Scheduled Date Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scheduled: ${booking.date}${booking.time.isNotEmpty ? " at ${booking.time}" : ""}',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Visual Stepper Pipeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepCircle(label: 'Booked', isDone: true, color: highlightColor),
              _StepLine(isDone: true, color: highlightColor),
              _StepCircle(
                label: 'Check-In',
                isCurrent: isConfirmed,
                isDone: isConfirmed,
                color: highlightColor,
              ),
              _StepLine(isDone: false, color: highlightColor),
              _StepCircle(
                label: 'Repairs',
                isDone: false,
                color: highlightColor,
              ),
              _StepLine(isDone: false, color: highlightColor),
              _StepCircle(
                label: 'Pick-Up',
                isDone: false,
                color: highlightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── NO ACTIVE JOB CARD (Clean & Elegant) ────────────────────────────────────
class _NoActiveJobStatusCard extends StatelessWidget {
  final VoidCallback onBook;

  const _NoActiveJobStatusCard({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Active Services',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your vehicle is idle and ready.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due for routine maintenance?',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── ACTIVE JOB TELEMETRY HERO (Premium Dark Uber-Style) ─────────────────────
class _ActiveJobTelemetryHero extends StatelessWidget {
  final CustomerServiceEntity service;

  const _ActiveJobTelemetryHero({required this.service});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = (service.progressPercent.clamp(0, 100) / 100).toDouble();

    return AppCard(
      color: colorScheme.inverseSurface, // Deep luxury contrast
      borderColor: Colors.transparent,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE TELEMETRY',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${service.progressPercent}%',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            service.currentStage.isNotEmpty
                ? service.currentStage
                : 'Service In Progress',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onInverseSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${service.vehicleName} (${service.plateNumber.toUpperCase()}) • Job #${service.jobCardId}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.onInverseSurface.withValues(
                alpha: 0.15,
              ),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),

          // Visual Stepper Pipeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepCircle(
                label: 'Check-In',
                isDone: true,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
              _StepLine(
                isDone: true,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
              _StepCircle(
                label: 'Inspection',
                isDone: true,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
              _StepLine(
                isDone: true,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
              _StepCircle(
                label: 'Repairing',
                isCurrent: true,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
              _StepLine(
                isDone: false,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
              _StepCircle(
                label: 'Pick-Up',
                isDone: false,
                color: colorScheme.primary,
                isDarkBg: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── STEPPER WIDGETS ─────────────────────────────────────────────────────────
class _StepCircle extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;
  final Color color;
  final bool isDarkBg;

  const _StepCircle({
    required this.label,
    this.isDone = false,
    this.isCurrent = false,
    required this.color,
    this.isDarkBg = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Explicitly defining a success color strictly inside the widget since AppTheme lacks it
    final resolvedColor = isDone ? const Color(0xFF10B981) : color;
    final emptyColor = isDarkBg
        ? colorScheme.onInverseSurface.withValues(alpha: 0.2)
        : colorScheme.surfaceContainerHighest;
    final textColor = isDarkBg
        ? colorScheme.onInverseSurface
        : colorScheme.onSurface;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isCurrent
                ? resolvedColor.withValues(alpha: 0.15)
                : emptyColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone || isCurrent ? resolvedColor : Colors.transparent,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, size: 14, color: resolvedColor)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCurrent ? resolvedColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent || isDone ? FontWeight.w900 : FontWeight.w600,
            color: isCurrent || isDone
                ? textColor
                : textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;
  final Color color;
  final bool isDarkBg;

  const _StepLine({
    required this.isDone,
    required this.color,
    this.isDarkBg = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final emptyColor = isDarkBg
        ? colorScheme.onInverseSurface.withValues(alpha: 0.1)
        : colorScheme.surfaceContainerHighest;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18), // Aligned with the circles
        color: isDone ? const Color(0xFF10B981) : emptyColor,
      ),
    );
  }
}

// ─── SERVICE RECORD LIST ITEM ────────────────────────────────────────────────
class _ServiceRecordCard extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _ServiceRecordCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.vehicleName} • ${booking.date}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: booking.statusLabel,
            bg: const Color(0xFF10B981).withValues(alpha: 0.15),
            fg: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
