import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// Hero vehicle carousel: one 16:10 imagery card per registered vehicle.
///
/// The art is an illustrative silhouette (the API carries no photography),
/// the badge is the vehicle's real service context derived from its own
/// bookings — in the workshop now, booked/requested, or last service — and
/// there is deliberately no health pill and no favorite heart: the endpoints
/// carry no assessment provenance and no favorite contract, so the addendum's
/// no-fake-ratings rule keeps both off. Tapping a card books service for
/// that exact vehicle.
class CustomerGarageCarousel extends StatefulWidget {
  final List<CustomerVehicleEntity> vehicles;
  final List<CustomerBookingEntity> bookings;
  final CustomerServiceEntity? liveService;
  final void Function(CustomerVehicleEntity vehicle) onBookVehicle;
  final void Function(CustomerBookingEntity booking)? onOpenBooking;
  final VoidCallback? onTrackService;

  const CustomerGarageCarousel({
    super.key,
    required this.vehicles,
    required this.bookings,
    required this.onBookVehicle,
    this.liveService,
    this.onOpenBooking,
    this.onTrackService,
  });

  @override
  State<CustomerGarageCarousel> createState() => _CustomerGarageCarouselState();
}

class _CustomerGarageCarouselState extends State<CustomerGarageCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicles = widget.vehicles;
    if (vehicles.isEmpty) return const SizedBox.shrink();

    // Any non-compact canvas grids the cards: a 16:10 band of a wide card
    // would tower half a viewport inside a fixed-height pager, so swipe
    // stays a compact idiom.
    if (!context.isCompact) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vehicles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // Two-up on tablets keeps cards readable; three-up beyond that
          // keeps the 16:10 band from towering (audited 1280px at 1.3x).
          crossAxisCount: context.adaptive.isMedium ? 2 : 3,
          crossAxisSpacing: AppDimensions.s16,
          mainAxisSpacing: AppDimensions.s16,
          // Art band plus two text lines and the plate row at 1.3x on
          // the widest cells (audited 1280px).
          mainAxisExtent: 384,
        ),
        itemBuilder: (context, index) =>
            _card(context, vehicles[index]),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          // 16:10 art plus the title/meta/footer block below it, with room
          // for 1.3x text growth (audited 320px).
          height: 344,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: vehicles.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsetsDirectional.only(
                end: index == vehicles.length - 1 ? 0 : AppDimensions.s12,
              ),
              child: _card(context, vehicles[index]),
            ),
          ),
        ),
        if (vehicles.length > 1) ...[
          const SizedBox(height: AppDimensions.s10),
          Semantics(
            label: 'Page ${_page + 1} of ${vehicles.length}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < vehicles.length; i++)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s4,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, CustomerVehicleEntity vehicle) {
    final vContext = CustomerVehiclePresentation.contextFor(
      vehicle: vehicle,
      bookings: widget.bookings,
      liveService: widget.liveService,
    );
    return _VehicleCard(
      vehicle: vehicle,
      serviceContext: vContext,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onBookVehicle(vehicle);
      },
      onOpenBooking: widget.onOpenBooking,
      onTrackService: widget.onTrackService,
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
    final plate =
        CustomerVehiclePresentation.plateLabel(vehicle.plateNumber);
    // Year · mileage · colour: the hero order pinned by the home contract
    // (manage rows use the shared specs() order instead — both honest,
    // each matching its own surface).
    final specs = <String>[
      if (vehicle.year > 0) '${vehicle.year}',
      if (CustomerVehiclePresentation.mileageLabel(vehicle.mileage).isNotEmpty)
        CustomerVehiclePresentation.mileageLabel(vehicle.mileage),
      if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
    ];
    final ctx = serviceContext;

    return AirbnbImageCard(
      image: const VehicleSilhouetteArt(),
      badge: ctx == null
          ? null
          : _ContextBadge(
              kind: ctx.kind,
              label: ctx.label,
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
                CustomerPlateChip(plate: plate),
              ],
            ),
      onTap: onTap,
    );
  }
}

/// Real service context as the overlay badge. Tapping opens the live tracker
/// for in-service work or the behind booking otherwise; kinds without a
/// destination render badge-only (no dead affordance).
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
    final pill = switch (kind) {
      CustomerVehicleContextKind.inService =>
        StatusPill.inProgress(label.toUpperCase()),
      CustomerVehicleContextKind.upcoming =>
        StatusPill.info(label.toUpperCase()),
      CustomerVehicleContextKind.completed =>
        StatusPill.neutral(label.toUpperCase()),
    };
    if (onTap == null) return pill;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: pill,
    );
  }
}
