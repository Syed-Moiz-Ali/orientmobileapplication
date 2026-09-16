import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

/// Canonical, presentation-only resolution of "what is happening with this
/// vehicle".
///
/// Home and Status both consume these rules so the two screens can never
/// disagree about the same backend state, and so booking/status tone mapping
/// and stage formatting exist in exactly one place. Nothing here changes
/// domain values or API semantics.
abstract final class CustomerServiceTracking {
  CustomerServiceTracking._();

  /// Booking states that still represent work the customer must be aware of.
  static const Set<BookingStatus> liveBookingStatuses = {
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.approvalRequired,
    BookingStatus.vehicleReceived,
    BookingStatus.approved,
    BookingStatus.workAssigned,
    BookingStatus.inProgress,
  };

  /// A live workshop job is only trusted when the backend flags one *and* the
  /// payload actually identifies it. `ActiveServiceResponse.hasActiveJob`
  /// defaults to `true` when the field is absent, so an empty payload must
  /// never render an "in service" surface.
  static bool isLiveService(CustomerServiceEntity? service) {
    if (service == null || !service.hasActiveJob) return false;
    return service.jobCardId.trim().isNotEmpty ||
        service.service.trim().isNotEmpty ||
        service.vehicleName.trim().isNotEmpty ||
        service.currentStage.trim().isNotEmpty ||
        service.stages.isNotEmpty;
  }

  /// The most relevant booking that has not finished yet.
  static CustomerBookingEntity? activeBooking(
    List<CustomerBookingEntity> bookings,
  ) {
    for (final booking in bookings) {
      if (liveBookingStatuses.contains(booking.status)) return booking;
    }
    return null;
  }

  /// Further live bookings beyond the one shown as the tracking target.
  static List<CustomerBookingEntity> otherLiveBookings(
    List<CustomerBookingEntity> bookings,
    CustomerBookingEntity? primary,
  ) {
    return bookings
        .where(
          (booking) =>
              liveBookingStatuses.contains(booking.status) &&
              booking != primary,
        )
        .toList();
  }

  /// The booking that owns a live job card, so a real "view details" route can
  /// be offered instead of a dead end.
  static CustomerBookingEntity? bookingForJobCard(
    List<CustomerBookingEntity> bookings,
    String jobCardId,
  ) {
    final reference = jobCardId.trim();
    if (reference.isEmpty) return null;
    for (final booking in bookings) {
      if (booking.jobCardId.trim() == reference ||
          booking.jobCardRef.trim() == reference) {
        return booking;
      }
    }
    return null;
  }

  /// Invoices the customer genuinely still owes money on.
  static List<InvoiceResponse> unpaidInvoices(List<InvoiceResponse> invoices) {
    return invoices
        .where(
          (invoice) => invoice.status == 'unpaid' && invoice.grandTotal > 0,
        )
        .toList();
  }

  /// Semantic tone shared by every booking/status surface. Completed work is
  /// positive, a customer decision is urgent, cancellation is neutral and
  /// everything else is in-progress informational cobalt.
  static Color bookingTone(ColorScheme colors, BookingStatus status) {
    return switch (status) {
      BookingStatus.completed || BookingStatus.delivered => colors.tertiary,
      BookingStatus.cancelled => colors.onSurfaceVariant,
      BookingStatus.approvalRequired => colors.error,
      _ => colors.primary,
    };
  }

  static Color bookingTint(ColorScheme colors, BookingStatus status) =>
      bookingTone(colors, status).withValues(alpha: 0.12);

  /// Human readable stage/status text.
  ///
  /// Reuses the canonical status vocabulary first, then guarantees that raw
  /// backend identifiers (`in_service`, `quality_check`) never reach the UI.
  static String humanize(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    final canonical = AppStatusLabels.normalizeJob(value);
    if (canonical != value) return canonical;

    if (value.contains('_')) {
      return value
          .split(RegExp(r'[_\s]+'))
          .where((word) => word.isNotEmpty)
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    if (value == value.toLowerCase() && !value.contains(' ')) {
      return value[0].toUpperCase() + value.substring(1);
    }

    return value;
  }

  /// Compacts a vehicle name and plate for a single tracking line.
  static String vehicleLine(String vehicleName, String plateNumber) {
    final vehicle = vehicleName.trim();
    final plate = plateNumber.trim().toUpperCase();
    return [
      if (vehicle.isNotEmpty) vehicle,
      if (plate.isNotEmpty) plate,
    ].join(' \u00b7 ');
  }
}
