import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// The booking as a workshop pass plus its honest record rows.
///
/// The pass carries the public reference (mono, LTR), the plate and the
/// appointment — what the customer shows at arrival. Below it, the service,
/// vehicle and schedule rows plus the one next-step note the status
/// genuinely supports. No duration, no QR bitmap, no promises: the booking
/// record carries no duration field and the app ships no QR renderer.
class CustomerBookingDetailSummary extends StatelessWidget {
  final CustomerBookingEntity booking;

  const CustomerBookingDetailSummary({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final group = CustomerBookingsPresentation.groupOf(booking.status);
    final tone = CustomerServiceTracking.bookingTone(colors, booking.status);
    final reference = CustomerBookingsPresentation.referenceOf(booking);
    final service = booking.service.trim();
    final plate = booking.plateNumber.trim();
    final vehicle = booking.vehicleName.trim();
    final date = CustomerBookingsPresentation.longDateLabel(booking.date);
    final time = booking.time.trim();
    final hasAppointment = date.isNotEmpty || time.isNotEmpty;
    final appointmentLabel = group == CustomerBookingGroup.history
        ? t.bkdDateLabel
        : t.bkdApptLabel;
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isLive = group == CustomerBookingGroup.inService;
    final isUpcoming = group == CustomerBookingGroup.upcoming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomerSurfacePanel(
          accent: tone,
          emphasised: isLive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    color: tone,
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  Expanded(
                    child: Text(
                      t.bkdPassTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: booking.statusLabel.toUpperCase(),
                    showDot: true,
                    bg: tone.withValues(alpha: 0.12),
                    fg: tone,
                  ),
                ],
              ),
              if (reference.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s12),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(color: colors.onSurface)
                        .copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: AppDimensions.s18,
                        ),
                  ),
                ),
              ],
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimensions.s8),
              Text(
                t.bkdPassHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        CustomerSurfacePanel(
          accent: colors.onSurfaceVariant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Row(
                label: t.bkdServiceLabel,
                child: Text(
                  service.isEmpty ? t.bkdServiceLabel : service,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isCancelled
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                  ),
                ),
              ),
              if (reference.isNotEmpty) ...[
                const Divider(height: AppDimensions.s24),
                _Row(
                  label: t.bkdRefLabel,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mono(
                        color: colors.onSurface,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              if (hasAppointment) ...[
                const Divider(height: AppDimensions.s24),
                _Row(
                  label: appointmentLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          date.isEmpty ? appointmentLabel : date,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.s4),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            CustomerBookingsPresentation.timeLabel(time),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (isUpcoming) ...[
                const Divider(height: AppDimensions.s24),
                Text(
                  booking.status == BookingStatus.confirmed
                      ? t.bkdConfirmedNote
                      : t.bkdRequestedNote,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Widget child;

  const _Row({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        child,
      ],
    );
  }
}
