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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final cancellable = booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed;

    final statusColor = _statusColor(booking.status, colorScheme);
    final statusBg = _statusBg(booking.status, colorScheme);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Appointment Details'),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── 1. STATUS HEADER CARD ──────────────────────────────
                    AppCard(
                      borderRadius: 24,
                      elevation: 0,
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
                              StatusPill(label: booking.statusLabel.toUpperCase(), bg: statusBg, fg: statusColor),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                ),
                                child: Text(
                                  '#${booking.id.length > 8 ? booking.id.substring(booking.id.length - 8) : booking.id}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            booking.service.isNotEmpty ? booking.service : 'Scheduled Service',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFACC15), // Yellow plate
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  booking.plateNumber.toUpperCase(),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 1.2,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── 2. APPOINTMENT DETAILS CARD ────────────────────────
                    _SectionHeader(title: 'Appointment Specifications', subtitle: 'Date, time & service details'),
                    const SizedBox(height: 16),
                    AppCard(
                      borderRadius: 24,
                      elevation: 0,
                      padding: EdgeInsets.zero,
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
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: booking.date.isNotEmpty ? booking.date : 'TBC',
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Time Slot',
                            value: booking.time.isNotEmpty ? booking.time : 'TBC',
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          _InfoRow(
                            icon: Icons.directions_car_rounded,
                            label: 'Vehicle',
                            value: booking.vehicleName.isNotEmpty ? booking.vehicleName : '—',
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          _InfoRow(
                            icon: Icons.pin_rounded,
                            label: 'Registration',
                            value: booking.plateNumber.toUpperCase(),
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          _InfoRow(
                            icon: Icons.build_rounded,
                            label: 'Service Package',
                            value: booking.service.isNotEmpty ? booking.service : '—',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── 3. PROGRESS TRACKER ────────────────────────────────
                    _SectionHeader(title: 'Service Progress', subtitle: 'Live stage tracker updated by workshop'),
                    const SizedBox(height: 16),
                    AppCard(
                      borderRadius: 24,
                      elevation: 0,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StepCircle(label: 'Booked', isDone: true, colorScheme: colorScheme),
                          _StepLine(
                            isDone:
                                booking.status == BookingStatus.confirmed || booking.status == BookingStatus.completed,
                            colorScheme: colorScheme,
                          ),
                          _StepCircle(
                            label: 'Confirmed',
                            isDone:
                                booking.status == BookingStatus.confirmed || booking.status == BookingStatus.completed,
                            isCurrent: booking.status == BookingStatus.confirmed,
                            colorScheme: colorScheme,
                          ),
                          _StepLine(isDone: booking.status == BookingStatus.completed, colorScheme: colorScheme),
                          _StepCircle(
                            label: 'In Bay',
                            isDone: booking.status == BookingStatus.completed,
                            isCurrent: booking.status == BookingStatus.completed,
                            colorScheme: colorScheme,
                          ),
                          _StepLine(isDone: booking.status == BookingStatus.completed, colorScheme: colorScheme),
                          _StepCircle(
                            label: 'Done',
                            isDone: booking.status == BookingStatus.completed,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── 4. WORKSHOP INFO ───────────────────────────────────
                    _SectionHeader(title: 'Workshop Location', subtitle: 'Orient Automotive • Main Bay'),
                    const SizedBox(height: 16),
                    AppCard(
                      borderRadius: 24,
                      elevation: 0,
                      padding: EdgeInsets.zero,
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
                        children: [
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'Address',
                            value: 'Orient Automotive, Workshop Bay 1',
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          _InfoRow(
                            icon: Icons.access_time_filled_rounded,
                            label: 'Opening Hours',
                            value: 'Mon–Fri 8:00am – 6:00pm',
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          _InfoRow(icon: Icons.phone_rounded, label: 'Workshop Line', value: '+44 (0) 20 1234 5678'),
                        ],
                      ),
                    ),

                    // ── CANCEL BUTTON ──────────────────────────────────────
                    if (cancellable) ...[
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmCancel(context, ref, colorScheme),
                          icon: Icon(Icons.cancel_outlined, size: 20, color: colorScheme.error),
                          label: Text(
                            'Cancel This Appointment',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, ColorScheme colorScheme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Cancel Booking?',
          style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.onSurface),
        ),
        content: Text(
          'This appointment will be cancelled and cannot be undone.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Booking', style: TextStyle(color: colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final cancelled = await ref
          .read(customerRemoteDataSourceProvider)
          .cancelBooking(int.tryParse(booking.id) ?? 0);
      if (!cancelled) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel this booking.')),
        );
        return;
      }
      ref.invalidate(customerBookingsProvider);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Color _statusColor(BookingStatus s, ColorScheme colorScheme) {
    switch (s) {
      case BookingStatus.confirmed:
        return colorScheme.primary;
      case BookingStatus.completed:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
        return colorScheme.error;
      case BookingStatus.pending:
        return colorScheme.secondary;
    }
  }

  Color _statusBg(BookingStatus s, ColorScheme colorScheme) {
    switch (s) {
      case BookingStatus.confirmed:
        return colorScheme.primary.withValues(alpha: 0.15);
      case BookingStatus.completed:
        return const Color(0xFF10B981).withValues(alpha: 0.15);
      case BookingStatus.cancelled:
        return colorScheme.error.withValues(alpha: 0.15);
      case BookingStatus.pending:
        return colorScheme.secondary.withValues(alpha: 0.15);
    }
  }
}

// ─── SHARED HELPERS ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.onSurface, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w800),
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
  final ColorScheme colorScheme;

  const _StepCircle({required this.label, this.isDone = false, this.isCurrent = false, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    const successGreen = Color(0xFF10B981);
    final activeColor = isDone ? successGreen : colorScheme.primary;
    final inactiveColor = colorScheme.outline;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone || isCurrent ? activeColor.withValues(alpha: 0.15) : colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(color: isDone || isCurrent ? activeColor : inactiveColor, width: isCurrent ? 2 : 1),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, size: 16, color: successGreen)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCurrent ? activeColor : Colors.transparent,
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
            color: isCurrent || isDone ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;
  final ColorScheme colorScheme;

  const _StepLine({required this.isDone, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    const successGreen = Color(0xFF10B981);
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isDone ? successGreen : colorScheme.outlineVariant,
      ),
    );
  }
}
