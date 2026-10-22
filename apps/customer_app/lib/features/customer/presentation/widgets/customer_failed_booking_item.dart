import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// One local booking the workshop never received, presented as a booking record
/// with its own recovery actions — not an error dashboard.
///
/// The terminal state is read from the failed operation itself; the row shows
/// only the vehicle, service and appointment the customer really chose, and
/// never a booking reference or a workshop status it does not have.
///
/// Presentation only — the failed-operation derivation, retry/remove handlers
/// and busy guard are unchanged; the row is rebuilt on shared atoms
/// (AppSurfaceCard, AppStatusChip, ARB copy).
class CustomerFailedBookingItem extends StatelessWidget {
  final FailedBooking booking;

  /// True while this booking's recovery action is running, so a second tap
  /// cannot replay the same failed operation twice.
  final bool busy;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const CustomerFailedBookingItem({
    super.key,
    required this.booking,
    required this.busy,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final service = booking.service.trim();
    final title = service.isEmpty ? t.bkServiceAppt : service;
    final plate = booking.plateNumber.trim();
    final vehicle = booking.vehicleName.trim();
    final schedule = CustomerBookingsPresentation.scheduleLabel(
      booking.date,
      booking.time,
    );

    return Semantics(
      liveRegion: true,
      container: true,
      label:
          "${t.bkfNotSent}. $title. "
          "${t.bkfSendBody}",
      child: AppSurfaceCard(
        outlined: false,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                // The icon carries the failure signal alongside the status text, so
                // the state is never conveyed by colour alone.
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.error,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: AppDimensions.s6,
                      spacing: AppDimensions.s8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppStatusChip(
                          // Sentence case via theme (C17), never ALL CAPS.
                          label: t.bkfNotSent,
                          kind: AppStatusKind.error,
                        ),
                      ],
                    ),
                    if (plate.isNotEmpty || vehicle.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s6),
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
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (schedule.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s6),
                      Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: AppDimensions.iconSm,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppDimensions.s6),
                          Expanded(
                            child: Text(
                              schedule,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppDimensions.s8),
                    Text(
                      t.bkfSendBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.r2),
                    Text(
                      t.bkfWaitingBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s8),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: AppDimensions.s8,
                      runSpacing: AppDimensions.s6,
                      children: [
                        SizedBox(
                          height: AppDimensions.touchTarget,
                          child: TextButton(
                            onPressed: busy ? null : onRemove,
                            style: TextButton.styleFrom(
                              foregroundColor: colors.onSurfaceVariant,
                            ),
                            child: Text(t.vhRemove),
                          ),
                        ),
                        SizedBox(
                          height: AppDimensions.touchTarget,
                          child: FilledButton(
                            onPressed: busy ? null : onRetry,
                            child: Text(busy ? t.bkfRetrying : t.bkRetry),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
