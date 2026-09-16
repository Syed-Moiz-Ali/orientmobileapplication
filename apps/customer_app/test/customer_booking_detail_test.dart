import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_booking_relations.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_vehicle.dart';

void main() {
  setUpAll(_loadFonts);

  group('CustomerBookingDetail identity', () {
    testWidgets('represents the booking the customer opened', (tester) async {
      await _pumpDetail(tester, booking: _confirmed);

      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Brake Inspection'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser'), findsOneWidget);
      // The appointment is presented in fuller form than the Bookings row.
      expect(find.text('Appointment'), findsOneWidget);
      expect(find.text('Tuesday, 22 September 2026'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('BK-2026-0188'), findsOneWidget);
    });

    testWidgets('reads the appointment from the payload the app really sends', (
      tester,
    ) async {
      // The booking flow writes `dd/MM/yyyy`; the detail must still present the
      // appointment properly instead of falling back to a raw string.
      await _pumpDetail(tester, booking: _withVehicle);

      expect(find.text('Appointment'), findsOneWidget);
      expect(find.text('Tuesday, 22 September 2026'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(
        find.textContaining('22/09/2026'),
        findsNothing,
        reason: 'raw backend dates must not reach the customer',
      );
    });

    testWidgets('never shows fabricated workshop or demo content', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _confirmed);

      // The pre-redesign screen invented a workshop location and contact
      // details; none of that was real, so none of it may return.
      expect(find.textContaining('Orient Automotive'), findsNothing);
      expect(find.textContaining('Workshop Bay'), findsNothing);
      expect(find.textContaining('Main Bay'), findsNothing);
      expect(find.textContaining('+971'), findsNothing);
      expect(find.textContaining('Opening Hours'), findsNothing);
      expect(find.textContaining('Mon\u2013Fri'), findsNothing);
      expect(find.textContaining('Live stage tracker'), findsNothing);
      expect(find.text('Quick Reserve'), findsNothing);
      expect(find.textContaining('AED 89'), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('offers no action the product does not implement', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _confirmed);

      // None of these exist in the customer app, so none may be implied here.
      for (final label in const [
        'Reschedule',
        'Call workshop',
        'Message advisor',
        'Contact advisor',
        'Pay now',
        'Download invoice',
        'Rate service',
        'Book again',
        'Add to calendar',
      ]) {
        expect(find.textContaining(label), findsNothing, reason: label);
      }
    });
  });

  group('CustomerBookingDetail lifecycle', () {
    testWidgets('an upcoming booking explains what happens next', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _confirmed);

      expect(find.textContaining('Your service is booked.'), findsOneWidget);
      expect(find.text('Track service'), findsNothing);
      expect(find.text('Current stage'), findsNothing);
    });

    testWidgets('a pending request reads as upcoming, not as work', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _pending);

      expect(find.text('PENDING'), findsOneWidget);
      // A requested booking is not a confirmed one.
      expect(
        find.textContaining('The workshop has your request'),
        findsOneWidget,
      );
      expect(find.textContaining('Your service is booked.'), findsNothing);
      expect(find.text('Track service'), findsNothing);
      expect(find.text('Current stage'), findsNothing);
    });

    testWidgets('a past booking states its outcome, not a next step', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _completed);

      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Track service'), findsNothing);
      expect(find.textContaining('Your service is booked.'), findsNothing);
    });

    testWidgets('a delivered booking stays historical and action-free', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _delivered);

      expect(find.text('DELIVERED'), findsOneWidget);
      expect(find.text('Track service'), findsNothing);
      expect(find.text('Cancel booking'), findsNothing);
      expect(find.text('Action required'), findsNothing);
    });

    testWidgets('a cancelled booking is represented as inactive', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _cancelled);

      expect(find.text('CANCELLED'), findsWidgets);
      expect(find.text('Track service'), findsNothing);
      expect(find.text('Cancel booking'), findsNothing);
      expect(find.textContaining('Your service is booked.'), findsNothing);
    });

    testWidgets('surfaces the live stage only when the workshop owns it', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        booking: _inService,
        activeService: _liveService,
      );

      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(find.text('Current stage'), findsOneWidget);
      expect(find.text('Quality Check'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(
        find.text('Estimated completion \u00b7 2026-09-16 17:00'),
        findsOneWidget,
      );
      // Raw backend identifiers must never reach the customer.
      expect(find.textContaining('quality_check'), findsNothing);
    });

    testWidgets('opens the contextual Service Status from the summary', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        booking: _inService,
        activeService: _liveService,
      );

      await tester.tap(find.text('Track service'));
      await tester.pumpAndSettle();

      expect(find.text('SERVICE_STATUS'), findsOneWidget);
    });

    testWidgets('never borrows a live service from another booking', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        booking: _confirmed,
        activeService: _liveService,
      );

      expect(find.text('Track service'), findsNothing);
      expect(find.text('Quality Check'), findsNothing);
    });
  });

  group('CustomerBookingDetail approval', () {
    testWidgets('routes a booking that needs approval into the flow', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _approvalRequired);

      expect(find.text('Action required'), findsOneWidget);
      expect(find.text('Estimate AED 1,250 awaiting approval'), findsOneWidget);

      await tester.tap(find.text('Review estimate'));
      await tester.pumpAndSettle();
      expect(find.text('APPROVALS estimateId=EST-9001'), findsOneWidget);
    });

    testWidgets('recognises a real pending approval for the booking', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        booking: _withEstimate,
        approvals: const [
          CustomerApprovalSummaryResponse(estimateId: 'EST-9001', amount: 1250),
        ],
      );

      expect(find.text('Action required'), findsOneWidget);
    });

    testWidgets('never claims approval is needed without evidence', (
      tester,
    ) async {
      // Same booking data, but nothing pending in the approvals feed.
      await _pumpDetail(tester, booking: _withEstimate);

      expect(find.text('Action required'), findsNothing);
      expect(find.text('Review estimate'), findsNothing);
    });
  });

  group('CustomerBookingDetail layout', () {
    testWidgets('stays overflow-free on the smallest supported phone', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _verbose, size: const Size(320, 640));

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives an increased text scale', (tester) async {
      await _pumpDetail(
        tester,
        booking: _verbose,
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders long service, vehicle and reference safely', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _verbose);

      expect(
        find.text(
          'Comprehensive Annual Service, Wheel Alignment and Air Conditioning '
          'System Inspection',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Mercedes-Benz GLE 450 4MATIC AMG Line'),
        findsOneWidget,
      );
      expect(
        find.text('BOOKING-REFERENCE-2026-0000-LONG-IDENTIFIER-99441'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses two coherent columns on a wide layout', (tester) async {
      await _pumpDetail(
        tester,
        booking: _withVehicle,
        vehicles: const [_vehicle],
        size: const Size(1440, 900),
      );

      // The record and the vehicle sit side by side instead of one narrow
      // phone column floating in the middle of the screen.
      final record = tester.getRect(find.byType(CustomerBookingDetailSummary));
      final vehicle = tester.getRect(find.byType(CustomerBookingDetailVehicle));
      expect(vehicle.left, greaterThan(record.right - 1));
      expect(record.width, greaterThan(300));
      expect(vehicle.width, greaterThan(200));
      expect(record.right, lessThan(1440));
    });

    testWidgets('stacks the columns on a phone', (tester) async {
      await _pumpDetail(
        tester,
        booking: _withVehicle,
        vehicles: const [_vehicle],
        size: const Size(390, 844),
      );

      final record = tester.getRect(find.byType(CustomerBookingDetailSummary));
      final vehicle = tester.getRect(find.byType(CustomerBookingDetailVehicle));
      expect(vehicle.top, greaterThan(record.bottom - 1));
    });

    testWidgets('renders in dark theme without exceptions', (tester) async {
      await _pumpDetail(
        tester,
        booking: _inService,
        activeService: _liveService,
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Quality Check'), findsOneWidget);
    });
  });

  group('CustomerBookingDetail vehicle enrichment', () {
    testWidgets('adds real vehicle details from the matched garage record', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        booking: _withVehicle,
        vehicles: const [_vehicle],
      );

      expect(find.byType(CustomerBookingDetailVehicle), findsOneWidget);
      expect(find.text('Vehicle'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser'), findsWidgets);
      expect(find.text('2021 \u00b7 White \u00b7 48,200 km'), findsOneWidget);
    });

    testWidgets('never borrows another vehicle', (tester) async {
      await _pumpDetail(
        tester,
        booking: _withVehicle,
        vehicles: const [
          CustomerVehicleEntity(
            id: 'v2',
            brand: 'Honda',
            model: 'Civic',
            plateNumber: 'B 99999',
            vin: '',
            color: 'Blue',
            year: 2019,
            mileage: '71,000 km',
            lastService: '',
            nextDue: '',
            healthScore: 70,
          ),
        ],
      );

      expect(find.byType(CustomerBookingDetailVehicle), findsNothing);
      expect(find.textContaining('Honda'), findsNothing);
      expect(find.textContaining('71,000 km'), findsNothing);
    });

    testWidgets('omits the surface when the vehicle adds nothing new', (
      tester,
    ) async {
      // Same plate, but no year, colour or mileage to add.
      await _pumpDetail(
        tester,
        booking: _withVehicle,
        vehicles: const [
          CustomerVehicleEntity(
            id: 'v3',
            brand: 'Toyota',
            model: 'Land Cruiser',
            plateNumber: 'A12345',
            vin: '',
            color: '',
            year: 0,
            mileage: '',
            lastService: '',
            nextDue: '',
            healthScore: 0,
          ),
        ],
      );

      expect(find.byType(CustomerBookingDetailVehicle), findsNothing);
    });
  });

  group('CustomerBookingRelations', () {
    test('matches a vehicle only on a stable plate identifier', () {
      expect(
        CustomerBookingRelations.vehicleFor(_withVehicle, const [_vehicle]),
        same(_vehicle),
      );
      // Formatting differences are still the same plateâ€¦
      expect(
        CustomerBookingRelations.vehicleFor(
          const CustomerBookingEntity(
            id: 'x',
            service: 'Brake Inspection',
            vehicleName: 'Toyota Land Cruiser',
            plateNumber: 'a-12345',
            date: '22 Sep 2026',
            time: '09:00 AM',
            status: BookingStatus.confirmed,
          ),
          const [_vehicle],
        ),
        same(_vehicle),
      );
      // â€¦but a different plate is never treated as the same car.
      expect(
        CustomerBookingRelations.vehicleFor(
          const CustomerBookingEntity(
            id: 'y',
            service: 'Brake Inspection',
            vehicleName: 'Toyota Land Cruiser',
            plateNumber: 'B 99999',
            date: '22 Sep 2026',
            time: '09:00 AM',
            status: BookingStatus.confirmed,
          ),
          const [_vehicle],
        ),
        isNull,
      );
      // No plate means no reliable match at all.
      expect(
        CustomerBookingRelations.vehicleFor(
          const CustomerBookingEntity(
            id: 'z',
            service: 'Brake Inspection',
            vehicleName: 'Toyota Land Cruiser',
            plateNumber: '',
            date: '22 Sep 2026',
            time: '09:00 AM',
            status: BookingStatus.confirmed,
          ),
          const [_vehicle],
        ),
        isNull,
      );
    });

    test('attaches only a genuinely pending estimate approval', () {
      const pending = CustomerApprovalSummaryResponse(
        estimateId: 'EST-9001',
        amount: 1250,
      );

      expect(
        CustomerBookingRelations.approvalFor(_withEstimate, const [pending]),
        same(pending),
      );
      expect(
        CustomerBookingRelations.approvalFor(_confirmed, const [pending]),
        isNull,
      );
      expect(CustomerBookingRelations.needsApproval(_confirmed, null), isFalse);
      expect(
        CustomerBookingRelations.needsApproval(_approvalRequired, null),
        isTrue,
        reason: 'the booking status alone can require a decision',
      );
      expect(
        CustomerBookingRelations.estimateAmount(_confirmed, pending),
        1250,
      );
      expect(CustomerBookingRelations.estimateAmount(_confirmed, null), isNull);
    });
  });

  group('CustomerBookingDetail navigation', () {
    testWidgets('back returns to where the customer came from', (tester) async {
      await _pumpDetail(tester, booking: _confirmed, entry: true);
      await tester.tap(find.text('OPEN_DETAIL'));
      await tester.pumpAndSettle();

      expect(find.text('Booking Details'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('OPEN_DETAIL'), findsOneWidget);
      expect(find.text('Booking Details'), findsNothing);
    });
  });

  group('CustomerBookingDetail visual references', () {
    testWidgets('upcoming mobile', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_upcoming_mobile.png',
        booking: _withEstimate,
        vehicles: const [_vehicle],
      );
    });

    testWidgets('in service mobile', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_in_service_mobile.png',
        booking: _inService,
        activeService: _liveService,
        vehicles: const [_vehicle],
        approvals: const [
          CustomerApprovalSummaryResponse(estimateId: 'EST-9001', amount: 1250),
        ],
      );
    });

    testWidgets('cancelled mobile', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_cancelled_mobile.png',
        booking: _cancelled,
        vehicles: const [_vehicle],
      );
    });

    testWidgets('completed mobile', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_completed_mobile.png',
        booking: _completed,
        vehicles: const [_vehicle],
      );
    });

    testWidgets('tablet composition', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_tablet.png',
        booking: _withVehicle,
        vehicles: const [_vehicle],
        size: const Size(1024, 900),
      );
    });

    testWidgets('approval required mobile', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_approval_mobile.png',
        booking: _approvalRequired,
        vehicles: const [_vehicle],
      );
    });

    testWidgets('cancellation confirmation mobile', (tester) async {
      await _pumpDetail(tester, booking: _confirmed);

      final action = find.text('Cancel booking');
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      await tester.tap(action);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/customer_booking_detail_confirm_mobile.png'),
      );
    });

    testWidgets('dark mode mobile', (tester) async {
      await _expectDetailGolden(
        tester,
        fileName: 'goldens/customer_booking_detail_dark_mobile.png',
        booking: _inService,
        activeService: _liveService,
        vehicles: const [_vehicle],
        theme: AppTheme.dark(BrandConfig.orient),
      );
    });
  });
}

// ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ Fixtures (real entity shapes only) ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬

const _confirmed = CustomerBookingEntity(
  id: 'b-near',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

const _withEstimate = CustomerBookingEntity(
  id: 'b-near',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
  estimateId: 'EST-9001',
  estimateAmount: 1250,
);

const _pending = CustomerBookingEntity(
  id: 'b-pending',
  service: 'Wheel Alignment',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '25 Sep 2026',
  time: '08:30 AM',
  status: BookingStatus.pending,
);

const _delivered = CustomerBookingEntity(
  id: 'b-delivered',
  service: 'Battery Check',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '11 Aug 2026',
  time: '03:30 PM',
  status: BookingStatus.delivered,
  jobCardRef: 'JC-2026-0980',
);

const _approvalRequired = CustomerBookingEntity(
  id: 'b-approval',
  service: 'Suspension Repair',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '15 Sep 2026',
  time: '10:00 AM',
  status: BookingStatus.approvalRequired,
  estimateId: 'EST-9001',
  estimateAmount: 1250,
);

const _inService = CustomerBookingEntity(
  id: 'b-service',
  service: 'Full Service',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '14 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.inProgress,
  jobCardId: 'JC-2026-1042',
  jobCardRef: 'JC-2026-1042',
);

const _completed = CustomerBookingEntity(
  id: 'b-old',
  service: 'Oil & Filter Change',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2 Jun 2026',
  time: '11:00 AM',
  status: BookingStatus.completed,
  jobCardRef: 'JC-2026-0900',
);

const _cancelled = CustomerBookingEntity(
  id: 'b-cancelled',
  service: 'Air Conditioning Regas',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '10 May 2026',
  time: '01:00 PM',
  status: BookingStatus.cancelled,
);

const _verbose = CustomerBookingEntity(
  id: 'b-verbose',
  service:
      'Comprehensive Annual Service, Wheel Alignment and Air Conditioning '
      'System Inspection',
  vehicleName: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  date: '20 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BOOKING-REFERENCE-2026-0000-LONG-IDENTIFIER-99441',
);

const _vehicle = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Land Cruiser',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '2026-01-12',
  nextDue: '2026-07-12',
  healthScore: 82,
);

