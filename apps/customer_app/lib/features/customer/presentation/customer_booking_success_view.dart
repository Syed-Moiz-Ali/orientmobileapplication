import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// The end of the booking flow: what was requested, and what to do next.
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          maxContentWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.s20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.tertiary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colors.tertiary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            queuedOffline
                                ? 'Booking saved'
                                : 'Booking requested',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.r2),
                        Text(
                          queuedOffline
                              ? 'It will reach the workshop when you are back online.'
                              : 'The workshop will confirm your appointment.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s20),

              // ── The booking record ────────────────────────────────────────
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
                        label: 'Booking reference',
                        value: bookingRef,
                        mono: true,
                        emphasize: true,
                      ),
                      Divider(height: 1, color: colors.outlineVariant),
                    ],
                    // A booking that only exists on this device has not reached
                    // the workshop, so it must not display a server status.
                    _RecordRow(
                      label: 'Status',
                      value: '',
                      pillTone: queuedOffline
                          ? colors.onSurfaceVariant
                          : pendingTone,
                      pillLabel: queuedOffline
                          ? 'Not sent yet'
                          : AppStatusLabels.booking('pending'),
                    ),
                    Divider(height: 1, color: colors.outlineVariant),
                    _RecordRow(
                      label: 'Service',
                      value: service.trim().isEmpty ? 'Service' : service,
                    ),
                    Divider(height: 1, color: colors.outlineVariant),
                    _VehicleRow(vehicle: vehicle, plate: plate),
                    if (schedule.isNotEmpty) ...[
                      Divider(height: 1, color: colors.outlineVariant),
                      _RecordRow(label: 'Appointment', value: schedule),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              // ── Honest state note ─────────────────────────────────────────
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
                      child: Text(
                        queuedOffline
                            ? 'This booking is stored on this device. It will be '
                                  'sent to the workshop automatically when the '
                                  'connection is back.'
                            : 'Your appointment is not confirmed yet. You will '
                                  'find it in your bookings, and the workshop '
                                  'will confirm the slot.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s24),

              if (created != null)
                FilledButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.customerBookingDetail,
                    extra: created,
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('View booking'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppDimensions.touchTarget,
                    ),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.bookingsLocation),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('View bookings'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppDimensions.touchTarget,
                    ),
                  ),
                ),
              const SizedBox(height: AppDimensions.s8),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.customerDashboard),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
                ),
                child: const Text('Back to Home'),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s14,
        vertical: AppDimensions.s14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: emphasize ? colors.primary : colors.onSurface,
                      fontFamily: mono ? AppFontFamilies.mono : null,
                      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                ),
                if (pillTone != null && pillLabel != null)
                  StatusPill(
                    label: pillLabel!.toUpperCase(),
                    showDot: true,
                    bg: pillTone!.withValues(alpha: 0.12),
                    fg: pillTone!,
                  ),
              ],
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
    final name = vehicle.trim();

    if (name.isEmpty && plate.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s14,
        vertical: AppDimensions.s14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              'Vehicle',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (plate.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s6),
                  CustomerPlateChip(plate: plate.trim()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
