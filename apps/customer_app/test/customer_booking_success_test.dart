import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_success_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

/// The last step of the booking flow: what was requested, and what to do next.
void main() {
  setUpAll(_loadFonts);

  group('CustomerBookingSuccessView', () {
    testWidgets('reports the real booking the workshop returned', (
      tester,
    ) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        vehicle: 'Toyota Camry',
        plate: 'A 12345',
      );

      expect(find.text('Booking requested'), findsOneWidget);
      expect(
        find.text('The workshop will confirm your appointment.'),
        findsOneWidget,
      );
      expect(find.text('BK-2026-0042'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Full Service'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      expect(find.text('Tue, 22 Sep 2026 \u00b7 9:00 AM'), findsOneWidget);
    });

    testWidgets('never invents a reference for a booking still queued', (
      tester,
    ) async {
      await _pumpSuccess(tester, queuedOffline: true);

      expect(find.text('Booking saved'), findsOneWidget);
      expect(find.textContaining('stored on this device'), findsOneWidget);
      expect(find.text('Booking reference'), findsNothing);
      // Offline bookings are not yet created at the workshop, so there is
      // nothing to open in Booking Details.
      expect(find.text('View booking'), findsNothing);
      expect(find.text('View bookings'), findsOneWidget);
    });

    testWidgets('opens the created booking once the feed really has it', (
      tester,
    ) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        bookingId: '77',
        createdBooking: _createdBooking,
      );

      expect(find.text('View booking'), findsOneWidget);
      await tester.tap(find.text('View booking'));
      await tester.pumpAndSettle();
      expect(find.text('BOOKING_DETAIL'), findsOneWidget);
    });

    testWidgets('resolves the created booking from its id alone', (
      tester,
    ) async {
      await _pumpSuccess(
        tester,
        bookingId: '77',
        createdBooking: _createdBooking,
      );

      expect(find.text('View booking'), findsOneWidget);
    });

    testWidgets('falls back to the bookings list when it cannot resolve it', (
      tester,
    ) async {
      await _pumpSuccess(tester, bookingRef: 'BK-2026-0042', bookingId: '77');

      expect(find.text('View booking'), findsNothing);
      await tester.tap(find.text('View bookings'));
      await tester.pumpAndSettle();
      // The named Bookings destination, never a numeric tab index.
      expect(find.text('DASHBOARD bookings'), findsOneWidget);
    });

    testWidgets('returns home deliberately', (tester) async {
      await _pumpSuccess(tester, bookingRef: 'BK-2026-0042');

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(find.text('DASHBOARD '), findsOneWidget);
    });

    testWidgets('shows no stock imagery and no invented promises', (
      tester,
    ) async {
      await _pumpSuccess(tester, bookingRef: 'BK-2026-0042');

      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('1–2 hours'), findsNothing);
      expect(find.textContaining('Mon–Fri'), findsNothing);
      expect(find.textContaining('Success!'), findsNothing);
    });

    testWidgets('stays usable on the smallest phone and at large text', (
      tester,
    ) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BOOKING-REFERENCE-2026-0000-LONG-IDENTIFIER-99441',
        vehicle: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
        plate: 'DUBAI A 99441',
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);

      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        vehicle: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
        plate: 'DUBAI A 99441',
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Booking requested'), findsOneWidget);
    });
  });

  group('booking flow imagery guard', () {
    test('never reintroduces stock imagery into the booking flow', () {
      for (final path in const [
        'lib/features/customer/presentation/customer_book_service_view.dart',
        'lib/features/customer/presentation/widgets/customer_booking_steps.dart',
        'lib/features/customer/presentation/widgets/customer_booking_flow_progress.dart',
        'lib/features/customer/presentation/widgets/customer_notice_panel.dart',
        'lib/features/customer/presentation/customer_booking_success_view.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(
          source.contains('unsplash'),
          isFalse,
          reason: '$path must not reference stock photography',
        );
        expect(
          source.contains('Image.network'),
          isFalse,
          reason: '$path must not render remote imagery',
        );
      }
    });
  });

  group('Booking success visual references', () {
    testWidgets('mobile', (tester) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        vehicle: 'Toyota Camry',
        plate: 'A 12345',
      );
      await expectLater(
        find.byType(CustomerBookingSuccessView),
        matchesGoldenFile('goldens/customer_booking_success_mobile.png'),
      );
    });

    testWidgets('tablet', (tester) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        vehicle: 'Toyota Camry',
        plate: 'A 12345',
        size: const Size(1024, 900),
      );
      await expectLater(
        find.byType(CustomerBookingSuccessView),
        matchesGoldenFile('goldens/customer_booking_success_tablet.png'),
      );
    });

    testWidgets('dark', (tester) async {
      await _pumpSuccess(
        tester,
        bookingRef: 'BK-2026-0042',
        vehicle: 'Toyota Camry',
        plate: 'A 12345',
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(CustomerBookingSuccessView),
        matchesGoldenFile('goldens/customer_booking_success_dark.png'),
      );
    });
  });
}

const _createdBooking = CustomerBookingEntity(
  id: '77',
  service: 'Full Service',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.pending,
  bookingRef: 'BK-2026-0042',
);

Future<void> _pumpSuccess(
  WidgetTester tester, {
  String bookingRef = '',
  String bookingId = '',
  String service = 'Full Service',
  String date = '2026-09-22',
  String time = '09:00',
  String vehicle = '',
  String plate = '',
  bool queuedOffline = false,
  CustomerBookingEntity? createdBooking,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => CustomerBookingSuccessView(
          bookingRef: bookingRef,
          bookingId: bookingId,
          service: service,
          date: date,
          time: time,
          vehicle: vehicle,
          plate: plate,
          queuedOffline: queuedOffline,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        builder: (_, __) => const Scaffold(body: Text('BOOKING_DETAIL')),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (context, state) => Scaffold(
          body: Text(
            'DASHBOARD '
            '${state.uri.queryParameters['tab'] ?? ''}',
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerBookingsProvider.overrideWith(
          (ref) async => createdBooking == null
              ? const <CustomerBookingEntity>[]
              : [createdBooking],
        ),
        customerDashboardProvider.overrideWith(_FakeDashboardNotifier.new),
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
  await tester.pumpAndSettle();
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  @override
  CustomerDashboardState build() => const CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: [],
    notifications: [],
  );

  @override
  Future<void> refresh() async {}
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
