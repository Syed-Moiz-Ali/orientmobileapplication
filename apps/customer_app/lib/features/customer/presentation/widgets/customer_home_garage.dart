import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// The customer's registered vehicles as an [AppCarousel] with a peeking
/// next card (~2.2 visible) and a "Show all" action into the vehicles tab.
///
/// Cards keep illustrative silhouette art (the API carries no photography)
/// and the vehicle's real service context derived from its own bookings —
/// in the workshop now, booked/requested, or last service — never a health
/// score (no provenance), never a favorite (no contract), never a promotion
/// (no endpoint). Tapping a card books service for that exact vehicle.
class CustomerHomeGarage extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final List<CustomerBookingEntity> bookings;
  final CustomerServiceEntity? liveService;
  final void Function(CustomerVehicleEntity vehicle) onBookVehicle;
  final void Function(CustomerBookingEntity booking)? onOpenBooking;
  final VoidCallback? onTrackService;
  final VoidCallback? onSeeAll;

  const CustomerHomeGarage({
    super.key,
    required this.vehicles,
    required this.bookings,
    required this.onBookVehicle,
    this.onSeeAll,
    this.liveService,
    this.onOpenBooking,
    this.onTrackService,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    if (vehicles.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final locale = Localizations.localeOf(context);
        final l10n = context.cx;
        // ~2.2 cards visible in the compact viewport; wider canvases cap the
        // extent so cards stay readable instead of stretching. One vehicle is
        // fully shown (nothing to peek at), so it takes the available width
        // instead of the peek slot — the grouped spec line stays whole.
        final extent = vehicles.length == 1
            ? constraints.maxWidth.clamp(150.0, 480.0)
            : (constraints.maxWidth / 2.2).clamp(150.0, 300.0);
        return AppCarousel(
          title: vehicles.length == 1 ? t.garTitleOne : t.garTitleMany,
          seeAllLabel: t.garShowAll,
          // U7: one vehicle is fully shown — no "Show all" to the same list.
          onSeeAll: onSeeAll == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onSeeAll!();
                },
          cardExtent: extent,
          semanticLabel: vehicles.length == 1
              ? t.garTitleOne
              : t.garTitleMany,
          children: [
            for (final vehicle in vehicles)
              _VehicleCard(
                vehicle: vehicle,
                serviceContext: CustomerVehiclePresentation.contextFor(
                  vehicle: vehicle,
                  bookings: bookings,
                  liveService: liveService,
                  l10n: l10n,
                  locale: locale,
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onBookVehicle(vehicle);
                },
                onOpenBooking: onOpenBooking,
                onTrackService: onTrackService,
              ),
          ],
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final CustomerVehicleContext? serviceContext;
  final VoidCallback onTap;
  final void Function(CustomerBookingEntity booking)? onOpenBooking;
  final VoidCallback? onTrackService;

  const _VehicleCard({
    required this.vehicle,
    required this.serviceContext,
    required this.onTap,
    this.onOpenBooking,
    this.onTrackService,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final name = vehicle.displayName.trim().isEmpty
        ? t.vhFallbackName
        : vehicle.displayName.trim();
    final plate = CustomerVehiclePresentation.plateLabel(vehicle.plateNumber);
    // Year · mileage · colour: the hero order pinned by the home contract
    // (manage rows use the shared specs() order instead — both honest,
    // each matching its own surface).
    final specs = <String>[
      if (vehicle.year > 0) '${vehicle.year}',
      if (CustomerVehiclePresentation.displayMileage(vehicle.mileage).isNotEmpty)
        CustomerVehiclePresentation.displayMileage(vehicle.mileage),
      if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
    ];
    final ctx = serviceContext;
    // Localized badge copy at the presentation edge: the service context
    // carries the (record-derived) kind; the words come from ARB so the
    // badge reads `قيد الصيانة` in Arabic instead of English. Sentence case
    // per C3 — never upper-cased.
    final String? badgeLabel = switch (ctx?.kind) {
      CustomerVehicleContextKind.inService => t.bkInService,
      CustomerVehicleContextKind.upcoming =>
        ctx?.booking?.status == BookingStatus.confirmed
            ? t.garStatusBooked
            : t.garStatusRequested,
      CustomerVehicleContextKind.completed => t.garStatusLastService,
      null => null,
    };

    return AirbnbImageCard(
      image: const VehicleSilhouetteArt(),
      badge: ctx == null || badgeLabel == null
          ? null
          : _ContextBadge(
              kind: ctx.kind,
              label: badgeLabel,
              onTap: ctx.kind == CustomerVehicleContextKind.inService
                  ? onTrackService
                  : (ctx.booking != null && onOpenBooking != null
                        ? () => onOpenBooking!(ctx.booking!)
                        : null),
            ),
      title: name,
      // Mixed word/number specs follow the ambient direction (same as the
      // staff/owner surfaces); pure Latin identifiers stay LTR-locked.
      meta: specs.isEmpty ? null : specs.join(' · '),
      footer: plate.isEmpty
          ? null
          : Row(
              children: [
                Flexible(child: CustomerPlateChip(plate: plate)),
              ],
            ),
      onTap: onTap,
    );
  }
}

/// Real service context as the overlay badge. Tapping opens the live tracker
/// for in-service work or the behind booking otherwise; kinds without a
/// destination render badge-only (no dead affordance).
///
/// [AppStatusChip] (not a single-line pill): the label wraps to a second
/// line instead of clipping (`IN THE WORKSHOP NO…`), dot + label kept.
class _ContextBadge extends StatelessWidget {
  final CustomerVehicleContextKind kind;
  final String label;
  final VoidCallback? onTap;

  const _ContextBadge({
    required this.kind,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = switch (kind) {
      CustomerVehicleContextKind.inService =>
        AppStatusChip(label: label, kind: AppStatusKind.accent),
      CustomerVehicleContextKind.upcoming =>
        AppStatusChip(label: label, kind: AppStatusKind.info),
      CustomerVehicleContextKind.completed =>
        AppStatusChip(label: label, kind: AppStatusKind.neutral),
    };
    if (onTap == null) return chip;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: chip,
    );
  }
}
