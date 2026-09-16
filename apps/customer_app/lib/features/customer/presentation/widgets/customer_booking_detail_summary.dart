import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// The primary record surface for one booking.
///
/// Status anchors the surface, then service and vehicle identity, then the
/// appointment in fuller detail than a Bookings row can afford. Live work and
/// approvals live in their own surface so this one stays a clean record.
class CustomerBookingDetailSummary extends StatelessWidget {
  final CustomerBookingEntity booking;

  const CustomerBookingDetailSummary({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final group = CustomerBookingsPresentation.groupOf(booking.status);
    final tone = CustomerServiceTracking.bookingTone(colors, booking.status);
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isUpcoming = group == CustomerBookingGroup.upcoming;
    final isLive = group == CustomerBookingGroup.inService;

    final service = booking.service.trim();
    final plate = booking.plateNumber.trim();
    final vehicle = booking.vehicleName.trim();
    final reference = CustomerBookingsPresentation.referenceOf(booking);
    final date = CustomerBookingsPresentation.longDateLabel(booking.date);
    final time = CustomerBookingsPresentation.timeLabel(booking.time);
    final hasAppointment = date.isNotEmpty || time.isNotEmpty;
    // Finished work reads as a service date; live and upcoming work reads as
    // the appointment the customer is holding.
    final appointmentLabel = group == CustomerBookingGroup.history
        ? 'Service date'
        : 'Appointment';

    return CustomerSurfacePanel(
      accent: tone,
      emphasised: isLive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusPill(
                label: booking.statusLabel.toUpperCase(),
                showDot: true,
                bg: tone.withValues(alpha: 0.12),
                fg: tone,
              ),
              const Spacer(),
              if (reference.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.s8),
                Flexible(
                  child: Text(
                    reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontFamily: AppFontFamilies.mono,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            service.isEmpty ? 'Service appointment' : service,
            style: textTheme.titleLarge?.copyWith(
              color: isCancelled ? colors.onSurfaceVariant : colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (plate.isNotEmpty || vehicle.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                if (plate.isNotEmpty) CustomerPlateChip(plate: plate),
                if (plate.isNotEmpty && vehicle.isNotEmpty)
                  const SizedBox(width: AppDimensions.s8),
                if (vehicle.isNotEmpty)
                  Expanded(
                    child: Text(
                      vehicle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (hasAppointment) ...[
            const SizedBox(height: AppDimensions.s16),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppDimensions.s14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointmentLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        date.isEmpty ? 'Scheduled' : date,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isCancelled
                              ? colors.onSurfaceVariant
                              : colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.r2),
                        Text(
                          time,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (isUpcoming) ...[
            const SizedBox(height: AppDimensions.s14),
            // A requested booking is not a confirmed one: say which it is.
            Text(
              booking.status == BookingStatus.confirmed
                  ? 'Your service is booked. Workshop updates will appear here '
                        'once your vehicle is checked in.'
                  : 'The workshop has your request and will confirm the '
                        'appointment. Updates appear here once it is confirmed.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
