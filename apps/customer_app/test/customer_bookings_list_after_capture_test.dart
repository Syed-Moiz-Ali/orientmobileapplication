// AFTER captures for the customer bookings list (post-redesign).
//
// Pumps CustomerBookingsTab with deterministic fixtures and writes viewport
// PNGs into docs/ui-redesign/baseline/after-customer-bookings/ for
// before/after diffing. No app code is modified; all fakes live in this file.
//
// Run (from apps/customer_app):
//   flutter test --tags baseline --update-goldens test/customer_bookings_list_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/customer_bookings_list_after_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
//
// Harness rules followed: real bundled fonts via FontLoader in setUpAll
// (Plus Jakarta Sans + IBM Plex Sans Arabic + MaterialIcons from the SDK),
// debugShowCheckedModeBanner: false, shadows restored per test, runAsync with
// a real delay around the pump, connectivity channel mocks (check +
// checkConnectivity), ar via locale + global delegates + AppTheme locale.
// No network, no file I/O in test bodies.
@Tags(['baseline'])
library;

import 'dart:async';
import 'dart:io';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _outDir = 'after-customer-bookings';

// ---------------------------------------------------------------- fixtures

const _upcoming = CustomerBookingEntity(
  id: 'b1',
  service: 'Oil change',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  date: '12 Jun 2026',
  time: '10:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-1001',
);

const _upcoming2 = CustomerBookingEntity(
  id: 'b5',
  service: 'Tire rotation',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  date: '18 Jun 2026',
  time: '11:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-1005',
);

const _inService = CustomerBookingEntity(
  id: 'b2',
  service: 'Brake pads',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '10 Jun 2026',
  time: '09:00',
  status: BookingStatus.inProgress,
  jobCardId: 'JC-7',
  bookingRef: 'BK-1002',
);

const _approval = CustomerBookingEntity(
  id: 'b4',
  service: 'Engine overhaul',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '15 Jun 2026',
  time: '11:00',
  status: BookingStatus.approvalRequired,
  estimateId: 'EST-1',
  estimateAmount: 1200,
  bookingRef: 'BK-1009',
);

const _history = CustomerBookingEntity(
  id: 'b3',
  service: 'Wheel alignment',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  date: '02 May 2026',
  time: '09:00',
  status: BookingStatus.completed,
  bookingRef: 'BK-0987',
);

const _history2 = CustomerBookingEntity(
  id: 'b6',
  service: 'AC service',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '20 Apr 2026',
  time: '09:00',
  status: BookingStatus.delivered,
  bookingRef: 'BK-0955',
);

/// Six loaded records (> 5) so the progressive-disclosure find-aids
/// (search + filter icons) are visible — the sanctioned U1 exception.
const _six = [
  _upcoming,
  _upcoming2,
  _inService,
  _approval,
  _history,
  _history2,
];

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-7',
  plateNumber: 'XYZ 5678',
  vehicleName: 'Honda Civic',
  service: 'Brake pads',
  started: '',
  estCompletion: '',
  progressPercent: 40,
  // Test-data only: deliberately differs from the booking status
  // (`In Service`) so the pill and the stage line prove both signals
  // independently (F3). Production predicate unchanged.
  currentStage: 'Quality check',
  technicianName: '',
  stages: [],
);

const _failed = FailedBooking(
  operationId: 'op-1',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  service: 'Oil change',
  date: '12 Jun 2026',
  time: '10:00',
  notes: '',
);

const _vehicle = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'ABC 1234',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '45000 km',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

class _FixedDashNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedDashNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

class _NoFailedSync implements FailedBookingSync {
  @override
  List<FailedBooking> failedBookings() => const [];
  @override
  Future<bool> retry(String operationId) async => false;
  @override
  Future<void> remove(String operationId) async {}
}

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerVehicleEntity> vehicles = const [],
  CustomerServiceEntity? activeService,
}) => CustomerDashboardState(
  selectedIndex: 1,
  isLoading: isLoading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  vehicles: vehicles,
  notifications: const [],
  activeService: activeService,
  profile: null,
  loadError: loadError,
);

// ---------------------------------------------------------------- harness

