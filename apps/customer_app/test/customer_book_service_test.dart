import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_book_service_view.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/vehicle_booking_decision.dart';

/// Creating a booking is one flow: which vehicle, which real service, which real
/// slot, a review of exactly what will be sent, and the result.
void main() {
  setUpAll(_loadFonts);

  group('Booking flow — vehicle', () {
    testWidgets('offers adding a vehicle when the garage is empty', (
      tester,
    ) async {
      await _pumpFlow(tester, vehicles: const []);

      expect(find.text('No vehicle yet'), findsOneWidget);
      expect(find.text('Add your vehicle'), findsOneWidget);
      // The flow cannot move on without a vehicle.
      expect(_continueEnabled(tester), isFalse);

      await tester.tap(find.text('Add your vehicle'));
      await tester.pumpAndSettle();
      expect(find.text('ADD_VEHICLE'), findsOneWidget);
    });

    testWidgets('selects the only vehicle without making the customer tap', (
      tester,
    ) async {
      await _pumpFlow(tester, vehicles: const [_camry]);

      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('A 12345'), findsWidgets);
      expect(_continueEnabled(tester), isTrue);
      // The selected vehicle is announced as selected.
      expect(
        tester
            .getSemantics(find.text('Toyota Camry').first)
            .flagsCollection
            .isSelected,
        isTrue,
      );
    });

    testWidgets('selects a vehicle added during the flow', (tester) async {
      final vehicles = <CustomerVehicleEntity>[];
      await _pumpFlow(tester, vehicles: vehicles);
      expect(find.text('No vehicle yet'), findsOneWidget);

      vehicles.add(_camry);
      await tester.tap(find.text('Add your vehicle'));
      await tester.pumpAndSettle();
      expect(find.text('ADD_VEHICLE'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // The freshly added vehicle is selected without another tap.
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('asks which of several vehicles is being booked', (
      tester,
    ) async {
      await _pumpFlow(tester, vehicles: const [_camry, _patrol]);

      // No silent default when there is a real choice.
      expect(_continueEnabled(tester), isFalse);
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('Nissan Patrol'), findsWidgets);

      await tester.tap(find.text('Nissan Patrol').first);
      await tester.pumpAndSettle();

      expect(_continueEnabled(tester), isTrue);
      expect(find.text('A 99999'), findsWidgets);
    });
  });

  group('Booking flow — service', () {
    testWidgets('lists the workshop catalogue with its real price and time', (
      tester,
    ) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _next(tester);

      expect(find.text('Full Service'), findsOneWidget);
      expect(find.text('AED 450 \u00b7 90 min'), findsOneWidget);
      expect(find.text('Brake Inspection'), findsOneWidget);
      // A service without a price stays without one.
      expect(find.text('Wheel Alignment'), findsOneWidget);
      expect(find.textContaining('Price on inspection'), findsNothing);

      await tester.tap(find.text('Brake Inspection'));
      await tester.pumpAndSettle();
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('offers a retry that really refetches the catalogue', (
      tester,
    ) async {
      final remote = _FakeRemote(servicesFail: true, services: const []);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _next(tester);

      expect(find.text('Retry services'), findsOneWidget);
      expect(remote.servicesCalls, 1);

      await tester.tap(find.text('Retry services'));
      await tester.pumpAndSettle();
      expect(remote.servicesCalls, 2);
    });

    testWidgets('shows a loading state while the catalogue arrives', (
      tester,
    ) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        servicesPending: true,
        settle: false,
      );
      await tester.pump();
      await _next(tester, settle: false);
      await tester.pump();

      expect(find.text('Full Service'), findsNothing);
      expect(find.text('Retry services'), findsNothing);
      // A real placeholder is shown, not a blank section.
      expect(find.byType(CustomerSkeleton), findsOneWidget);
    });
  });

  group('Booking flow — schedule', () {
    testWidgets('uses the workshop’s real availability for the chosen date', (
      tester,
    ) async {
      final remote = _FakeRemote(availability: const ['09:00', '11:00']);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);

      expect(find.textContaining('Choose a date'), findsWidgets);
      await _pickFirstDate(tester);

      expect(remote.availabilityDates, hasLength(1));
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('11:00 AM'), findsOneWidget);

      await tester.tap(find.text('11:00 AM'));
      await tester.pumpAndSettle();
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('states plainly when a date has no times left', (tester) async {
      final remote = _FakeRemote(availability: const []);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);
      await _pickFirstDate(tester);

      expect(
        find.text('No times available on this date. Choose another date.'),
        findsOneWidget,
      );
      expect(_continueEnabled(tester), isFalse);
    });

    testWidgets('keeps the date and offers a retry that refetches times', (
      tester,
    ) async {
      final remote = _FakeRemote(availabilityFails: true);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);
      await _pickFirstDate(tester);

      expect(find.text('Retry times'), findsOneWidget);
      expect(remote.availabilityCalls, 1);

      await tester.tap(find.text('Retry times'));
      await tester.pumpAndSettle();
      expect(remote.availabilityCalls, 2);
      // The chosen date is still the one being retried.
      expect(remote.availabilityDates.first, remote.availabilityDates.last);
    });

    testWidgets('shows a loading state while times are being fetched', (
      tester,
    ) async {
      final remote = _FakeRemote(availabilityPending: true);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);

      await tester.tap(
        find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(InkWell),
            )
            .at(1),
      );
      await tester.pump();

      expect(find.byType(CustomerSkeleton), findsWidgets);
      expect(find.text('9:00 AM'), findsNothing);
    });

    testWidgets('hides today’s slots that have already passed', (tester) async {
      // Midnight and 23:59 on today's date: at most one of them is still
      // bookable, and the flow must not offer a slot in the past.
      final remote = _FakeRemote(availability: const ['00:00', '23:59']);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);

      await tester.tap(
        find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();

      expect(find.text('12:00 AM'), findsNothing);
    });
  });

  group('Booking flow — review and submission', () {
    testWidgets('reviews exactly what will be sent and can change it', (
      tester,
    ) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      expect(find.text('YOUR VEHICLE'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('SERVICE'), findsOneWidget);
      expect(find.text('Full Service'), findsWidgets);
      expect(find.text('APPOINTMENT'), findsOneWidget);
      expect(find.textContaining('9:00 AM'), findsWidgets);
      expect(find.text('Confirm booking'), findsOneWidget);

      // Every decision can be changed without restarting the flow.
      await tester.tap(find.text('Change').first);
      await tester.pumpAndSettle();
      expect(find.text('Which vehicle?'), findsOneWidget);
    });

    testWidgets('creates the booking and carries the result forward', (
      tester,
    ) async {
      final remote = _FakeRemote(createdId: '77', createdRef: 'BK-2026-0042');
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      // The real API contract: exactly the documented CreateBookingRequest
      // fields — an extra key makes the backend reject the booking.
      expect(remote.createdPayloads, hasLength(1));
      final payload = remote.createdPayloads.single;
      expect(payload.keys.toSet(), {
        'vehicleId',
        'vehicleName',
        'plateNumber',
        'serviceType',
        'bookingDate',
        'bookingTime',
        'notes',
      }, reason: 'unknown properties are rejected by the API');
      expect(payload['vehicleId'], 'v1');
      expect(payload['vehicleName'], 'Toyota Camry');
      expect(payload['plateNumber'], 'A 12345');
      expect(payload['serviceType'], 'Full Service');
      expect(payload['bookingDate'], matches(r'^\d{4}-\d{2}-\d{2}T09:00:00$'));
      expect(payload['bookingTime'], '09:00');

      // The result travels with the returned reference, never a guessed one.
      expect(
        find.text('SUCCESS ref=BK-2026-0042 id=77 queued=false feed=0'),
        findsOneWidget,
      );
    });

    testWidgets('cannot create the same booking twice', (tester) async {
      final remote = _FakeRemote(
        createdRef: 'BK-2026-0043',
        createPending: true,
      );
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pump();
      expect(find.text('Booking…'), findsOneWidget);
      await tester.tap(find.text('Booking…'), warnIfMissed: false);
      await tester.pump();
      expect(remote.createdPayloads, hasLength(1));

      remote.completeCreate('77');
      await tester.pumpAndSettle();
      expect(remote.createdPayloads, hasLength(1));
    });

    testWidgets('keeps every selection when creation fails', (tester) async {
      final remote = _FakeRemote(createFails: true);
      await _pumpFlow(tester, vehicles: const [_camry], remote: remote);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      // The workshop's own reason is shown; nothing is swallowed.
      expect(find.text('The workshop rejected this booking.'), findsOneWidget);
      // Still on the review, with nothing lost.
      expect(find.text('Confirm booking'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('Full Service'), findsWidgets);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('refreshes Bookings and Home after creating one', (
      tester,
    ) async {
      final probe = _FlowProbe();
      final remote = _FakeRemote(createdRef: 'BK-2026-0044');
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        remote: remote,
        probe: probe,
      );
      final loadsBefore = probe.bookingsLoads;

      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);
      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      // The new booking must be visible without restarting the app: the
      // Bookings feed is re-read and Home is asked to refresh.
      expect(probe.bookingsLoads, greaterThan(loadsBefore));
      expect(probe.dashboardRefreshes, greaterThan(0));
    });

    testWidgets('lets the customer change the service from the review', (
      tester,
    ) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      // The service section owns the second Change action.
      await tester.tap(find.text('Change').at(1));
      await tester.pumpAndSettle();
      expect(find.text('What service?'), findsOneWidget);

      await tester.tap(find.text('Brake Inspection'));
      await tester.pumpAndSettle();
      await _next(tester);
      expect(find.text('Brake Inspection'), findsWidgets);
    });

    testWidgets('a booking made offline is queued, not lost', (tester) async {
      final probe = _FlowProbe();
      final remote = _FakeRemote(createOffline: true);
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        remote: remote,
        probe: probe,
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(find.textContaining('queued=true'), findsOneWidget);
      expect(find.textContaining('feed='), findsOneWidget);
      // A queued booking is still the customer's booking: the feeds refresh.
      expect(probe.dashboardRefreshes, greaterThan(0));
    });
  });

  group('Booking flow — layout and imagery', () {
    testWidgets('never renders stock vehicle imagery', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry, _patrol]);
      expect(find.byType(Image), findsNothing);

      await tester.tap(find.text('Toyota Camry').first);
      await tester.pumpAndSettle();
      await _selectService(tester);
      expect(find.byType(Image), findsNothing);
      await _pickFirstSlot(tester);
      await _next(tester);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('stays overflow-free on every supported phone width', (
      tester,
    ) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpFlow(
          tester,
          vehicles: const [_camry, _patrol],
          services: _longServices,
          size: Size(width, 844),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'booking flow must not overflow at ${width}px',
        );
      }
    });

    testWidgets('survives large text', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        services: _longServices,
        textScaler: const TextScaler.linear(1.6),
      );
      await _selectService(tester, name: _longServices.first.name);
      await _pickFirstSlot(tester);
      await _next(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Confirm booking'), findsOneWidget);
    });

    testWidgets('keeps the steps and a live summary separate on a tablet', (
      tester,
    ) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        size: const Size(1024, 900),
      );
      await _next(tester);

      final step = tester.getRect(find.text('What service?'));
      final summary = tester.getRect(find.text('Your booking'));
      expect(summary.left, greaterThan(step.left));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Which vehicle?'), findsOneWidget);
    });
  });

  group('Booking flow visual references', () {
    testWidgets('vehicle step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry, _patrol]);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_vehicle_mobile.png'),
      );
    });

    testWidgets('service step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _next(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_service_mobile.png'),
      );
    });

    testWidgets('schedule step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _selectService(tester);
      await _pickFirstDate(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_schedule_mobile.png'),
      );
    });

    testWidgets('review step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_review_mobile.png'),
      );
    });

    testWidgets('tablet composition', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        size: const Size(1024, 900),
      );
      await _selectService(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_tablet.png'),
      );
    });

    testWidgets('dark mode mobile', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_dark_mobile.png'),
      );
    });
  });
  group('Booking a vehicle the workshop has not accepted yet', () {
    testWidgets('online Confirm Booking never calls the booking API', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpFlow(
        tester,
        vehicles: const [_pendingVehicle],
        remote: remote,
        identity: _pendingIdentity,
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(
        remote.createdPayloads,
        isEmpty,
        reason: 'a temporary vehicle id must never be posted',
      );
      expect(find.textContaining("hasn't finished saving"), findsOneWidget);
      // Selections survive, so the customer only has to retry.
      expect(find.text('Confirm booking'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
    });

    testWidgets('a reconciled vehicle is booked with the server id', (
      tester,
    ) async {
      final remote = _FakeRemote(createdRef: 'BK-2026-0044');
      await _pumpFlow(
        tester,
        vehicles: const [_serverVehicle],
        remote: remote,
        identity: _reconciledIdentity,
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(remote.createdPayloads, hasLength(1));
      expect(remote.createdPayloads.single['vehicleId'], '8472');
      expect(remote.createdPayloads.single['vehicleId'], isNot('1723456789'));
      expect(remote.createdPayloads.single.keys.toSet(), {
        'vehicleId',
        'vehicleName',
        'plateNumber',
        'serviceType',
        'bookingDate',
        'bookingTime',
        'notes',
      });
    });
  });

  group('Booking flow — layout and imagery', () {
    testWidgets('never renders stock vehicle imagery', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry, _patrol]);
      expect(find.byType(Image), findsNothing);

      await tester.tap(find.text('Toyota Camry').first);
      await tester.pumpAndSettle();
      await _selectService(tester);
      expect(find.byType(Image), findsNothing);
      await _pickFirstSlot(tester);
      await _next(tester);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('stays overflow-free on every supported phone width', (
      tester,
    ) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpFlow(
          tester,
          vehicles: const [_camry, _patrol],
          services: _longServices,
          size: Size(width, 844),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'booking flow must not overflow at ${width}px',
        );
      }
    });

    testWidgets('survives large text', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        services: _longServices,
        textScaler: const TextScaler.linear(1.6),
      );
      await _selectService(tester, name: _longServices.first.name);
      await _pickFirstSlot(tester);
      await _next(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Confirm booking'), findsOneWidget);
    });

    testWidgets('keeps the steps and a live summary separate on a tablet', (
      tester,
    ) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        size: const Size(1024, 900),
      );
      await _next(tester);

      final step = tester.getRect(find.text('What service?'));
      final summary = tester.getRect(find.text('Your booking'));
      expect(summary.left, greaterThan(step.left));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Which vehicle?'), findsOneWidget);
    });
  });

  group('Booking flow visual references', () {
    testWidgets('vehicle step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry, _patrol]);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_vehicle_mobile.png'),
      );
    });

    testWidgets('service step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _next(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_service_mobile.png'),
      );
    });

    testWidgets('schedule step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _selectService(tester);
      await _pickFirstDate(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_schedule_mobile.png'),
      );
    });

    testWidgets('review step mobile', (tester) async {
      await _pumpFlow(tester, vehicles: const [_camry]);
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_review_mobile.png'),
      );
    });

    testWidgets('tablet composition', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        size: const Size(1024, 900),
      );
      await _selectService(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_tablet.png'),
      );
    });

    testWidgets('dark mode mobile', (tester) async {
      await _pumpFlow(
        tester,
        vehicles: const [_camry],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/customer_book_service_dark_mobile.png'),
      );
    });
  });
  group('Booking a vehicle the workshop has not accepted yet', () {
    testWidgets('online Confirm Booking never calls the booking API', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpFlow(
        tester,
        vehicles: const [_pendingVehicle],
        remote: remote,
        identity: _pendingIdentity,
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(
        remote.createdPayloads,
        isEmpty,
        reason: 'a temporary vehicle id must never be posted',
      );
      expect(find.textContaining("hasn't finished saving"), findsOneWidget);
      // Selections survive, so the customer only has to retry.
      expect(find.text('Confirm booking'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
    });

    testWidgets('a reconciled vehicle is booked with the server id', (
      tester,
    ) async {
      final remote = _FakeRemote(createdRef: 'BK-2026-0044');
      await _pumpFlow(
        tester,
        vehicles: const [_serverVehicle],
        remote: remote,
        identity: _reconciledIdentity,
      );
      await _selectService(tester);
      await _pickFirstSlot(tester);
      await _next(tester);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(remote.createdPayloads, hasLength(1));
      expect(remote.createdPayloads.single['vehicleId'], '8472');
      expect(remote.createdPayloads.single['vehicleId'], isNot('1723456789'));
      expect(remote.createdPayloads.single.keys.toSet(), {
        'vehicleId',
        'vehicleName',
        'plateNumber',
        'serviceType',
        'bookingDate',
        'bookingTime',
        'notes',
      });
    });
  });
}

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _camry = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '2026-01-12',
  nextDue: '2026-07-12',
  healthScore: 82,
);

