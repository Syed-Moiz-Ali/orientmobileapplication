import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBookingDetailView extends ConsumerWidget {
  final CustomerBookingEntity booking;

  const CustomerBookingDetailView({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final cancellable =
        booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;

    final statusColor = _statusColor(booking.status);
    final statusBg = _statusBg(booking.status);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Appointment Details'),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.s16),

                    // ── STATUS HEADER CARD ──────────────────────────────────
                    AppCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(AppDimensions.s18),
                      color: AppColors.surface,
                      borderColor: AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status pill
                          Row(
                            children: [
                              StatusPill(
                                label: booking.statusLabel.toUpperCase(),
                                bg: statusBg,
                                fg: statusColor,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '#${booking.id.length > 8 ? booking.id.substring(booking.id.length - 8) : booking.id}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.text3,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          // Service name
                          Text(
                            booking.service.isNotEmpty
                                ? booking.service
                                : 'Scheduled Service',
                            style: textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Plate + vehicle
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  booking.plateNumber.toUpperCase(),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFFACC15),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s8),
                              Expanded(
                                child: Text(
                                  booking.vehicleName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.text3,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),

                    // ── APPOINTMENT DETAILS CARD ────────────────────────────
                    _SectionHeader(title: 'Appointment Details', subtitle: 'Date, time & vehicle summary'),
                    const SizedBox(height: AppDimensions.s10),
                    AppCard(
                      borderRadius: 24,
                      padding: EdgeInsets.zero,
                      color: AppColors.surface,
                      borderColor: AppColors.border,
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: booking.date.isNotEmpty ? booking.date : 'TBC',
                          ),
                          const Divider(height: 1, color: AppColors.line),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Time',
                            value: booking.time.isNotEmpty ? booking.time : 'TBC',
                          ),
                          const Divider(height: 1, color: AppColors.line),
                          _InfoRow(
                            icon: Icons.directions_car_rounded,
                            label: 'Vehicle',
                            value: booking.vehicleName.isNotEmpty
                                ? booking.vehicleName
                                : '—',
                          ),
                          const Divider(height: 1, color: AppColors.line),
                          _InfoRow(
                            icon: Icons.pin_rounded,
                            label: 'Registration',
                            value: booking.plateNumber.toUpperCase(),
                          ),
                          const Divider(height: 1, color: AppColors.line),
                          _InfoRow(
                            icon: Icons.build_rounded,
                            label: 'Service Type',
                            value: booking.service.isNotEmpty ? booking.service : '—',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),

                    // ── PROGRESS TRACKER ────────────────────────────────────
                    _SectionHeader(
                      title: 'Service Progress',
                      subtitle: 'Live stage tracker updated by the workshop',
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    AppCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(AppDimensions.s18),
                      color: AppColors.surface,
                      borderColor: AppColors.border,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StepCircle(
                            label: 'Booked',
                            isDone: true,
                          ),
                          _StepLine(
                            isDone: booking.status == BookingStatus.confirmed ||
                                booking.status == BookingStatus.completed ||
                                booking.status == BookingStatus.completed,
                          ),
                          _StepCircle(
                            label: 'Confirmed',
                            isDone: booking.status == BookingStatus.confirmed ||
                                booking.status == BookingStatus.completed ||
                                booking.status == BookingStatus.completed,
                            isCurrent: booking.status == BookingStatus.confirmed,
                          ),
                          _StepLine(
                            isDone: booking.status == BookingStatus.completed ||
                                booking.status == BookingStatus.completed,
                          ),
                          _StepCircle(
                            label: 'In Bay',
                            isDone: booking.status == BookingStatus.completed,
                            isCurrent: booking.status == BookingStatus.completed,
                          ),
                          _StepLine(
                            isDone: booking.status == BookingStatus.completed,
                          ),
                          _StepCircle(
                            label: 'Done',
                            isDone: booking.status == BookingStatus.completed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),

                    // ── WORKSHOP INFO ────────────────────────────────────────
                    _SectionHeader(
                      title: 'Workshop Location',
                      subtitle: 'Orient Automotive • Main Bay',
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    AppCard(
                      borderRadius: 24,
                      padding: EdgeInsets.zero,
                      color: AppColors.surface,
                      borderColor: AppColors.border,
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'Address',
                            value: 'Orient Automotive, Workshop Bay 1',
                          ),
                          const Divider(height: 1, color: AppColors.line),
                          _InfoRow(
                            icon: Icons.access_time_filled_rounded,
                            label: 'Opening Hours',
                            value: 'Mon–Fri 8:00am – 6:00pm',
                          ),
                          const Divider(height: 1, color: AppColors.line),
                          _InfoRow(
                            icon: Icons.phone_rounded,
                            label: 'Workshop Line',
                            value: '+44 (0) 20 1234 5678',
                          ),
                        ],
                      ),
                    ),

                    // ── CANCEL BUTTON ────────────────────────────────────────
                    if (cancellable) ...[
                      const SizedBox(height: AppDimensions.s28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmCancel(context, ref),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Cancel This Appointment'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.dangerBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.rPill),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.s32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel Booking?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'This appointment will be cancelled and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Cancel Booking',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(customerRemoteDataSourceProvider)
          .cancelBooking(int.tryParse(booking.id) ?? 0);
      ref.invalidate(customerBookingsProvider);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.danger;
      case BookingStatus.pending:
        return AppColors.warning;
    }
  }

  Color _statusBg(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return AppColors.primaryBg;
      case BookingStatus.completed:
        return AppColors.successBg;
      case BookingStatus.cancelled:
        return AppColors.dangerBg;
      case BookingStatus.pending:
        return AppColors.warningBg;
    }
  }
}

// ─── Shared Helpers ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s14,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.text3,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
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
            fontWeight:
                isCurrent || isDone ? FontWeight.w900 : FontWeight.w500,
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