const _withVehicle = CustomerBookingEntity(
  id: 'b-near',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Land Cruiser',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  currentStage: 'quality_check',
  technicianName: 'Ravi',
  stages: [],
);

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;

  @override
  CustomerDashboardState build() => _initial;
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required CustomerBookingEntity booking,
  CustomerServiceEntity? activeService,
  List<CustomerApprovalSummaryResponse> approvals = const [],
  List<CustomerVehicleEntity> vehicles = const [],
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool entry = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: entry ? '/' : '/detail',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, __) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/detail'),
              child: const Text('OPEN_DETAIL'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/detail',
        builder: (_, __) => CustomerBookingDetailView(booking: booking),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (context, state) => Scaffold(
          body: Text(
            'DASHBOARD_${state.uri.queryParameters['tab']}'
            '_${state.uri.queryParameters['estimateId']}',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerServiceStatus,
        builder: (_, __) => const Scaffold(body: Text('SERVICE_STATUS')),
      ),
      GoRoute(
        path: AppRoutes.customerApprovals,
        builder: (context, state) => Scaffold(
          body: Text(
            'APPROVALS estimateId='
            '${state.uri.queryParameters['estimateId'] ?? 'none'}',
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            CustomerDashboardState(
              selectedIndex: 0,
              isLoading: false,
              selectedVehicle: '',
              selectedServiceType: '',
              bookingNotes: '',
              vehicles: vehicles,
              notifications: const [],
              activeService: activeService,
            ),
          ),
        ),
        customerBookingsProvider.overrideWith((ref) async => [booking]),
        customerApprovalsProvider.overrideWith((ref) async => approvals),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expectDetailGolden(
  WidgetTester tester, {
  required String fileName,
  required CustomerBookingEntity booking,
  CustomerServiceEntity? activeService,
  List<CustomerApprovalSummaryResponse> approvals = const [],
  List<CustomerVehicleEntity> vehicles = const [],
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  await _pumpDetail(
    tester,
    booking: booking,
    activeService: activeService,
    approvals: approvals,
    vehicles: vehicles,
    size: size,
    theme: theme,
  );
  await expectLater(
    find.byType(CustomerBookingDetailView),
    matchesGoldenFile(fileName),
  );
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
