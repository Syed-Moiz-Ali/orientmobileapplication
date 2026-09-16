import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_item.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';

void main() {
  setUpAll(_loadFonts);

  group('CustomerBookingsPresentation', () {
    test('groups real statuses into lifecycle buckets', () {
      expect(
        CustomerBookingsPresentation.groupOf(BookingStatus.pending),
        CustomerBookingGroup.upcoming,
      );
      expect(
        CustomerBookingsPresentation.groupOf(BookingStatus.confirmed),
        CustomerBookingGroup.upcoming,
      );
      for (final status in CustomerBookingsPresentation.inWorkshopStatuses) {
        expect(
          CustomerBookingsPresentation.groupOf(status),
          CustomerBookingGroup.inService,
          reason: '$status is a workshop state',
        );
      }
      for (final status in [
        BookingStatus.completed,
        BookingStatus.delivered,
        BookingStatus.cancelled,
      ]) {
        expect(
          CustomerBookingsPresentation.groupOf(status),
          CustomerBookingGroup.history,
          reason: '$status is a finished lifecycle entry',
        );
      }
    });

    test('orders upcoming soonest first and history newest first', () {
      final ordered = CustomerBookingsPresentation.sortByUpcoming(const [
        _later,
        _nearer,
      ]);
      expect(ordered.map((b) => b.id).toList(), ['b-near', 'b-later']);

      final recent = CustomerBookingsPresentation.sortByRecent(const [
        _olderCompleted,
        _newerCompleted,
      ]);
      expect(recent.map((b) => b.id).toList(), ['b-new', 'b-old']);
    });

    test('keeps unreadable dates in their incoming order', () {
      final ordered = CustomerBookingsPresentation.sortByUpcoming(const [
        _unreadable,
        _later,
      ]);
      expect(ordered.map((b) => b.id).toList(), ['b-later', 'b-unreadable']);
    });

    test('formats real dates and times, degrading to raw values', () {
      expect(
        CustomerBookingsPresentation.dateLabel('2026-09-22'),
        'Tue, 22 Sep 2026',
      );
      expect(CustomerBookingsPresentation.timeLabel('09:00'), '9:00 AM');
      expect(CustomerBookingsPresentation.timeLabel('14:30'), '2:30 PM');
      expect(CustomerBookingsPresentation.timeLabel('10:30 AM'), '10:30 AM');
      expect(
        CustomerBookingsPresentation.scheduleLabel('2026-09-22', '09:00'),
        'Tue, 22 Sep 2026 \u00b7 9:00 AM',
      );
      // Unreadable values are shown as sent, never invented.
      expect(
        CustomerBookingsPresentation.dateLabel('next Tuesday'),
        'next Tuesday',
      );
      expect(CustomerBookingsPresentation.timeLabel('morning'), 'morning');
      expect(CustomerBookingsPresentation.scheduleLabel('', ''), '');
    });

    test('reads every date shape this product actually exchanges', () {
      // The booking API formats the appointment as `d MMM yyyy` + `hh:mm a`
      // (BookingService.toResponse), so that pair must always be readable.
      expect(
        CustomerBookingsPresentation.dateLabel('22 Sep 2026'),
        'Tue, 22 Sep 2026',
      );
      expect(CustomerBookingsPresentation.dayOfMonthLabel('22 Sep 2026'), '22');
      expect(CustomerBookingsPresentation.monthLabel('22 Sep 2026'), 'SEP');
      expect(
        CustomerBookingsPresentation.scheduleLabel('22 Sep 2026', '09:00 AM'),
        'Tue, 22 Sep 2026 \u00b7 9:00 AM',
      );
      // Single-digit days are not padded by the backend.
      expect(
        CustomerBookingsPresentation.dateLabel('2 Oct 2026'),
        'Fri, 2 Oct 2026',
      );
      // The booking flow writes day-first dates itself.
      expect(
        CustomerBookingsPresentation.dateLabel('22/09/2026'),
        'Tue, 22 Sep 2026',
      );
      expect(CustomerBookingsPresentation.dayOfMonthLabel('22/09/2026'), '22');
      expect(CustomerBookingsPresentation.monthLabel('22/09/2026'), 'SEP');
      // Tolerated variants.
      expect(
        CustomerBookingsPresentation.dateLabel('2/9/2026'),
        'Wed, 2 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('22-09-2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('22.09.2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('2026/09/22'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('2026-09-22T09:00:00'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('2026-09-22T09:00:00.000Z'),
        'Tue, 22 Sep 2026',
      );
      // A second component that cannot be a month is read month-first.
      expect(
        CustomerBookingsPresentation.dateLabel('09/22/2026'),
        'Tue, 22 Sep 2026',
      );
      // Formatted dates a backend may return instead of a machine format.
      expect(
        CustomerBookingsPresentation.dateLabel('Tue, 22 Sep 2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('22 Sep 2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('22 September 2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('22-Sep-2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('Sep 22, 2026'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('Tuesday, 22 Sep 2026'),
        'Tue, 22 Sep 2026',
      );
      // Machine formats: compact and epoch timestamps.
      expect(
        CustomerBookingsPresentation.dateLabel('20260922'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('1790035200'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('1790035200000'),
        'Tue, 22 Sep 2026',
      );
      // The date is found even when the backend wraps it.
      expect(
        CustomerBookingsPresentation.dateLabel('22/09/2026 at 09:00'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('Tue, 22 Sep 2026 09:00'),
        'Tue, 22 Sep 2026',
      );
      expect(
        CustomerBookingsPresentation.dateLabel('Scheduled for 22/09/2026'),
        'Tue, 22 Sep 2026',
      );
      // Impossible and unreadable values stay unread rather than guessed.
      expect(
        CustomerBookingsPresentation.parseDateTime('31/02/2026', ''),
        isNull,
      );
      expect(
        CustomerBookingsPresentation.parseDateTime('next Tuesday', ''),
        isNull,
      );
      expect(
        CustomerBookingsPresentation.parseDateTime('Foo 22 2026', ''),
        isNull,
      );
      expect(CustomerBookingsPresentation.parseDateTime('', ''), isNull);
    });

    test('compares one booking seen from two sources by identity', () {
      // The workshop sends d MMM yyyy; the device cache stores the submitted
      // ISO value. The same booking must not be listed twice.
      final fromApi = CustomerBookingsPresentation.identityKey(
        vehicleName: 'Toyota Land Cruiser',
        plateNumber: 'A 12345',
        date: '22 Sep 2026',
      );
      final fromCache = CustomerBookingsPresentation.identityKey(
        vehicleName: 'Toyota Land Cruiser',
        plateNumber: 'a-12345',
        date: '2026-09-22T09:00:00',
      );
      expect(fromApi, fromCache);
      expect(
        CustomerBookingsPresentation.identityKey(
          vehicleName: 'Toyota Land Cruiser',
          plateNumber: 'A 12345',
          date: '23 Sep 2026',
        ),
        isNot(fromApi),
      );
      expect(
        CustomerBookingsPresentation.identityKey(
          vehicleName: 'Toyota Land Cruiser',
          plateNumber: 'B 99999',
          date: '22 Sep 2026',
        ),
        isNot(fromApi),
      );
    });

    test('reads a slot as minutes since midnight', () {
      expect(CustomerBookingsPresentation.minutesOfDay('09:00'), 540);
      expect(CustomerBookingsPresentation.minutesOfDay('9:00 AM'), 540);
      expect(CustomerBookingsPresentation.minutesOfDay('2:30 PM'), 870);
      expect(CustomerBookingsPresentation.minutesOfDay('17:00'), 1020);
      expect(CustomerBookingsPresentation.minutesOfDay('morning'), isNull);
      expect(CustomerBookingsPresentation.minutesOfDay(''), isNull);
    });

    test('knows when a time can be shown as a clock time', () {
      expect(CustomerBookingsPresentation.isReadableTime('09:00'), isTrue);
      expect(CustomerBookingsPresentation.isReadableTime('9:00 AM'), isTrue);
      expect(CustomerBookingsPresentation.isReadableTime('14:00:00'), isTrue);
      expect(CustomerBookingsPresentation.isReadableTime('morning'), isFalse);
      expect(CustomerBookingsPresentation.isReadableTime(''), isFalse);
    });

    test('orders day-first dates correctly', () {
      final ordered = CustomerBookingsPresentation.sortByUpcoming(const [
        _later,
        _nearer,
      ]);
      expect(ordered.map((b) => b.id).toList(), ['b-near', 'b-later']);
    });

    test('prefers the public booking reference over internal identifiers', () {
      // The backend exposes `bookingRef` (`BK-…`) as the public identifier.
      expect(
        CustomerBookingsPresentation.referenceOf(_withReferences),
        'BK-2026-0188',
      );
      // A job card reference is the next best customer-facing value.
      expect(
        CustomerBookingsPresentation.referenceOf(_inService),
        'JC-2026-1042',
      );
      // An internal job card id is never shown as a reference.
      expect(
        CustomerBookingsPresentation.referenceOf(_internalIdOnly),
        '',
        reason: 'database ids must not leak into the UI',
      );
      expect(CustomerBookingsPresentation.referenceOf(_later), '');
    });

    test('bookings is the second permanent workspace destination', () {
      expect(
        CustomerDestination.navItems[CustomerDestination.bookings.index].label,
        'Bookings',
      );
      expect(
        AppRoutes.bookingsLocation,
        '${AppRoutes.customerDashboard}?tab=bookings',
      );
    });
  });

  group('CustomerBookingsTab states', () {
    testWidgets('shows a bookings-shaped skeleton on first load', (
      tester,
    ) async {
      await _pumpBookings(
        tester,
        bookings: const [],
        pendingBookings: true,
        settle: false,
      );
      await tester.pump();

      expect(find.byType(CustomerBookingsSkeleton), findsOneWidget);
    });

    testWidgets('offers a retry when nothing could be loaded', (tester) async {
      final notifier = await _pumpBookings(
        tester,
        bookings: const [],
        loadError: 'unavailable',
      );

      expect(find.text("We couldn't load your bookings"), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(notifier.refreshCount, 1);
    });

    testWidgets('offers book service for a customer with vehicles', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const []);

      expect(find.text('No bookings yet'), findsOneWidget);
      expect(find.text('Book service'), findsOneWidget);
      expect(find.text('Add your vehicle'), findsNothing);

      await tester.tap(find.text('Book service'));
      await tester.pumpAndSettle();
      expect(find.text('BOOK_SERVICE'), findsOneWidget);
    });

    testWidgets('prioritises adding a vehicle when there are none', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [], vehicles: const []);

      expect(find.text('No vehicle yet'), findsOneWidget);
      expect(find.text('Add your vehicle'), findsOneWidget);
      expect(find.text('Book service'), findsNothing);

      await tester.tap(find.text('Add your vehicle'));
      await tester.pumpAndSettle();
      expect(find.text('ADD_VEHICLE'), findsOneWidget);
    });
  });

  group('CustomerBookingsTab rows', () {
    testWidgets('summarises an upcoming appointment without fake content', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_withReferences]);

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Brake Inspection'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      expect(find.text('BK-2026-0188'), findsOneWidget);
      expect(find.text('1 upcoming'), findsOneWidget);

      // Removed fabricated/demo presentation must never come back.
      expect(find.text('Quick Reserve'), findsNothing);
      expect(find.text('Next Express Slot'), findsNothing);
      expect(find.text('UP NEXT'), findsNothing);
      expect(find.textContaining('AED 89'), findsNothing);
      expect(find.textContaining('mins'), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('anchors every appointment with a scannable date block', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_nearer, _later]);

      // Day, month and time are their own block, not buried in metadata.
      expect(find.text('22'), findsOneWidget);
      expect(find.text('SEP'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('OCT'), findsOneWidget);
      expect(find.text('2:00 PM'), findsOneWidget);

      // Soonest appointment is listed first.
      expect(
        tester.getTopLeft(find.text('SEP')).dy,
        lessThan(tester.getTopLeft(find.text('OCT')).dy),
      );
    });

    testWidgets('degrades to the raw schedule when a date is unreadable', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_unreadable]);

      // Nothing is invented: the backend's own values are shown instead.
      expect(find.text('next Tuesday \u00b7 morning'), findsOneWidget);
      expect(find.text('Wheel Alignment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('orders multiple upcoming appointments by nearest date', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_later, _nearer]);

      expect(find.text('2 upcoming'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Brake Inspection')).dy,
        lessThan(tester.getTopLeft(find.text('Tyre Rotation')).dy),
      );
    });

    testWidgets('keeps history separate and newest first', (tester) async {
      await _pumpBookings(
        tester,
        bookings: const [_nearer, _olderCompleted, _newerCompleted],
      );

      expect(find.text('History'), findsOneWidget);
      expect(find.textContaining('2 past services'), findsOneWidget);
      final completedNew = tester.getTopLeft(find.text('Battery Check')).dy;
      final completedOld = tester
          .getTopLeft(find.text('Oil & Filter Change'))
          .dy;
      expect(completedNew, lessThan(completedOld));
    });

    testWidgets('represents cancelled work as inactive, not positive', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_cancelled]);

      expect(find.text('History'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
      final pill = tester.widget<StatusPill>(
        find.ancestor(
          of: find.text('CANCELLED'),
          matching: find.byType(StatusPill),
        ),
      );
      final theme = AppTheme.light(BrandConfig.orient);
      expect(pill.fg, theme.colorScheme.onSurfaceVariant);
      expect(pill.fg, isNot(theme.colorScheme.tertiary));
    });

    testWidgets('separates upcoming, in-service and history correctly', (
      tester,
    ) async {
      await _pumpBookings(
        tester,
        bookings: const [_inService, _nearer, _olderCompleted, _cancelled],
        activeService: _liveService,
      );

      expect(find.text('Upcoming & in service'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      final activeHeader = tester
          .getTopLeft(find.text('Upcoming & in service'))
          .dy;
      final historyHeader = tester.getTopLeft(find.text('History')).dy;
      expect(activeHeader, lessThan(historyHeader));
      expect(
        tester.getTopLeft(find.text('Brake Inspection')).dy,
        lessThan(historyHeader),
      );
      expect(
        tester.getTopLeft(find.text('Oil & Filter Change')).dy,
        greaterThan(historyHeader),
      );
      // One upcoming appointment plus one already with the workshop.
      expect(find.textContaining('1 upcoming'), findsOneWidget);
      expect(find.textContaining('1 in service'), findsOneWidget);
      expect(find.textContaining('2 past services'), findsOneWidget);
    });

    testWidgets('states each section\'s real record count', (tester) async {
      await _pumpBookings(
        tester,
        bookings: const [_nearer, _later, _olderCompleted],
      );

      String? countNextTo(String title) {
        final row = find
            .ancestor(of: find.text(title), matching: find.byType(Row))
            .first;
        final texts = tester.widgetList<Text>(
          find.descendant(of: row, matching: find.byType(Text)),
        );
        for (final text in texts) {
          final value = text.data ?? '';
          if (value != title && value.isNotEmpty) return value;
        }
        return null;
      }

      expect(countNextTo('Upcoming'), '2');
      expect(countNextTo('History'), '1');
    });

    testWidgets(
      'surfaces real live stage and tracks the contextual Status page',
      (tester) async {
        await _pumpBookings(
          tester,
          bookings: const [_inService],
          activeService: _liveService,
        );

        expect(find.text('IN SERVICE'), findsOneWidget);
        expect(find.text('Current stage \u00b7 Quality Check'), findsOneWidget);

        await tester.tap(find.text('Track service'));
        await tester.pumpAndSettle();
        expect(find.text('SERVICE_STATUS'), findsOneWidget);
      },
    );

    testWidgets('never shows a live stage for an unrelated booking', (
      tester,
    ) async {
      await _pumpBookings(
        tester,
        bookings: const [_inService, _nearer],
        activeService: _liveService,
      );

      expect(find.text('Current stage \u00b7 Quality Check'), findsOneWidget);
    });

    testWidgets('routes a real pending approval into the approvals flow', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_approvalRequired]);

      expect(find.textContaining('Estimate AED 1,250'), findsOneWidget);
      expect(
        find.textContaining('Estimate AED 1,250 awaiting approval'),
        findsOneWidget,
      );

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(find.text('APPROVALS estimateId=EST-9001'), findsOneWidget);
    });

    testWidgets('opens booking detail from a row', (tester) async {
      await _pumpBookings(tester, bookings: const [_withReferences]);

      await tester.tap(find.text('Brake Inspection'));
      await tester.pumpAndSettle();
      expect(find.text('BOOKING_DETAIL'), findsOneWidget);
    });
  });

  group('CustomerBookingsTab scale', () {
    testWidgets('a single booking still reads as a complete workspace', (
      tester,
    ) async {
      await _pumpBookings(tester, bookings: const [_withReferences]);

      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('1 upcoming'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Book service'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stays compact with many bookings', (tester) async {
      await _pumpBookings(tester, bookings: _many, activeService: _liveService);

      // A plain appointment row stays a compact record, not a 200px card.
      final plainRow = find.ancestor(
        of: find.text('Brake Inspection'),
        matching: find.byType(CustomerBookingItem),
      );
      expect(tester.getSize(plainRow).height, lessThan(140));
      expect(find.text('History'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CustomerBookingsTab layout', () {
    testWidgets('stays overflow-free on the smallest supported phone', (
      tester,
    ) async {
      await _pumpBookings(
        tester,
        size: const Size(320, 640),
        bookings: const [_verbose, _inService, _approvalRequired, _cancelled],
        activeService: _liveService,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives an increased text scale', (tester) async {
      await _pumpBookings(
        tester,
        textScaler: const TextScaler.linear(1.6),
        bookings: const [_verbose, _inService, _olderCompleted, _cancelled],
        activeService: _liveService,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses two columns for upcoming and history on wide layouts', (
      tester,
    ) async {
      await _pumpBookings(
        tester,
        size: const Size(1440, 900),
        bookings: const [_nearer, _olderCompleted],
      );

      final upcoming = tester.getTopLeft(find.text('Upcoming')).dx;
      final history = tester.getTopLeft(find.text('History')).dx;
      expect(history, greaterThan(upcoming));
    });

    testWidgets('renders in dark theme without exceptions', (tester) async {
      await _pumpBookings(
        tester,
        theme: AppTheme.dark(BrandConfig.orient),
        bookings: const [_nearer, _cancelled],
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Brake Inspection'), findsOneWidget);
    });
  });

  group('CustomerBookingsTab refresh', () {
    testWidgets('pull to refresh reloads bookings and tracking state', (
      tester,
    ) async {
      final notifier = await _pumpBookings(tester, bookings: const [_nearer]);

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 320),
        1200,
      );
      await tester.pumpAndSettle();

      expect(notifier.refreshCount, greaterThan(0));
    });

    testWidgets('preserves bookings when a refresh fails', (tester) async {
      final notifier = await _pumpBookings(
        tester,
        bookings: const [_nearer],
        loadError: 'unavailable',
      );

      expect(find.text('Brake Inspection'), findsOneWidget);
      expect(
        find.text("We couldn't refresh your information."),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(notifier.refreshCount, 1);
    });
  });

  // These render the REAL composed workspace ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â shell, navigation rail or
  // bottom navigation and all ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â so the reference images match what a customer
  // actually sees, not just the tab in isolation.
  group('CustomerBookingsTab actual composition', () {
    testWidgets('mixed lifecycle mobile', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        fileName: 'goldens/customer_bookings_mixed_mobile.png',
        bookings: const [
          _inService,
          _approvalRequired,
          _nearer,
          _olderCompleted,
          _cancelled,
        ],
        activeService: _liveService,
      );
    });

    testWidgets('upcoming mobile', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        fileName: 'goldens/customer_bookings_upcoming_mobile.png',
        bookings: const [_withReferences],
      );
    });

    testWidgets('one booking mobile', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        fileName: 'goldens/customer_bookings_one_mobile.png',
        bookings: const [_withReferences],
      );
    });

    testWidgets('many bookings mobile', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        fileName: 'goldens/customer_bookings_many_mobile.png',
        bookings: _many,
        activeService: _liveService,
      );
    });

    testWidgets('empty mobile', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        fileName: 'goldens/customer_bookings_empty_mobile.png',
        bookings: const [],
      );
    });

    testWidgets('tablet composition', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        size: const Size(1024, 900),
        fileName: 'goldens/customer_bookings_tablet.png',
        bookings: const [
          _nearer,
          _approvalRequired,
          _olderCompleted,
          _cancelled,
        ],
      );
    });

    testWidgets('dark mode mobile', (tester) async {
      await _expectWorkspaceGolden(
        tester,
        theme: AppTheme.dark(BrandConfig.orient),
        fileName: 'goldens/customer_bookings_dark_mobile.png',
        bookings: const [_inService, _nearer, _olderCompleted],
        activeService: _liveService,
      );
    });

    testWidgets('opening a booking covers the workspace navigation', (
      tester,
    ) async {
      await _pumpWorkspace(tester, bookings: const [_withReferences]);

      await tester.tap(find.text('Brake Inspection'));
      await tester.pumpAndSettle();
      await _ignoreOutOfScopeImageFailures(tester);

      // Booking Details is a root-level pushed page: the workspace navigation
      // is not part of the screen the customer sees.
      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(
        find.text('Bookings'),
        findsNothing,
        reason: 'the workspace destination label is covered by the detail page',
      );
      expect(find.text('CONFIRMED'), findsOneWidget);
    });
  });

  // States the customer really hits that the populated goldens cannot show.
  group('CustomerBookingsTab real-world states', () {
    testWidgets('loading skeleton matches the list it replaces', (
      tester,
    ) async {
      await _pumpBookings(
        tester,
        bookings: const [],
        pendingBookings: true,
        settle: false,
      );
      await tester.pump();

      await expectLater(
        find.byType(CustomerBookingsSkeleton),
        matchesGoldenFile('goldens/customer_bookings_loading_mobile.png'),
      );
    });

    testWidgets('sparse records still compose cleanly', (tester) async {
      await _pumpBookings(tester, bookings: const [_sparse, _sparseHistory]);

      await expectLater(
        find.byType(CustomerBookingsTab),
        matchesGoldenFile('goldens/customer_bookings_sparse_mobile.png'),
      );
    });

    testWidgets('the real shell survives every supported phone width', (
      tester,
    ) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpWorkspace(
          tester,
          bookings: const [
            _inService,
            _approvalRequired,
            _verbose,
            _cancelled,
            _sparse,
          ],
          activeService: _liveService,
          size: Size(width, 844),
        );
        await _ignoreOutOfScopeImageFailures(tester);

        expect(
          tester.takeException(),
          isNull,
          reason: 'bookings workspace must not overflow at ${width}px',
        );
        expect(
          find.byType(AppBottomNavigation),
          findsOneWidget,
          reason: 'phones keep the bottom navigation at ${width}px',
        );
      }
    });
  });
}

// ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ Fixtures (real entity shapes only) ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬

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

const _withReferences = CustomerBookingEntity(
  id: 'b-near',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

const _nearer = CustomerBookingEntity(
  id: 'b-near',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
);

const _later = CustomerBookingEntity(
  id: 'b-later',
  service: 'Tyre Rotation',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2 Oct 2026',
  time: '02:00 PM',
  status: BookingStatus.pending,
);

const _unreadable = CustomerBookingEntity(
  id: 'b-unreadable',
  service: 'Wheel Alignment',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: 'next Tuesday',
  time: 'morning',
  status: BookingStatus.pending,
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

const _olderCompleted = CustomerBookingEntity(
  id: 'b-old',
  service: 'Oil & Filter Change',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2 Jun 2026',
  time: '11:00 AM',
  status: BookingStatus.completed,
);

const _newerCompleted = CustomerBookingEntity(
  id: 'b-new',
  service: 'Battery Check',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '11 Aug 2026',
  time: '03:30 PM',
  status: BookingStatus.delivered,
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

const _warranty = CustomerBookingEntity(
  id: 'b-warranty',
  service: 'Warranty Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '10 Sep 2026',
  time: '08:00 AM',
  status: BookingStatus.vehicleReceived,
  jobCardRef: 'JC-2026-1030',
);

const _alignment = CustomerBookingEntity(
  id: 'b-alignment',
  service: 'Wheel Alignment',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '18 Apr 2026',
  time: '04:00 PM',
  status: BookingStatus.delivered,
  jobCardRef: 'JC-2026-0812',
);

/// A realistic long-running customer: active work, upcoming appointments and
/// several finished services.
/// A booking exactly as a thin backend payload can deliver it: no plate, no
/// reference, no readable date.
const _sparse = CustomerBookingEntity(
  id: '',
  service: '',
  vehicleName: '',
  plateNumber: '',
  date: 'next Tuesday',
  time: 'morning',
  status: BookingStatus.pending,
);

const _sparseHistory = CustomerBookingEntity(
  id: '',
  service: 'Brake Inspection',
  vehicleName: '',
  plateNumber: '',
  date: '',
  time: '',
  status: BookingStatus.completed,
);

/// A booking whose only identifier is an internal job card id.
const _internalIdOnly = CustomerBookingEntity(
  id: 'b-internal',
  service: 'Tyre Rotation',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2 Oct 2026',
  time: '02:00 PM',
  status: BookingStatus.pending,
  jobCardId: '4821',
);

const _many = <CustomerBookingEntity>[
  _inService,
  _approvalRequired,
  _nearer,
  _later,
  _olderCompleted,
  _newerCompleted,
  _cancelled,
  _alignment,
  _warranty,
];

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
  final List<int> selectedTabs = [];
  int refreshCount = 0;

  @override
  CustomerDashboardState build() => _initial;

  @override
  void selectTab(int index) {
    selectedTabs.add(index);
    state = state.copyWith(selectedIndex: index);
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

Future<_FakeDashboardNotifier> _pumpBookings(
  WidgetTester tester, {
  required List<CustomerBookingEntity> bookings,
  List<CustomerVehicleEntity> vehicles = const [_vehicle],
  CustomerServiceEntity? activeService,
  String loadError = '',
  bool loading = false,

  /// Keeps the bookings feed unresolved so the loading state can be asserted.
  bool pendingBookings = false,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final notifier = _FakeDashboardNotifier(
    CustomerDashboardState(
      selectedIndex: CustomerDestination.bookings.index,
      isLoading: loading,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      loadError: loadError,
      vehicles: vehicles,
      notifications: const [],
      activeService: activeService,
      profile: const CustomerEntity(
        name: 'Ahmed Al Mansoori',
        firstName: 'Ahmed',
        avatarInitials: 'AM',
        memberId: 'CUS-1042',
      ),
    ),
  );

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: CustomerBookingsTab()),
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
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        builder: (_, __) => const Scaffold(body: Text('BOOKING_DETAIL')),
      ),
      GoRoute(
        path: AppRoutes.customerBookService,
        builder: (_, __) => const Scaffold(body: Text('BOOK_SERVICE')),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) => const Scaffold(body: Text('ADD_VEHICLE')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(() => notifier),
        customerBookingsProvider.overrideWith((ref) async {
          if (pendingBookings) {
            await Completer<List<CustomerBookingEntity>>().future;
          }
          return bookings;
        }),
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
  return notifier;
}

/// Renders the real workspace at the Bookings destination and captures the
/// whole composed screen, so the reference image includes the same shell chrome
/// a customer sees (bottom navigation on phones, navigation rail on tablets).
Future<void> _expectWorkspaceGolden(
  WidgetTester tester, {
  required String fileName,
  required List<CustomerBookingEntity> bookings,
  CustomerServiceEntity? activeService,
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  await _pumpWorkspace(
    tester,
    bookings: bookings,
    activeService: activeService,
    size: size,
    theme: theme,
  );

  await expectLater(find.byType(CustomerScaffold), matchesGoldenFile(fileName));
}

Future<void> _pumpWorkspace(
  WidgetTester tester, {
  required List<CustomerBookingEntity> bookings,
  CustomerServiceEntity? activeService,
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final notifier = _FakeDashboardNotifier(
    CustomerDashboardState(
      selectedIndex: CustomerDestination.bookings.index,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: const [_vehicle],
      notifications: const [],
      activeService: activeService,
      profile: const CustomerEntity(
        name: 'Ahmed Al Mansoori',
        firstName: 'Ahmed',
        avatarInitials: 'AM',
        memberId: 'CUS-1042',
      ),
    ),
  );

  late final GoRouter router;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(_CustomerAuth.new),
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(ConnectivityResult.wifi),
        ),
        customerDashboardProvider.overrideWith(() => notifier),
        customerBookingsProvider.overrideWith((ref) async => bookings),
        customerApprovalsProvider.overrideWith(
          (ref) async => const <CustomerApprovalSummaryResponse>[],
        ),
        customerInvoicesProvider.overrideWith((ref) async => const []),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          router = ref.watch(appRouterProvider);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: theme ?? AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _ignoreOutOfScopeImageFailures(tester);

  router.go(AppRoutes.bookingsLocation);
  await tester.pumpAndSettle();
  // The offstage Home destination still loads its out-of-scope Vehicles stock
  // imagery, which the test HTTP client rejects. Only those failures are
  // tolerated.
  await _ignoreOutOfScopeImageFailures(tester);
}

Future<void> _ignoreOutOfScopeImageFailures(WidgetTester tester) async {
  Object? failure;
  while ((failure = tester.takeException()) != null) {
    if (failure is! NetworkImageLoadException) {
      fail('Unexpected error while rendering the workspace: $failure');
    }
  }
}

class _CustomerAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 'test-token');
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
