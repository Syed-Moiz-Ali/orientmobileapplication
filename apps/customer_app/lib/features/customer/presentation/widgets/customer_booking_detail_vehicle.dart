import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Vehicle details for the booking's car, composed from the garage's own
/// vehicle record.
///
/// The caller only passes a vehicle it matched on a stable identifier, and this
/// surface is only rendered when that record actually adds something the
/// primary booking record does not already show (year, colour or mileage).
class CustomerBookingDetailVehicle extends StatelessWidget {
  final CustomerBookingEntity booking;
  final CustomerVehicleEntity vehicle;

  const CustomerBookingDetailVehicle({
    super.key,
    required this.booking,
    required this.vehicle,
  });

  /// True when the matched vehicle record carries details worth a surface.
  static bool hasDetails(CustomerVehicleEntity? vehicle) {
    if (vehicle == null) return false;
    return vehicle.year > 0 ||
        vehicle.color.trim().isNotEmpty ||
        vehicle.mileage.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final model = [
      vehicle.brand.trim(),
      vehicle.model.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    final name = model.isNotEmpty ? model : booking.vehicleName.trim();
    final plate =
        (vehicle.plateNumber.trim().isNotEmpty
                ? vehicle.plateNumber
                : booking.plateNumber)
            .trim();
    final specs = <String>[
      if (vehicle.year > 0) '${vehicle.year}',
      if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
      if (vehicle.mileage.trim().isNotEmpty) vehicle.mileage.trim(),
    ];

    return CustomerSurfacePanel(
      accent: colors.onSurfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.garage_rounded,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  'Vehicle',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s10),
          Text(
            name.isEmpty ? 'Your vehicle' : name,
            style: textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (plate.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomerPlateChip(plate: plate),
            ),
          ],
          if (specs.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s10),
            Text(
              specs.join(' \u00b7 '),
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