const _patrol = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'A 99999',
  vin: '',
  color: 'Black',
  year: 2023,
  mileage: '12,000 km',
  lastService: '2026-03-01',
  nextDue: '2026-09-01',
  healthScore: 91,
);

const _services = [
  ServiceTypeResponse(
    id: 's1',
    name: 'Full Service',
    price: 'AED 450',
    duration: '90 min',
  ),
  ServiceTypeResponse(
    id: 's2',
    name: 'Brake Inspection',
    price: 'AED 120',
    duration: '30 min',
  ),
  ServiceTypeResponse(id: 's3', name: 'Wheel Alignment'),
];

const _longServices = [
  ServiceTypeResponse(
    id: 's1',
    name:
        'Comprehensive annual service including engine oil, filters and a full '
        'multi-point inspection',
    price: 'AED 1,450',
    duration: '4 hours',
  ),
  ServiceTypeResponse(id: 's2', name: 'Brake Inspection', price: 'AED 120'),
];

class _FakeRemote implements CustomerRemoteDataSource {
  _FakeRemote({
    this.services = _services,
    this.servicesFail = false,
    this.servicesPending = false,
    this.availability = const ['09:00'],
    this.availabilityPending = false,
    this.availabilityFails = false,
    this.createdId = '1',
    this.createdRef = '',
    this.createFails = false,
    this.createOffline = false,
    this.createPending = false,
  });

