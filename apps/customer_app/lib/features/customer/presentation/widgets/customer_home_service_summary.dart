import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// The single most important thing on Customer Home: what is happening to the
/// customer's vehicle right now.
///
/// Every value rendered here comes from real state (`/customers/services/active`
/// for the live job, the bookings feed for a not-yet-started booking). Nothing
/// is estimated, and the panel degrades to a compact, useful state when there
/// is no active work.
///
/// The panel only ever offers a state-specific action (track / view booking /
/// add vehicle). Booking itself lives once in the persistent quick-action row,
/// so Home never presents two competing Book service entry points.
class CustomerHomeServiceSummary extends StatelessWidget {
  final CustomerServiceEntity? activeService;
  final CustomerBookingEntity? activeBooking;
  final int vehicleCount;
  final VoidCallback onTrackService;
  final VoidCallback onViewBooking;
  final VoidCallback onAddVehicle;

  const CustomerHomeServiceSummary({
    super.key,
    required this.activeService,
    required this.activeBooking,
    required this.vehicleCount,
    required this.onTrackService,
    required this.onViewBooking,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final service = activeService;
    if (service != null && service.hasActiveJob) {
      return _LiveServicePanel(svc: service, onTrackService: onTrackService);
    }

    final booking = activeBooking;
    if (booking != null) {
      return _ActiveBookingPanel(
        booking: booking,
        onViewBooking: onViewBooking,
      );
    }

    if (vehicleCount == 0) {
      return _WelcomePanel(onAddVehicle: onAddVehicle);
    }

    return _IdlePanel(vehicleCount: vehicleCount);
  }
}

class _LiveServicePanel extends StatelessWidget {
  final CustomerServiceEntity svc;
  final VoidCallback onTrackService;

  const _LiveServicePanel({required this.svc, required this.onTrackService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final progress = svc.progressPercent.clamp(0, 100);
    final vehicleLine = CustomerServiceTracking.vehicleLine(
      svc.vehicleName,
      svc.plateNumber,
    );

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
            svc.service.trim().isEmpty
                ? 'Service in progress'
                : svc.service.trim(),
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (vehicleLine.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              vehicleLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (svc.currentStage.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s14),
            Row(
              children: [
                Icon(
                  Icons.build_circle_rounded,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Text(
                    'Current stage \u00b7 ${svc.currentStage.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (progress > 0) ...[
            const SizedBox(height: AppDimensions.s14),
            Row(
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
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
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
          ],
          if (svc.estCompletion.trim().isNotEmpty) ...[
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
                    'Estimated completion \u00b7 ${svc.estCompletion.trim()}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.s18),
          FilledButton.icon(
            onPressed: onTrackService,
            icon: const Icon(Icons.track_changes_rounded, size: 18),
            label: const Text('Track service'),
          ),
        ],
      ),
    );
  }
}

class _ActiveBookingPanel extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onViewBooking;

  const _ActiveBookingPanel({
    required this.booking,
    required this.onViewBooking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final needsApproval = booking.status == BookingStatus.approvalRequired;
    final accent = needsApproval ? colors.error : colors.primary;
    final vehicleLine = CustomerServiceTracking.vehicleLine(
      booking.vehicleName,
      booking.plateNumber,
    );
    final schedule = [
      if (booking.date.trim().isNotEmpty) booking.date.trim(),
      if (booking.time.trim().isNotEmpty) booking.time.trim(),
    ].join(' \u00b7 ');

    return CustomerSurfacePanel(
      accent: accent,
      emphasised: needsApproval,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusPill(
                label: booking.statusLabel.toUpperCase(),
                showDot: true,
                bg: accent.withValues(alpha: 0.14),
                fg: accent,
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
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (vehicleLine.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              vehicleLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (schedule.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
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
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

class _WelcomePanel extends StatelessWidget {
  final VoidCallback onAddVehicle;

  const _WelcomePanel({required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CustomerSurfacePanel(
      accent: colors.primary,
      emphasised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  size: 20,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  'Your garage is empty',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(
            'Add your vehicle to book service, follow repair progress, and keep '
            'every update in one place.',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppDimensions.s18),
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

class _IdlePanel extends StatelessWidget {
  final int vehicleCount;

  const _IdlePanel({required this.vehicleCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CustomerSurfacePanel(
      accent: colors.onSurfaceVariant,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
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
                  'No active service',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  vehicleCount == 1
                      ? 'Your vehicle is not in the workshop right now.'
                      : 'Your vehicles are not in the workshop right now.',
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
    );
  }
}
