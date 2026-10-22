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
/// Presentation only — every handler, route, predicate and key contract is
/// unchanged (see `customer_vehicles_tab.dart`).
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

    // Card hierarchy (brief U0 binding): title = make/model/year (the thing
    // the customer recognizes); plate = small meta; status pill ONLY from
    // existing contextFor() data — never invented, none when absent.
    // Year lives ONCE in the title (brief hierarchy: title carries identity);
    // the specs line shows colour + mileage only (specs() stays verbatim,
    // filtered here for display so the predicate is untouched).
    final title = name.isEmpty
        ? t.vhFallbackName
        : (vehicle.year > 0 ? '$name \u00b7 ${vehicle.year}' : name);
    final yearToken = vehicle.year > 0 ? '${vehicle.year}' : '';
    final displaySpecs = [
      for (final part in specs)
        if (part != yearToken) part,
    ];

    return Semantics(
      label: [
        title,
        if (plate.isNotEmpty) plate,
        if (displaySpecs.isNotEmpty) displaySpecs.join(', '),
        if (serviceContext != null)
          '${serviceContext!.label}, ${serviceContext!.detail}',
      ].join(', '),
      child: AppSurfaceCard(
        // Borderless in light (soft shadow), bordered in dark (C16).
        outlined: false,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand/colour tile placeholder band (the API carries no
            // photography); identity and facts live below it, unchanged.
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusCard),
              ),
              child: Stack(
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
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (displaySpecs.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      displaySpecs.join(' \u00b7 '),
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
            if (serviceContext != null) ...[
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppDimensions.s14,
                  end: AppDimensions.s14,
                  bottom: AppDimensions.s12,
                ),
                child: _ContextLine(
                  serviceContext: serviceContext!,
                  onOpenBooking: onOpenBooking,
                  onTrackService: onTrackService,
                ),
              ),
            ],
            if (deleteFailed) ...[
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppDimensions.s14,
                  end: AppDimensions.s14,
                  bottom: AppDimensions.s12,
                ),
                child: _DeleteFailedNotice(
                  busy: busy,
                  onRetry: onRetryRemoval,
                ),
              ),
            ] else if (syncFailed) ...[
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppDimensions.s14,
                  end: AppDimensions.s14,
                  bottom: AppDimensions.s12,
                ),
                child: _SyncFailedNotice(onRetry: onRetrySync),
              ),
            ],
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppDimensions.s6,
                end: AppDimensions.s6,
                bottom: AppDimensions.s6,
              ),
              child: _Actions(
                busy: busy,
                onBookService: onBookService,
                onEdit: onEdit,
                // While removal recovery is active the normal Remove is
                // withdrawn: a second delete must never be enqueued, and the
                // single recovery control above is the only removal path.
                onRemove: deleteFailed ? null : onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Real service state for one record: a status pill ONLY from existing
/// contextFor() data plus the one-sentence detail and the behind-booking
/// action. No invented health/due claims.
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
    final open = live
        ? onTrackService
        : (serviceContext.booking != null && onOpenBooking != null
              ? () => onOpenBooking!(serviceContext.booking!)
              : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStatusChip(
                // Sentence case via theme (C17): callers pass the label
                // verbatim, no .toUpperCase() anywhere on this screen.
                label: serviceContext.label,
                kind: switch (serviceContext.kind) {
                  CustomerVehicleContextKind.inService =>
                    AppStatusKind.accent,
                  CustomerVehicleContextKind.upcoming => AppStatusKind.info,
                  CustomerVehicleContextKind.completed =>
                    AppStatusKind.neutral,
                },
              ),
              if (serviceContext.detail.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s6),
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
        if (open != null) ...[
          const SizedBox(width: AppDimensions.s8),
          TextButton(
            onPressed: open,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s8,
              ),
            ),
            child: Text(
              live ? context.cx.vhTrack : context.cx.vhView,
            ),
          ),
        ],
      ],
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
    return AppBanner(
      kind: AppBannerKind.warning,
      message: context.cx.vhSyncFail,
      actionLabel: onRetry == null ? null : context.cx.vhRetry,
      onAction: onRetry == null ? null : () => onRetry!(),
    );
  }
}

/// Truthful recovery for a removal the workshop never confirmed: the vehicle
/// is still there, so it stays visible and offers a single retry.
class _DeleteFailedNotice extends StatelessWidget {
  final bool busy;
  final VoidCallback? onRetry;

  const _DeleteFailedNotice({required this.busy, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return AppBanner(
      kind: AppBannerKind.error,
      message: '${t.vhDeleteFailTitle} ${t.vhDeleteFailBody}',
      actionLabel: busy
          ? null
          : (onRetry == null ? null : t.vhRetryRemoval),
      onAction: busy || onRetry == null ? null : () => onRetry!(),
    );
  }
}

/// Frequent action binding (brief U3/U14): Book service sits DIRECTLY on each
/// card (≤ 1 tap from the list); Edit/Remove live in the card menu
/// (existing routes only). Wraps instead of overflowing at 320px / 1.3x.
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
    final menuTooltip = MaterialLocalizations.of(
      context,
    ).showMenuTooltip;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
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
        PopupMenuButton<String>(
          enabled: !busy,
          tooltip: menuTooltip,
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'remove') {
              onRemove?.call();
            }
          },
          itemBuilder: (itemContext) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(itemContext.cx.vhEdit),
            ),
            // While removal recovery is active the normal Remove is
            // withdrawn (same contract as before).
            if (onRemove != null)
              PopupMenuItem(
                value: 'remove',
                child: Text(
                  itemContext.cx.vhRemove,
                  style: TextStyle(color: colors.error),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
