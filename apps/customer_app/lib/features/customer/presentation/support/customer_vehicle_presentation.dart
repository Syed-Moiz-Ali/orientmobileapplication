import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_booking_relations.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';

/// What a vehicle record may honestly say.
///
/// The vehicle endpoints carry no provenance: `healthScore` is 100 for every
/// customer-added vehicle, and `lastService`/`nextDue` are placeholder strings
/// that no workshop process ever updates. So this helper never presents those
/// fields as facts — the record's real service context comes from the
/// customer's own bookings instead.
abstract final class CustomerVehiclePresentation {
  CustomerVehiclePresentation._();

  /// `48,200 km` — one `km` suffix, or empty when the mileage is unknown.
  /// A blank mileage is never turned into `0 km`.
  static String mileageLabel(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    final number = value.replaceFirst(RegExp(r'\s*[kK][mM]\s*$'), '').trim();
    if (number.isEmpty) return '';
    return '$number km';
  }

  /// The mileage without its unit, for editing.
  static String mileageInput(String raw) {
    final label = mileageLabel(raw);
    if (label.isEmpty) return '';
    return label.replaceFirst(RegExp(r'\s*[kK][mM]$'), '').trim();
  }

  /// `A 12345` — upper case, single-spaced. Never padded or invented.
  static String plateLabel(String raw) =>
      raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Real, known specification parts in a stable order: year, colour, mileage.
  static List<String> specs(CustomerVehicleEntity vehicle) => [
    if (vehicle.year > 0) '${vehicle.year}',
    if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
    if (mileageLabel(vehicle.mileage).isNotEmpty) mileageLabel(vehicle.mileage),
  ];

  /// True when the vehicle carries any real specification worth a line.
  static bool hasSpecs(CustomerVehicleEntity vehicle) =>
      specs(vehicle).isNotEmpty;

  /// The explicit `AddVehicleRequest` contract.
  ///
  /// Only fields the API declares are ever sent. Health and the service dates
  /// are preserved exactly as stored — a customer edit must never invent an
  /// assessment nor erase one the workshop made.
  static Map<String, dynamic> apiPayload(CustomerVehicleEntity vehicle) => {
    'brand': vehicle.brand.trim(),
    'model': vehicle.model.trim(),
    'plateNumber': plateLabel(vehicle.plateNumber),
    'vin': vehicle.vin.trim().toUpperCase(),
    'color': vehicle.color.trim(),
    'year': vehicle.year,
    'mileage': mileageLabel(vehicle.mileage),
    'lastService': vehicle.lastService.trim(),
    'nextDue': vehicle.nextDue.trim(),
    'healthScore': vehicle.healthScore,
  };

  /// A real service context for one vehicle, derived only from records that
  /// genuinely reference it (matched on the plate, the identifier both the
  /// booking and the vehicle endpoints carry).
  static CustomerVehicleContext? contextFor({
    required CustomerVehicleEntity vehicle,
    required List<CustomerBookingEntity> bookings,
    CustomerServiceEntity? liveService,
    String Function(double amount)? formatAmount,
  }) {
    final plate = CustomerBookingRelations.normalizePlate(vehicle.plateNumber);
    if (plate.isEmpty) return null;

    // Work happening now: the active job card belongs to this vehicle.
    if (liveService != null && liveService.hasActiveJob) {
      final servicePlate = CustomerBookingRelations.normalizePlate(
        liveService.plateNumber,
      );
      if (servicePlate.isNotEmpty && servicePlate == plate) {
        final stage = CustomerServiceTracking.humanize(
          liveService.currentStage,
        );
        return CustomerVehicleContext(
          kind: CustomerVehicleContextKind.inService,
          label: 'In the workshop now',
          detail: stage.isEmpty
              ? 'Service in progress'
              : 'Current stage · $stage',
          booking: null,
        );
      }
    }

    final mine = bookingsFor(vehicle, bookings);
    if (mine.isEmpty) return null;

    // The next appointment that has not finished yet.
    final upcoming = CustomerBookingsPresentation.sortByUpcoming(
      mine.where((b) => !_finished(b.status)).toList(),
    );
    if (upcoming.isNotEmpty) {
      final booking = upcoming.first;
      return CustomerVehicleContext(
        kind: CustomerVehicleContextKind.upcoming,
        label: upcomingLabel(booking.status),
        detail: _scheduleOrService(booking),
        booking: booking,
      );
    }

    // Otherwise the most recent finished service, as real history.
    final past = CustomerBookingsPresentation.sortByRecent(
      mine.where((b) => _finished(b.status)).toList(),
    );
    if (past.isEmpty) return null;
    final booking = past.first;
    return CustomerVehicleContext(
      kind: CustomerVehicleContextKind.completed,
      label: 'Last service',
      detail: _scheduleOrService(booking),
      booking: booking,
    );
  }

  /// Every booking that references one vehicle, matched on the plate.
  static List<CustomerBookingEntity> bookingsFor(
    CustomerVehicleEntity vehicle,
    List<CustomerBookingEntity> bookings,
  ) {
    final plate = CustomerBookingRelations.normalizePlate(vehicle.plateNumber);
    if (plate.isEmpty) return const [];
    return bookings
        .where(
          (booking) =>
              CustomerBookingRelations.normalizePlate(booking.plateNumber) ==
              plate,
        )
        .toList();
  }

  static String upcomingLabel(BookingStatus status) =>
      status == BookingStatus.confirmed ? 'Booked' : 'Requested';

  static String _scheduleOrService(CustomerBookingEntity booking) {
    final service = booking.service.trim();
    // The compact date keeps the real appointment on one line in a record.
    final schedule = [
      CustomerBookingsPresentation.compactDateLabel(booking.date),
      CustomerBookingsPresentation.timeLabel(booking.time),
    ].where((part) => part.isNotEmpty).join(' \u00b7 ');
    return [
      service,
      schedule,
    ].where((part) => part.isNotEmpty).join(' \u00b7 ');
  }

  static bool _finished(BookingStatus status) =>
      status == BookingStatus.completed ||
      status == BookingStatus.delivered ||
      status == BookingStatus.cancelled;
}

enum CustomerVehicleContextKind { inService, upcoming, completed }

/// Real, record-derived state for one vehicle: what is happening with it.
class CustomerVehicleContext {
  final CustomerVehicleContextKind kind;

  /// `In the workshop now`, `Requested`, `Booked`, `Last service`.
  final String label;

  /// The real stage, service, schedule — whatever the record actually holds.
  final String detail;

  /// The booking behind this context, when there is one.
  final CustomerBookingEntity? booking;

  const CustomerVehicleContext({
    required this.kind,
    required this.label,
    required this.detail,
    required this.booking,
  });
}