  final List<ServiceTypeResponse> services;
  final bool servicesFail;
  final bool servicesPending;
  final bool availabilityPending;
  int servicesCalls = 0;
  int availabilityCalls = 0;
  final List<String> availability;
  final bool availabilityFails;
  final String createdId;
  final String createdRef;
  final bool createFails;
  final bool createOffline;
  final bool createPending;
  final List<String> availabilityDates = [];
  final List<Map<String, dynamic>> createdPayloads = [];
  Completer<IdResponse>? _create;

  @override
  Future<List<ServiceTypeResponse>> getServiceTypes() async {
    servicesCalls++;
    if (servicesPending) {
      await Completer<List<ServiceTypeResponse>>().future;
    }
    if (servicesFail) throw const NetworkException('catalogue unavailable');
    return services;
  }

  @override
  Future<List<String>> getAvailability(String date) async {
    availabilityDates.add(date);
    availabilityCalls++;
    if (availabilityPending) {
      await Completer<List<String>>().future;
    }
    if (availabilityFails) throw Exception('availability unavailable');
    return availability;
  }

  @override
  Future<IdResponse> createBooking(Map<String, dynamic> data) {
    createdPayloads.add(data);
    if (createPending) {
      _create ??= Completer<IdResponse>();
      return _create!.future;
    }
    if (createOffline) {
      throw NetworkException('no connection');
    }
    if (createFails) {
      throw const ValidationException('The workshop rejected this booking.');
    }
    return Future.value(IdResponse(id: createdId, bookingRef: createdRef));
  }

