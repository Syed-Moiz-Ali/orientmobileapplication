import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// The end of the booking flow: reservation warmth, the real reference and
/// the next steps — then one Done that returns to the garage.
///
/// It shows only what the workshop actually returned — the booking reference
/// and creation result — plus the selections the customer just made. When the
/// booking was queued on the device because there was no connection, it says so
/// instead of inventing a reference.
class CustomerBookingSuccessView extends ConsumerWidget {
  final String bookingRef;
  final String bookingId;
  final String service;
  final String date;
  final String time;
  final String vehicle;
  final String plate;
  final bool queuedOffline;

  const CustomerBookingSuccessView({
    super.key,
    this.bookingRef = '',
    this.bookingId = '',
    required this.service,
    required this.date,
    required this.time,
    this.vehicle = '',
    this.plate = '',
    this.queuedOffline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;

    // The new booking is only offered as a detail link once the refreshed feed
    // really contains it, so Booking Details is never opened with invented data.
    final created = _createdBooking(
      ref.watch(customerBookingsProvider).valueOrNull ??
          const <CustomerBookingEntity>[],
    );

    final schedule = CustomerBookingsPresentation.scheduleLabel(date, time);
    final pendingTone = CustomerServiceTracking.bookingTone(
      colors,
      BookingStatus.pending,
    );
    final accent = queuedOffline ? colors.error : colors.tertiary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          maxContentWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.s32),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  queuedOffline
                      ? Icons.cloud_off_rounded
                      : Icons.check_rounded,
                  color: accent,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              Semantics(
                header: true,
                child: Text(
                  queuedOffline ? t.bksSaved : t.bksRequested,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                queuedOffline ? t.bksSavedSub : t.bksRequestedSub,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s20),

              // ── The booking record ────────────────────────────────────
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (bookingRef.isNotEmpty) ...[
                      _RecordRow(
                        label: t.bksRefLabel,
                        value: bookingRef,
                        mono: true,
                        emphasize: true,
                      ),
                      Divider(height: 1, color: colors.outlineVariant),
                    ],
                    // A booking that only exists on this device has not reached
                    // the workshop, so it must not display a server status.
                    _RecordRow(
                      label: t.bksStatusLabel,
                      value: '',
                      pillTone: queuedOffline
                          ? colors.onSurfaceVariant
                          : pendingTone,
                      pillLabel: queuedOffline
                          ? t.bksNotSent
                          : AppStatusLabels.booking('pending'),
                    ),
                    Divider(height: 1, color: colors.outlineVariant),
                    _RecordRow(
                      label: t.bksServiceLabel,
                      value: service.trim().isEmpty
                          ? t.bksServiceLabel
                          : service,
                    ),
                    Divider(height: 1, color: colors.outlineVariant),
                    _VehicleRow(vehicle: vehicle, plate: plate),
                    if (schedule.isNotEmpty) ...[
                      Divider(height: 1, color: colors.outlineVariant),
                      _RecordRow(label: t.bksApptLabel, value: schedule),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              // ── Honest state note ─────────────────────────────────────
              CustomerSurfacePanel(
                accent: queuedOffline ? colors.error : colors.primary,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      queuedOffline
                          ? Icons.cloud_off_rounded
                          : Icons.info_outline_rounded,
                      size: AppDimensions.iconMd,
                      color: queuedOffline ? colors.error : colors.primary,
                    ),
                    const SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            queuedOffline
                                ? t.bksQueuedTitle
                                : t.bksPendingTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s4),
                          Text(
                            queuedOffline ? t.bksQueuedBody : t.bksPendingBody,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              // ── What happens next ─────────────────────────────────────
              SectionHeader(title: t.bksNextTitle),
              const SizedBox(height: AppDimensions.s8),
              _NextStep(index: '1', text: t.bksNextOne),
              _NextStep(index: '2', text: t.bksNextTwo),
              _NextStep(index: '3', text: t.bksNextThree),
              const SizedBox(height: AppDimensions.s24),

              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.customerDashboard),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(t.bksDone),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: AppDimensions.s8),
              if (created != null)
                TextButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.customerBookingDetail,
                    extra: created,
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text(t.bksViewBooking),
                )
              else
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.bookingsLocation),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text(t.bksViewBookings),
                ),
              const SizedBox(height: AppDimensions.s32),
            ],
          ),
        ),
      ),
    );
  }

  /// The booking this flow just created, resolved from the refreshed feed.
  CustomerBookingEntity? _createdBooking(List<CustomerBookingEntity> bookings) {
    if (bookingId.isEmpty && bookingRef.isEmpty) return null;
    for (final booking in bookings) {
      if (bookingRef.isNotEmpty && booking.bookingRef.trim() == bookingRef) {
        return booking;
      }
      if (bookingId.isNotEmpty && booking.id.trim() == bookingId) {
        return booking;
      }
    }
    return null;
  }
}

class _NextStep extends StatelessWidget {
  final String index;
  final String text;

  const _NextStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              index,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.s4),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool emphasize;
  final Color? pillTone;
  final String? pillLabel;

  const _RecordRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.emphasize = false,
    this.pillTone,
    this.pillLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          if (pillLabel != null && pillTone != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusPill(
                label: pillLabel!.toUpperCase(),
                showDot: true,
                bg: pillTone!.withValues(alpha: 0.12),
                fg: pillTone!,
              ),
            )
          else
            Text(
              value,
              style: (mono
                      ? AppTextStyles.mono(color: colors.onSurface)
                      : theme.textTheme.bodyLarge!)
                  .copyWith(
                    fontWeight: emphasize
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final String vehicle;
  final String plate;

  const _VehicleRow({required this.vehicle, required this.plate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final name = vehicle.trim();
    if (name.isEmpty && plate.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.bksVehicleLabel.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          if (name.isNotEmpty)
            Text(
              name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (plate.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s8),
            CustomerPlateChip(plate: plate.trim()),
          ],
        ],
      ),
    );
  }
}
