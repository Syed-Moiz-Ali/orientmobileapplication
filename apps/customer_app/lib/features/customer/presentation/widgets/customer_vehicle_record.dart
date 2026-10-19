import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// One vehicle in the garage: identity, the real specification it carries, its
/// real service context, and the actions a customer has for it.
///
/// No photography and no painted status: the only claims made here come from
/// the vehicle record and from bookings that genuinely reference the vehicle.
class CustomerVehicleRecord extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final CustomerVehicleContext? serviceContext;

  /// True while an action for this record is in flight.
  final bool busy;
  final VoidCallback onBookService;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  /// Opens the booking behind the context, when there is one.
  final void Function(CustomerBookingEntity booking)? onOpenBooking;

  /// Opens the contextual service tracking page.
  final VoidCallback? onTrackService;

  /// True when this vehicle's registration has permanently failed, so the
  /// customer needs an explicit retry.
  final bool syncFailed;
  final VoidCallback? onRetrySync;

  /// True when a removal the customer asked for terminally failed, so the
  /// vehicle is still at the workshop and must stay visible with a retry.
  final bool deleteFailed;
  final VoidCallback? onRetryRemoval;

  const CustomerVehicleRecord({
    super.key,
    required this.vehicle,
    required this.onBookService,
    required this.onEdit,
    required this.onRemove,
    this.serviceContext,
    this.busy = false,
    this.onOpenBooking,
    this.onTrackService,
    this.syncFailed = false,
    this.onRetrySync,
    this.deleteFailed = false,
    this.onRetryRemoval,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = vehicle.displayName.trim();
    final plate = CustomerVehiclePresentation.plateLabel(vehicle.plateNumber);
    final specs = CustomerVehiclePresentation.specs(vehicle);
    final vin = vehicle.vin.trim();

    return Semantics(
      label: [
        name.isEmpty ? t.vhFallbackName : name,
        if (plate.isNotEmpty) plate,
        if (specs.isNotEmpty) specs.join(', '),
        if (serviceContext != null)
          '${serviceContext!.label}, ${serviceContext!.detail}',
      ].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Illustrative silhouette band (the API carries no photography);
          // identity and facts live below it, unchanged.
          Stack(
            children: [
              const SizedBox(
                width: double.infinity,
                height: 96,
                child: VehicleSilhouetteArt(),
              ),
              if (plate.isNotEmpty)
                PositionedDirectional(
                  bottom: AppDimensions.s8,
                  start: AppDimensions.s14,
                  child: CustomerPlateChip(plate: plate),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? t.vhFallbackName : name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (specs.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.s4),
                            Text(
                              specs.join(' \u00b7 '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (vin.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.s4),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                'VIN $vin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.mono(
                                  color: colors.onSurfaceVariant,
                                ).copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            if (serviceContext != null) ...[
              const SizedBox(height: AppDimensions.s12),
              _ContextLine(
                serviceContext: serviceContext!,
                onOpenBooking: onOpenBooking,
                onTrackService: onTrackService,
              ),
            ],
            if (deleteFailed) ...[
              const SizedBox(height: AppDimensions.s12),
              _DeleteFailedNotice(busy: busy, onRetry: onRetryRemoval),
            ] else if (syncFailed) ...[
              const SizedBox(height: AppDimensions.s12),
              _SyncFailedNotice(onRetry: onRetrySync),
            ],
            const SizedBox(height: AppDimensions.s12),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppDimensions.s8),
            _Actions(
              busy: busy,
              onBookService: onBookService,
              onEdit: onEdit,
              // While removal recovery is active the normal Remove is withdrawn:
              // a second delete must never be enqueued, and the single recovery
              // control below is the only removal path.
              onRemove: deleteFailed ? null : onRemove,
            ),
          ],
        ),
    );
  }
}

/// Restrained, truthful notice for the one state that needs the customer's
/// help: a registration that never completed.
class _SyncFailedNotice extends StatelessWidget {
  final VoidCallback? onRetry;

  const _SyncFailedNotice({this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(
          Icons.sync_problem_rounded,
          size: AppDimensions.iconSm,
          color: colors.error,
        ),
        const SizedBox(width: AppDimensions.s6),
        Expanded(
          child: Text(
            context.cx.vhSyncFail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
            ),
            child: Text(context.cx.vhRetry),
          ),
      ],
    );
  }
}

class _ContextLine extends StatelessWidget {
  final CustomerVehicleContext serviceContext;
  final void Function(CustomerBookingEntity booking)? onOpenBooking;
  final VoidCallback? onTrackService;

  const _ContextLine({
    required this.serviceContext,
    this.onOpenBooking,
    this.onTrackService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final live = serviceContext.kind == CustomerVehicleContextKind.inService;
    final tone = live ? colors.primary : colors.onSurfaceVariant;
    final open = live
        ? onTrackService
        : (serviceContext.booking != null && onOpenBooking != null
              ? () => onOpenBooking!(serviceContext.booking!)
              : null);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s12,
        vertical: AppDimensions.s10,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(tone.withValues(alpha: 0.05), colors.surface),
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            live ? Icons.build_circle_rounded : Icons.event_available_rounded,
            size: AppDimensions.iconSm,
            color: tone,
          ),
          const SizedBox(width: AppDimensions.s6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceContext.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                if (serviceContext.detail.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.r2),
                  Text(
                    serviceContext.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (open != null)
            TextButton(
              onPressed: open,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s8,
                ),
              ),
              child: Text(
                live
                    ? context.cx.vhTrack
                    : context.cx.vhView,
              ),
            ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final bool busy;
  final VoidCallback onBookService;
  final VoidCallback onEdit;

  /// Null while a removal recovery is active, so no second delete is offered.
  final VoidCallback? onRemove;

  const _Actions({
    required this.busy,
    required this.onBookService,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Wraps instead of overflowing: the actions stack on the narrowest phones
    // and at large text scales.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: AppDimensions.s4,
      runSpacing: AppDimensions.s4,
      children: [
        TextButton.icon(
          onPressed: busy ? null : onBookService,
          icon: const Icon(Icons.calendar_month_rounded, size: 18),
          label: Text(context.cx.vhBook),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
          ),
        ),
        TextButton(
          onPressed: busy ? null : onEdit,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
          ),
          child: Text(context.cx.vhEdit),
        ),
        // Removal stays tertiary and clearly destructive.
        if (onRemove != null)
          TextButton(
            onPressed: busy ? null : onRemove,
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
            ),
            child: Text(context.cx.vhRemove),
          ),
      ],
    );
  }
}

/// Truthful recovery for a removal the workshop never confirmed: the vehicle is
/// still there, so it stays visible and offers a single retry.
class _DeleteFailedNotice extends StatelessWidget {
  final bool busy;
  final VoidCallback? onRetry;

  const _DeleteFailedNotice({required this.busy, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      container: true,
      label:
          '${context.cx.vhDeleteFailTitle} ${context.cx.vhDeleteFailBody}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s10,
          vertical: AppDimensions.s10,
        ),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.error.withValues(alpha: 0.05),
            colors.surface,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          border: Border.all(color: colors.error.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconSm,
                  color: colors.error,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.cx.vhDeleteFailTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.r2),
                      Text(
                        context.cx.vhDeleteFailBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s8),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: AppDimensions.touchTarget,
                child: FilledButton(
                  onPressed: busy ? null : onRetry,
                  child: Text(
                    busy ? context.cx.vhRetrying : context.cx.vhRetryRemoval,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