  void completeCreate(String id) =>
      _create!.complete(IdResponse(id: id, bookingRef: 'BK-2026-0043'));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._vehicles, this._probe);

  final List<CustomerVehicleEntity> _vehicles;
  final _FlowProbe _probe;

  @override
  CustomerDashboardState build() => CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: _vehicles,
    notifications: const [],
  );

  @override
  Future<void> refresh() async {
    _probe.dashboardRefreshes++;
  }
}

bool _continueEnabled(WidgetTester tester) {
  final label = find.text('Confirm booking').evaluate().isEmpty
      ? find.text('Continue')
      : find.text('Confirm booking');
  final button = tester.widget<FilledButton>(
    find
        .ancestor(
          of: label,
          matching: find.byWidgetPredicate((widget) => widget is FilledButton),
        )
        .first,
  );
  return button.onPressed != null;
}

Future<void> _next(WidgetTester tester, {bool settle = true}) async {
  await tester.tap(find.text('Continue'));
  if (settle) await tester.pumpAndSettle();
}

Future<void> _selectService(
  WidgetTester tester, {
  String name = 'Full Service',
}) async {
  await _next(tester);
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
  await _next(tester);
}

Future<void> _pickFirstDate(WidgetTester tester) async {
  // Tomorrow, not today: today's morning slots have genuinely passed by the
  // time these tests run, and the flow correctly hides them.
  final date = find
      .descendant(of: find.byType(ListView), matching: find.byType(InkWell))
      .at(1);
  await tester.tap(date);
  await tester.pumpAndSettle();
}

