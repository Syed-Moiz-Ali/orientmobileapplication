import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

void main() {
  group('Booking detail cancellation', () {
    testWidgets('a confirmed booking can be cancelled from the detail screen', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _confirmed);

      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('Cancel booking'), findsOneWidget);
    });

    testWidgets('asks for confirmation before sending anything', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource();
      await _pumpDetail(tester, booking: _confirmed, remote: remote);

      await _openCancelDialog(tester);

      expect(
        find.text(
          'This will cancel your appointment for Brake Inspection on '
          'Tue, 22 Sep 2026 \u00b7 9:00 AM. This cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Keep booking'), findsOneWidget);
      // Nothing reaches the API until the customer explicitly confirms.
      expect(remote.cancelledIds, isEmpty);
    });

    testWidgets('keeping the booking changes nothing', (tester) async {
      final remote = _FakeRemoteDataSource();
      await _pumpDetail(tester, booking: _confirmed, remote: remote);

      await _openCancelDialog(tester);
      await tester.tap(find.text('Keep booking'));
      await tester.pumpAndSettle();

      expect(remote.cancelledIds, isEmpty);
      expect(find.text('Cancel booking'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
    });

    testWidgets('confirming cancels through the API and reflects it', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource();
      await _pumpDetail(
        tester,
        booking: _confirmed,
        remote: remote,
        afterCancel: _cancelled,
      );

      await _openCancelDialog(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel booking'));
      await tester.pumpAndSettle();

      expect(remote.cancelledIds, [42]);
      expect(find.text('Booking cancelled.'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('a cancellation in flight cannot be submitted twice', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource(pending: true);
      await _pumpDetail(tester, booking: _confirmed, remote: remote);

      await _openCancelDialog(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel booking'));
      await tester.pump();

      // Real in-flight feedback, and the action is no longer tappable.
      expect(find.text('Cancelling\u2026'), findsOneWidget);
      final action = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Cancelling\u2026'),
          matching: find.byWidgetPredicate((widget) => widget is TextButton),
        ),
      );
      expect(action.onPressed, isNull);

      await tester.tap(find.text('Cancelling\u2026'), warnIfMissed: false);
      await tester.pump();
      expect(remote.cancelledIds, [42]);

      remote.complete(true);
      await tester.pumpAndSettle();
      expect(remote.cancelledIds, [42]);
    });

    testWidgets('a failed cancellation is reported and can be retried', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource(succeeds: false);
      await _pumpDetail(tester, booking: _confirmed, remote: remote);

      await _openCancelDialog(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel booking'));
      await tester.pumpAndSettle();

      expect(remote.cancelledIds, [42]);
      expect(
        find.text("We couldn't cancel this booking. Please try again."),
        findsOneWidget,
      );
      // The booking is untouched and the customer can try again.
      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Cancel booking'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(remote.cancelledIds, [42, 42]);
    });

    testWidgets('a cancelled booking offers no cancellation', (tester) async {
      await _pumpDetail(tester, booking: _cancelled);

      expect(find.text('CANCELLED'), findsWidgets);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('a finished booking cannot be cancelled from the app', (
      tester,
    ) async {
      await _pumpDetail(tester, booking: _completed);

      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('a booking without a usable id never hits the API', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource();
      await _pumpDetail(tester, booking: _noId, remote: remote);

      await _openCancelDialog(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel booking'));
      await tester.pumpAndSettle();

      expect(remote.cancelledIds, isEmpty);
      expect(
        find.text("We couldn't cancel this booking. Please try again."),
        findsOneWidget,
      );
      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Fixtures (real entity shapes only) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

const _confirmed = CustomerBookingEntity(
  id: '42',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
);

const _cancelled = CustomerBookingEntity(
  id: '42',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.cancelled,
);

const _completed = CustomerBookingEntity(
  id: '43',
  service: 'Oil & Filter Change',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2 Jun 2026',
  time: '11:00 AM',
  status: BookingStatus.completed,
);

const _noId = CustomerBookingEntity(
  id: '',
  service: 'Wheel Alignment',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '25 Sep 2026',
  time: '08:30 AM',
  status: BookingStatus.pending,
);

/// Fakes the booking-status call the cancellation flow depends on, without any
/// network access.
class _FakeRemoteDataSource implements CustomerRemoteDataSource {
  _FakeRemoteDataSource({this.succeeds = true, this.pending = false});

  final List<int> cancelledIds = [];
  final bool succeeds;
  final bool pending;
  Completer<bool>? _completer;

  @override
  Future<bool> cancelBooking(int bookingId) {
    cancelledIds.add(bookingId);
    if (pending) {
      _completer ??= Completer<bool>();
      return _completer!.future;
    }
    return Future<bool>.value(succeeds);
  }

  void complete(bool value) => _completer!.complete(value);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<void> _openCancelDialog(WidgetTester tester) async {
  final action = find.text('Cancel booking');
  await tester.ensureVisible(action);
  await tester.pumpAndSettle();
  await tester.tap(action);
  await tester.pumpAndSettle();
  expect(find.text('Cancel booking?'), findsOneWidget);
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required CustomerBookingEntity booking,
  _FakeRemoteDataSource? remote,
  CustomerBookingEntity? afterCancel,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final dataSource = remote ?? _FakeRemoteDataSource();

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => CustomerBookingDetailView(booking: booking),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (_, __) => const Scaffold(body: Text('DASHBOARD')),
      ),
      GoRoute(
        path: AppRoutes.customerServiceStatus,
        builder: (_, __) => const Scaffold(body: Text('SERVICE_STATUS')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerRemoteDataSourceProvider.overrideWithValue(dataSource),
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            const CustomerDashboardState(
              selectedIndex: 0,
              isLoading: false,
              selectedVehicle: '',
              selectedServiceType: '',
              bookingNotes: '',
              vehicles: [],
              notifications: [],
            ),
          ),
        ),
        customerApprovalsProvider.overrideWith(
          (ref) async => const <CustomerApprovalSummaryResponse>[],
        ),
        customerBookingsProvider.overrideWith((ref) async {
          if (afterCancel != null && dataSource.cancelledIds.isNotEmpty) {
            return [afterCancel];
          }
          return [booking];
        }),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;

  @override
  CustomerDashboardState build() => _initial;
}
