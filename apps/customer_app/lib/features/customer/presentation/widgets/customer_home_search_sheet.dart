import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';

/// Customer Home global find sheet (U1/U9): search across the home's
/// EXISTING vehicles + bookings, presented full-screen from the header
/// search icon (same mechanism and placement as the advisor home).
///
/// Filtering is an in-memory substring match over the lists the home
/// already holds — no new routes, no new providers, no new logic. Result
/// taps reuse the home's existing destinations (book service for a vehicle,
/// booking detail for a booking); the opener owns popping + navigating.
/// Recents are honestly omitted: the customer app keeps no recent searches
/// anywhere, so the empty state is a plain hint line instead.
class CustomerHomeSearchSheet extends StatefulWidget {
  final List<CustomerVehicleEntity> vehicles;
  final List<CustomerBookingEntity> bookings;
  final ValueChanged<CustomerVehicleEntity> onSelectVehicle;
  final ValueChanged<CustomerBookingEntity> onSelectBooking;

  const CustomerHomeSearchSheet({
    super.key,
    required this.vehicles,
    required this.bookings,
    required this.onSelectVehicle,
    required this.onSelectBooking,
  });

  @override
  State<CustomerHomeSearchSheet> createState() =>
      _CustomerHomeSearchSheetState();
}

class _CustomerHomeSearchSheetState extends State<CustomerHomeSearchSheet> {
  String _query = '';

  List<CustomerVehicleEntity> _matchVehicles(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.vehicles
        .where(
          (v) =>
              v.brand.toLowerCase().contains(q) ||
              v.model.toLowerCase().contains(q) ||
              v.plateNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  List<CustomerBookingEntity> _matchBookings(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.bookings
        .where(
          (b) =>
              b.service.toLowerCase().contains(q) ||
              b.vehicleName.toLowerCase().contains(q) ||
              b.plateNumber.toLowerCase().contains(q) ||
              b.bookingRef.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final colors = Theme.of(context).colorScheme;
    final query = _query.trim();
    final vehicleHits = _matchVehicles(query);
    final bookingHits = _matchBookings(query);
    final hasResults = vehicleHits.isNotEmpty || bookingHits.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.garSearchTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppSearchField(
          autofocus: true,
          hintText: t.garSearchHint,
          onChanged: (v) => setState(() => _query = v),
          onClear: () => setState(() => _query = ''),
        ),
        if (query.isEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            t.garSearchEmpty,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ] else if (!hasResults) ...[
          const SizedBox(height: AppSpacing.lg),
          EmptyState.noMatch(
            icon: Icons.search_off_rounded,
            message: t.garSearchNoMatch,
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (vehicleHits.isNotEmpty) ...[
                    _GroupHeader(
                      label: '${t.garNavVehicles} (${vehicleHits.length})',
                    ),
                    for (final vehicle in vehicleHits)
                      _VehicleResult(
                        vehicle: vehicle,
                        onTap: () => widget.onSelectVehicle(vehicle),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (bookingHits.isNotEmpty) ...[
                    _GroupHeader(
                      label: '${t.garNavBookings} (${bookingHits.length})',
                    ),
                    for (final booking in bookingHits)
                      _BookingResult(
                        booking: booking,
                        onTap: () => widget.onSelectBooking(booking),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;

  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _VehicleResult extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final VoidCallback onTap;

  const _VehicleResult({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final name = vehicle.displayName.trim().isEmpty
        ? t.vhFallbackName
        : vehicle.displayName.trim();
    final plate = CustomerVehiclePresentation.plateLabel(vehicle.plateNumber);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppRecordRow(
        leading: const Icon(Icons.directions_car_filled_rounded),
        title: name,
        subtitle: plate.isEmpty ? null : plate,
        onTap: onTap,
      ),
    );
  }
}

class _BookingResult extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _BookingResult({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final title = booking.service.trim().isEmpty
        ? t.bkServiceAppt
        : booking.service.trim();
    final meta = [
      if (booking.vehicleName.trim().isNotEmpty) booking.vehicleName.trim(),
      if (booking.date.trim().isNotEmpty) booking.date.trim(),
    ].join(' \u00b7 ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppRecordRow(
        leading: const Icon(Icons.receipt_long_rounded),
        title: title,
        subtitle: meta.isEmpty ? null : meta,
        onTap: onTap,
      ),
    );
  }
}