Future<void> _pickFirstSlot(WidgetTester tester) async {
  await _pickFirstDate(tester);
  await tester.tap(find.text('9:00 AM'));
  await tester.pumpAndSettle();
}

class _FlowProbe {
  int bookingsLoads = 0;
  int dashboardRefreshes = 0;
}

Future<void> _pumpFlow(
  WidgetTester tester, {
  _FlowProbe? probe,
  required List<CustomerVehicleEntity> vehicles,
  CustomerRemoteDataSource? remote,
  List<ServiceTypeResponse> services = _services,
  bool servicesFail = false,
  bool servicesPending = false,
  bool availabilityPending = false,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
  VehicleIdentityReader identity = const StoreVehicleIdentityReader(),
  bool offline = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final bookkeeping = probe ?? _FlowProbe();
  final dataSource =
      remote ??
      _FakeRemote(
        services: services,
        servicesFail: servicesFail,
        servicesPending: servicesPending,
        availabilityPending: availabilityPending,
      );

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const CustomerBookServiceView()),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) =>
            Scaffold(appBar: AppBar(title: const Text('ADD_VEHICLE'))),
      ),
      GoRoute(
        path: AppRoutes.customerBookingSuccess,
        // Mirrors the real success screen: it reads the refreshed Bookings feed
        // to resolve the booking that was just created.
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            final feed =
                ref.watch(customerBookingsProvider).valueOrNull ?? const [];
            return Scaffold(
              body: Text(
                'SUCCESS ref=${extra['ref']} id=${extra['id']} '
                'queued=${extra['queued']} feed=${feed.length}',
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (_, __) => const Scaffold(body: Text('HOME')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerRemoteDataSourceProvider.overrideWithValue(dataSource),
        // The device's connectivity provider is plugin-backed; tests state it.
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(
            offline ? ConnectivityResult.none : ConnectivityResult.wifi,
          ),
        ),
        vehicleIdentityReaderProvider.overrideWithValue(identity),
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(vehicles, bookkeeping),
        ),
        customerBookingsProvider.overrideWith((ref) async {
          bookkeeping.bookingsLoads++;
          return const <CustomerBookingEntity>[];
        }),
        customerApprovalsProvider.overrideWith((ref) async => const []),
        customerInvoicesProvider.overrideWith((ref) async => const []),
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
  if (settle) await tester.pumpAndSettle();
}

class _FakeIdentityReader implements VehicleIdentityReader {
  const _FakeIdentityReader({this.mapped, this.pending = false});

  final String? mapped;
  final bool pending;

  @override
  String? serverIdFor(String localId) => mapped;

  @override
  bool isPending(String localId) => pending;

  @override
  bool hasFailedCreate(String localId) => false;
}

const _pendingIdentity = _FakeIdentityReader(pending: true);
const _reconciledIdentity = _FakeIdentityReader(mapped: '8472');

const _pendingVehicle = CustomerVehicleEntity(
  id: '1723456789',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _serverVehicle = CustomerVehicleEntity(
  id: '8472',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);
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
