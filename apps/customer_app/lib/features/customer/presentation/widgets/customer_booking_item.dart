import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// One scannable booking row.
///
/// The row is built around a compact date block so appointments can be scanned
/// by date, then carries only the summary needed to decide whether to open the
/// booking: canonical status, service, vehicle, reference and Ã¢â‚¬â€ when the
/// booking genuinely has one Ã¢â‚¬â€ its live or action-required state. Live tracking
/// itself stays in Status and the full record stays in Booking Details.
class CustomerBookingItem extends StatelessWidget {
  final CustomerBookingEntity booking;

  /// The canonical live job when this booking owns it.
  final CustomerServiceEntity? liveService;
  final String Function(double amount) formatAmount;
  final VoidCallback onOpen;
  final VoidCallback onTrackService;
  final void Function(String estimateId) onReviewApproval;

  const CustomerBookingItem({
    super.key,
    required this.booking,
    required this.formatAmount,
    required this.onOpen,
    required this.onTrackService,
    required this.onReviewApproval,
    this.liveService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final group = CustomerBookingsPresentation.groupOf(booking.status);
    final tone = CustomerServiceTracking.bookingTone(colors, booking.status);
    final isInService = group == CustomerBookingGroup.inService;
    final isCancelled = booking.status == BookingStatus.cancelled;
    final needsApproval = booking.status == BookingStatus.approvalRequired;

    final service = booking.service.trim();
    final title = service.isEmpty ? 'Service appointment' : service;
    final plate = booking.plateNumber.trim();
    final vehicle = booking.vehicleName.trim();
    final reference = CustomerBookingsPresentation.referenceOf(booking);
    final schedule = CustomerBookingsPresentation.scheduleLabel(
      booking.date,
      booking.time,
    );
    final day = CustomerBookingsPresentation.dayOfMonthLabel(booking.date);
    final month = CustomerBookingsPresentation.monthLabel(booking.date);
    final hasDateBlock = day.isNotEmpty && month.isNotEmpty;
    // A time the parser cannot read is shown as the backend sent it on the
    // metadata line instead of being squeezed into the date block.
    final readableTime = CustomerBookingsPresentation.isReadableTime(
      booking.time,
    );
    final time = readableTime
        ? CustomerBookingsPresentation.timeLabel(booking.time)
        : '';
    // The raw schedule covers both an unreadable date and a readable date with
    // an unreadable time, so no real value is ever dropped.
    final showRawSchedule =
        (!hasDateBlock || !readableTime) && schedule.isNotEmpty;
    // Tracking is only offered for the booking that canonically owns the live
    // workshop job, so the row can never lead to another vehicle's service.
    final trackable = isInService && liveService != null;
    final stage = trackable
        ? CustomerServiceTracking.humanize(liveService?.currentStage ?? '')
        : '';

    final semantics = [
      title,
      booking.statusLabel,
      if (vehicle.isNotEmpty || plate.isNotEmpty) '$vehicle $plate'.trim(),
      if (hasDateBlock) '${booking.date.trim()} ${booking.time.trim()}'.trim(),
      if (!hasDateBlock && schedule.isNotEmpty) schedule,
      if (stage.isNotEmpty) 'Current stage $stage',
      if (needsApproval) 'Action required',
      if (reference.isNotEmpty) 'Booking reference $reference',
    ].join(', ');

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: semantics,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDateBlock)
                _DateBlock(day: day, month: month, time: time)
              else
                _IconTile(icon: _iconFor(booking.status), tone: tone),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The service name and the status share the top line while
                    // they fit; a long name pushes the status onto its own line
                    // instead of breaking mid-word.
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: AppDimensions.s6,
                      spacing: AppDimensions.s8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          // Long service names wrap instead of being cut off,
                          // because the title is the row's anchor.
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: isCancelled
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                            fontWeight: FontWeight.w700,
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
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (stage.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s6),
                      _StateLine(
                        icon: Icons.build_circle_rounded,
                        text: 'Current stage \u00b7 $stage',
                        color: colors.primary,
                      ),
                    ],
                    if (needsApproval) ...[
                      const SizedBox(height: AppDimensions.s6),
                      _StateLine(
                        icon: Icons.error_outline_rounded,
                        text: _approvalMessage(),
                        color: colors.error,
                      ),
                    ],
                    if (showRawSchedule) ...[
                      const SizedBox(height: AppDimensions.s6),
                      _StateLine(
                        icon: Icons.event_rounded,
                        text: schedule,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                    if (reference.isNotEmpty ||
                        (!needsApproval && !trackable)) ...[
                      const SizedBox(height: AppDimensions.s6),
                      Row(
                        children: [
                          if (reference.isNotEmpty)
                            Flexible(
                              child: Text(
                                reference,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontFamily: AppFontFamilies.mono,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          // const Spacer(),
                          // if (!needsApproval && !trackable)
                          //   Icon(
                          //     Icons.chevron_right_rounded,
                          //     size: AppDimensions.iconMd,
                          //     color: colors.onSurfaceVariant,
                          //   ),
                        ],
                      ),
                    ],
                    // A contextual action only ever appears when the booking
                    // really has one, and it keeps its own line so the record's
                    // reference is never squeezed.
                    if (needsApproval || trackable) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: needsApproval
                            ? _RowAction(
                                label: 'Review',
                                onPressed: () =>
                                    onReviewApproval(booking.estimateId),
                              )
                            : _RowAction(
                                label: 'Track service',
                                onPressed: onTrackService,
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _approvalMessage() {
    final amount = booking.estimateAmount;
    if (amount <= 0) return 'Approval needed before work continues';
    // The row carries the compact indicator; the fuller wording lives in
    // Booking Details.
    return 'Estimate ${formatAmount(amount)} awaiting approval';
  }

  IconData _iconFor(BookingStatus status) {
    return switch (status) {
      BookingStatus.cancelled => Icons.cancel_rounded,
      BookingStatus.completed ||
      BookingStatus.delivered => Icons.receipt_long_rounded,
      BookingStatus.pending ||
      BookingStatus.confirmed => Icons.calendar_month_rounded,
      _ => Icons.build_circle_rounded,
    };
  }
}

/// Compact date anchor: day, month and time in one block, so a long list can be
/// scanned by date without reading each row's metadata.
class _DateBlock extends StatelessWidget {
  final String day;
  final String month;
  final String time;

  const _DateBlock({
    required this.day,
    required this.month,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                Text(
                  month,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (time.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final Color tone;

  const _IconTile({required this.icon, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 52,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      ),
      child: Icon(icon, size: AppDimensions.iconMd, color: tone),
    );
  }
}

class _StateLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StateLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: color),
        const SizedBox(width: AppDimensions.s6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact contextual action that keeps a 48px touch target without adding a
/// second row of vertical space.
class _RowAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _RowAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.touchTarget,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: AppDimensions.s4),
            const Icon(Icons.arrow_forward_rounded, size: 14),
          ],
        ),
      ),
    );
  }
}
