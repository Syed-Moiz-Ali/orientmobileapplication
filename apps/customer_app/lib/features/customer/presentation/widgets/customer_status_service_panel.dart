import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Active workshop job — the primary tracking surface.
///
/// Shows only real fields: the canonical "in service" state, the current
/// workshop stage (humanised), real progress when the backend provides it, and
/// a real expected completion when one exists.
class CustomerStatusLivePanel extends StatelessWidget {
  final CustomerServiceEntity service;
  final VoidCallback? onViewBooking;

  const CustomerStatusLivePanel({
    super.key,
    required this.service,
    this.onViewBooking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final progress = service.progressPercent.clamp(0, 100);
    final stage = CustomerServiceTracking.humanize(service.currentStage);
    final vehicle = CustomerServiceTracking.vehicleLine(
      service.vehicleName,
      service.plateNumber,
    );
    final eta = service.estCompletion.trim();

    return CustomerSurfacePanel(
      accent: colors.primary,
      emphasised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: StatusPill(
              label: 'IN SERVICE',
              showDot: true,
              bg: colors.primary.withValues(alpha: 0.14),
              fg: colors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            service.service.trim().isEmpty
                ? 'Service in progress'
                : service.service.trim(),
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (vehicle.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              vehicle,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          Text(
            'Current stage',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            stage.isEmpty ? 'Service in progress' : stage,
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (progress > 0) ...[
            const SizedBox(height: AppDimensions.s16),
            Semantics(
              excludeSemantics: true,
              label: 'Service progress, $progress percent',
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 6,
                        backgroundColor: colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Text(
                    '$progress%',
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (eta.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: AppDimensions.iconSm,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Text(
                    'Estimated completion \u00b7 $eta',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (onViewBooking != null) ...[
            const SizedBox(height: AppDimensions.s18),
            FilledButton(
              onPressed: onViewBooking,
              child: const Text('View booking'),
            ),
          ],
        ],
      ),
    );
  }
}

/// A real booking that has not reached the workshop yet.
///
/// Clearly states that the service is booked rather than in progress, and
/// never fabricates progress.
class CustomerStatusUpcomingPanel extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onViewBooking;

  const CustomerStatusUpcomingPanel({
    super.key,
    required this.booking,
    required this.onViewBooking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final tone = CustomerServiceTracking.bookingTone(colors, booking.status);
    final vehicle = CustomerServiceTracking.vehicleLine(
      booking.vehicleName,
      booking.plateNumber,
    );
    final appointment = [
      if (booking.date.trim().isNotEmpty) booking.date.trim(),
      if (booking.time.trim().isNotEmpty) booking.time.trim(),
    ].join(' \u00b7 ');

    return CustomerSurfacePanel(
      accent: tone,
      emphasised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusPill(
                label: booking.statusLabel.toUpperCase(),
                showDot: true,
                bg: tone.withValues(alpha: 0.14),
                fg: tone,
              ),
              const Spacer(),
              if (booking.jobCardRef.trim().isNotEmpty)
                Flexible(
                  child: Text(
                    booking.jobCardRef.trim(),
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
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            booking.service.trim().isEmpty
                ? 'Workshop booking'
                : booking.service.trim(),
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (vehicle.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              vehicle,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  appointment.isEmpty ? 'Appointment scheduled' : appointment,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(
            'Your service is booked. Workshop updates will appear here once '
            'your vehicle is checked in.',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppDimensions.s18),
          FilledButton(
            onPressed: onViewBooking,
            child: const Text('View booking'),
          ),
        ],
      ),
    );
  }
}

/// Nothing booked and nothing in the workshop.
class CustomerStatusIdlePanel extends StatelessWidget {
  final bool hasVehicles;
  final bool showBookingsLink;
  final VoidCallback onBookService;
  final VoidCallback onViewBookings;
  final VoidCallback onAddVehicle;

  const CustomerStatusIdlePanel({
    super.key,
    required this.hasVehicles,
    required this.showBookingsLink,
    required this.onBookService,
    required this.onViewBookings,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CustomerSurfacePanel(
      accent: colors.onSurfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(
                  Icons.garage_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nothing to track right now',
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      hasVehicles
                          ? 'Your vehicle is not currently booked or in the '
                                'workshop.'
                          : 'Add your vehicle to book service and follow its '
                                'progress here.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s18),
          if (hasVehicles) ...[
            FilledButton.icon(
              onPressed: onBookService,
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('Book service'),
            ),
            if (showBookingsLink)
              TextButton(
                onPressed: onViewBookings,
                child: const Text('View bookings'),
              ),
          ] else
            FilledButton.icon(
              onPressed: onAddVehicle,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add your vehicle'),
            ),
        ],
      ),
    );
  }
}