/// Locates `<repo>/packages/shared_core/assets/fonts` regardless of whether
/// tests run from the package dir or the repo root.
String _fontRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final candidate =
        '${dir.path}${Platform.pathSeparator}packages${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory(candidate).existsSync()) return candidate;
    final local =
        '${dir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory('$local${Platform.pathSeparator}plus_jakarta_sans')
        .existsSync()) {
      return local;
    }
    dir = dir.parent;
  }
  throw StateError('shared_core font root not found from ${Directory.current.path}');
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
      );
    }
    await loader.load();
  }

  final root = _fontRoot();
  await load('packages/shared_core/Plus Jakarta Sans', [
    '$root/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
  ]);

  // MaterialIcons from the enclosing Flutter SDK (same probe as phase-1).
  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(ByteData.sublistView(candidate.readAsBytesSync())),
        );
      await loader.load();
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<FailedBooking> failed = const [],
  bool dark = false,
  double scale = 1.0,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double dpr = 3.0,
  bool loading = false,
  bool openSearch = false,
  bool openFilter = false,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize =
      Size(logicalSize.width * dpr, logicalSize.height * dpr);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);

  // connectivity_plus MethodChannel: offline for both the v6
  // ('checkConnectivity') and v7 ('check') method names.
  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall call) async {
      if (call.method == 'checkConnectivity' || call.method == 'check') {
        return <String>['none'];
      }
      return null;
    },
  );
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    ),
  );

  // runAsync + a real delay (proven pattern from the phase-0a baseline):
  // the pump runs on real event-loop turns while the fake clock stays fixed,
  // so shimmer/transition frames land byte-identically on every run.
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerDashboardProvider.overrideWith(
            () => _FixedDashNotifier(state),
          ),
          if (loading)
            customerBookingsProvider.overrideWith(
              (ref) => Completer<List<CustomerBookingEntity>>().future,
            )
          else
            customerBookingsProvider.overrideWith((ref) async => bookings),
          customerFailedBookingsProvider.overrideWith((ref) => failed),
          failedBookingSyncProvider.overrideWith(
            (ref) => _NoFailedSync(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            CustomerLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          darkTheme: AppTheme.dark(BrandConfig.orient, locale: locale),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const Scaffold(body: CustomerBookingsTab()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  if (openSearch) {
    // Locale-independent: search icon (tooltip is localized in ar).
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  if (openFilter) {
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(
      '../../../docs/ui-redesign/baseline/$_outDir/$name',
    ),
  );
  debugDisableShadows = oldShadows;
}

String _name(
  String state,
  String theme,
  double scale,
  String locale,
  Size size,
) =>
    '${state}_${theme}_${scale.toStringAsFixed(1)}_${locale}_${size.width.toInt()}x${size.height.toInt()}.png';

// ---------------------------------------------------------------- tests

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('bookings-list after capture: fonts ready');
  });

  group('after matrix @360x800', () {
    testWidgets('idle 6-record light en 1.0 (find-aids visible)', (
      tester,
    ) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(activeService: _liveService),
        bookings: _six,
      );
    });
    testWidgets('empty light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('empty', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(vehicles: const [_vehicle]),
      );
    });
    testWidgets('loading light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('loading', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(isLoading: true),
        loading: true,
      );
    });
    testWidgets('error light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('error', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(loadError: 'No connection'),
      );
    });
    testWidgets('failed light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('failed', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(),
        bookings: const [_upcoming2, _history],
        failed: const [_failed],
      );
    });
    testWidgets('search sheet open', (tester) async {
      await _capture(
        tester,
        name: _name(
          'search-open',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(activeService: _liveService),
        bookings: _six,
        openSearch: true,
      );
    });
    testWidgets('filter sheet open', (tester) async {
      await _capture(
        tester,
        name: _name(
          'filter-open',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(activeService: _liveService),
        bookings: _six,
        openFilter: true,
      );
    });
    testWidgets('idle dark en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(activeService: _liveService),
        bookings: _six,
        dark: true,
      );
    });
    testWidgets('idle light ar 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'ar', const Size(360, 800)),
        state: _state(activeService: _liveService),
        bookings: _six,
        locale: const Locale('ar'),
      );
    });
    testWidgets('idle light en 1.3', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.3, 'en', const Size(360, 800)),
        state: _state(activeService: _liveService),
        bookings: _six,
        scale: 1.3,
      );
    });
    testWidgets('idle light en 1.0 320px', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(320, 568)),
        state: _state(activeService: _liveService),
        bookings: _six,
        logicalSize: const Size(320, 568),
      );
    });
    testWidgets('idle light en 1.0 tablet', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(768, 1024)),
        state: _state(activeService: _liveService),
        bookings: _six,
        logicalSize: const Size(768, 1024),
        dpr: 2.0,
      );
    });
  });
}
