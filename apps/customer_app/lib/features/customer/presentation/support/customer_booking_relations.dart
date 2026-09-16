import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

/// Presentation-only resolution of the *other real records* that belong to one
/// booking.
///
/// Booking Details is allowed to compose related product data, but only from
/// records that can be matched reliably: a booking knows its own plate and its
/// own estimate id, so those are the only identifiers used here. Nothing is
/// inferred from dates, ordering or similar-looking names.
abstract final class CustomerBookingRelations {
  CustomerBookingRelations._();

  /// The garage vehicle this booking is about, matched on the plate — a stable
  /// identifier carried by both the booking and the vehicle record.
  ///
  /// Returns null when the booking has no plate or no vehicle matches, so the
  /// UI simply omits the vehicle surface instead of showing another car.
  static CustomerVehicleEntity? vehicleFor(
    CustomerBookingEntity booking,
    List<CustomerVehicleEntity> vehicles,
  ) {
    final plate = normalizePlate(booking.plateNumber);
    if (plate.isEmpty) return null;
    for (final vehicle in vehicles) {
      if (normalizePlate(vehicle.plateNumber) == plate) return vehicle;
    }
    return null;
  }

  /// The pending estimate approval that genuinely belongs to this booking.
  ///
  /// Only the pending feed is consulted, and only an exact estimate id match
  /// counts, so an approval is never attached to the wrong booking.
  static CustomerApprovalSummaryResponse? approvalFor(
    CustomerBookingEntity booking,
    List<CustomerApprovalSummaryResponse> approvals,
  ) {
    final estimateId = booking.estimateId.trim();
    if (estimateId.isEmpty) return null;
    for (final approval in approvals) {
      if (approval.estimateId.trim() == estimateId) return approval;
    }
    return null;
  }

  /// True when the customer genuinely has a decision to make: the booking's own
  /// status says so, or a pending approval really exists for its estimate.
  static bool needsApproval(
    CustomerBookingEntity booking,
    CustomerApprovalSummaryResponse? approval,
  ) {
    return booking.status == BookingStatus.approvalRequired || approval != null;
  }

  /// The real estimate amount, preferring the amount on the approval record and
  /// falling back to the booking. Returns null when neither carries one, so the
  /// UI can omit the figure rather than invent it.
  static double? estimateAmount(
    CustomerBookingEntity booking,
    CustomerApprovalSummaryResponse? approval,
  ) {
    final approved = approval?.amount ?? 0;
    if (approved > 0) return approved;
    if (booking.estimateAmount > 0) return booking.estimateAmount;
    return null;
  }

  /// Plates are compared without punctuation or case so `A 12345`, `a-12345`
  /// and `A12345` are recognised as the same vehicle.
  static String normalizePlate(String raw) =>
      raw.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
}
