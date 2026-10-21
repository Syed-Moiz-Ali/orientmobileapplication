// Phase-6 customer-home capture (after redesign).
//
// Pumps the recomposed CustomerHomeTab with deterministic fixtures (reused
// from customer_home_tab_test.dart) and writes viewport PNGs into
// docs/ui-redesign/baseline/after-phase-6-customer/ for before/after diffing.
//
// Run (from apps/customer_app):
//   flutter test --tags baseline --update-goldens test/customer_home_phase6_capture_test.dart   (generate)
//   flutter test --tags baseline test/customer_home_phase6_capture_test.dart                    (compare)
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

import 'dart:io';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _outDir = 'after-phase-6-customer';

// ---------------------------------------------------------------- fixtures

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

const _vehicle2 = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Honda',
  model: 'Civic',
  plateNumber: 'XYZ 5678',
  vin: '',
  color: 'Silver',
  year: 2019,
  mileage: '78200 km',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

/// A vehicle with every optional field blank: exercises the n/a fallbacks
/// (fallback name, no spec line, no plate footer, no context badge).
const _naVehicle = CustomerVehicleEntity(
  id: 'v9',
  brand: '',
  model: '',
  plateNumber: '',
  vin: '',
  color: '',
  year: 0,
  mileage: '',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-1',
  plateNumber: 'ABC 1234',
  vehicleName: 'Toyota Camry',
  service: 'Full service',
  started: '',
  estCompletion: 'Today, 5 PM',
  progressPercent: 60,
  currentStage: 'On the lift',
  technicianName: '',
  stages: [],
);

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

const _completed = CustomerBookingEntity(
  id: 'b2',
  service: 'Brake pads',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '02 May 2026',
  time: '09:00',
  status: BookingStatus.completed,
  bookingRef: 'BK-0987',
);

const _approval = CustomerApprovalSummaryResponse(
  estimateId: 'E1',
  amount: 450,
);

class _FixedHomeNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedHomeNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerVehicleEntity> vehicles = const [],
  CustomerServiceEntity? activeService,
  int unpaidInvoices = 0,
  bool withProfile = true,
}) => CustomerDashboardState(
  selectedIndex: 0,
  isLoading: isLoading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  vehicles: vehicles,
  notifications: const [],
  activeService: activeService,
  profile: withProfile
      ? const CustomerEntity(
          name: 'Ahmed Ali',
          firstName: 'Ahmed',
          avatarInitials: 'AA',
          memberId: 'M1',
        )
      : null,
  unpaidInvoices: unpaidInvoices,
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
    // Also accept running from inside packages/shared_core itself.
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
  List<CustomerApprovalSummaryResponse> approvals = const [],
  bool dark = false,
  double scale = 1.0,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double dpr = 3.0,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize =
      Size(logicalSize.width * dpr, logicalSize.height * dpr);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);

  // connectivity_plus MethodChannel: offline for both the v6
  // ('checkConnectivity') and v7 ('check') method names. Nothing in this
  // harness dials it (all providers are overridden fakes), but the mocks
  // keep a stray plugin call from failing the capture.
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
            () => _FixedHomeNotifier(state),
          ),
          customerBookingsProvider.overrideWith((ref) async => bookings),
          customerApprovalsProvider.overrideWith((ref) async => approvals),
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
          home: const Scaffold(body: CustomerHomeTab()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

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
    debugPrint('phase-6 capture: fonts ready');
  });

  // Loaded idle fixture: greeting + attention (approval) + 2 vehicles +
  // live service + recent activity.
  CustomerDashboardState idleState() => _state(
        vehicles: const [_vehicle, _vehicle2],
        activeService: _liveService,
      );
  List<CustomerBookingEntity> idleBookings() => const [_upcoming, _completed];
  List<CustomerApprovalSummaryResponse> idleApprovals() => const [_approval];

  group('idle matrix @360x800', () {
    for (final dark in [false, true]) {
      for (final locale in ['en', 'ar']) {
        for (final scale in [1.0, 1.3]) {
          final theme = dark ? 'dark' : 'light';
          testWidgets(
            'idle $theme $scale $locale 360x800',
            (tester) async {
              await _capture(
                tester,
                name: _name(
                  'idle',
                  theme,
                  scale,
                  locale,
                  const Size(360, 800),
                ),
                state: idleState(),
                bookings: idleBookings(),
                approvals: idleApprovals(),
                dark: dark,
                scale: scale,
                locale: Locale(locale),
              );
            },
          );
        }
      }
    }
  });

  group('idle small phone @320x568', () {
    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      testWidgets('idle $theme en 1.0 320x568', (tester) async {
        await _capture(
          tester,
          name: _name('idle', theme, 1.0, 'en', const Size(320, 568)),
          state: idleState(),
          bookings: idleBookings(),
          approvals: idleApprovals(),
          dark: dark,
          logicalSize: const Size(320, 568),
        );
      });
    }
  });

  group('idle tablet', () {
    testWidgets('idle light en 1.0 768x1024', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(768, 1024)),
        state: idleState(),
        bookings: idleBookings(),
        approvals: idleApprovals(),
        logicalSize: const Size(768, 1024),
        dpr: 2.0,
      );
    });
    testWidgets('idle light en 1.0 1180x820', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(1180, 820)),
        state: idleState(),
        bookings: idleBookings(),
        approvals: idleApprovals(),
        logicalSize: const Size(1180, 820),
        dpr: 2.0,
      );
    });
  });

  group('states en light @360x800', () {
    testWidgets('loading skeleton', (tester) async {
      await _capture(
        tester,
        name: _name('loading', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(isLoading: true, withProfile: false),
      );
    });
    testWidgets('new-customer empty', (tester) async {
      await _capture(
        tester,
        name: _name('empty', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(withProfile: false),
      );
    });
    testWidgets('field n/a', (tester) async {
      await _capture(
        tester,
        name: _name('field-na', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(vehicles: const [_naVehicle]),
      );
    });
    testWidgets('error + retry', (tester) async {
      await _capture(
        tester,
        name: _name('error', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(loadError: 'No connection', withProfile: false),
      );
    });
    testWidgets('offline banner + stale data', (tester) async {
      await _capture(
        tester,
        name: _name('offline', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(
          vehicles: const [_vehicle],
          loadError: 'No connection',
        ),
        bookings: const [_completed],
      );
    });
    testWidgets('hero approval-waiting', (tester) async {
      await _capture(
        tester,
        name: _name(
          'hero-approval',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_completed],
        approvals: const [_approval],
      );
    });
    testWidgets('hero payment-due', (tester) async {
      await _capture(
        tester,
        name: _name(
          'hero-payment',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(vehicles: const [_vehicle], unpaidInvoices: 2),
        bookings: const [_completed],
      );
    });
    testWidgets('hero in-service', (tester) async {
      await _capture(
        tester,
        name: _name(
          'hero-service',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(
          vehicles: const [_vehicle],
          activeService: _liveService,
        ),
        bookings: const [_upcoming, _completed],
      );
    });
    testWidgets('hero upcoming', (tester) async {
      await _capture(
        tester,
        name: _name(
          'hero-upcoming',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_upcoming, _completed],
      );
    });
    testWidgets('hero nothing-active', (tester) async {
      await _capture(
        tester,
        name: _name(
          'hero-nothing',
          'light',
          1.0,
          'en',
          const Size(360, 800),
        ),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_completed],
      );
    });
  });

  group('hero + error dark @360x800', () {
    testWidgets('hero approval-waiting dark', (tester) async {
      await _capture(
        tester,
        name: _name('hero-approval', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_completed],
        approvals: const [_approval],
        dark: true,
      );
    });
    testWidgets('hero payment-due dark', (tester) async {
      await _capture(
        tester,
        name: _name('hero-payment', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(vehicles: const [_vehicle], unpaidInvoices: 2),
        bookings: const [_completed],
        dark: true,
      );
    });
    testWidgets('hero in-service dark', (tester) async {
      await _capture(
        tester,
        name: _name('hero-service', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(
          vehicles: const [_vehicle],
          activeService: _liveService,
        ),
        bookings: const [_upcoming, _completed],
        dark: true,
      );
    });
    testWidgets('hero upcoming dark', (tester) async {
      await _capture(
        tester,
        name: _name('hero-upcoming', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_upcoming, _completed],
        dark: true,
      );
    });
    testWidgets('hero nothing-active dark', (tester) async {
      await _capture(
        tester,
        name: _name('hero-nothing', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_completed],
        dark: true,
      );
    });
    testWidgets('error + retry dark', (tester) async {
      await _capture(
        tester,
        name: _name('error', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(loadError: 'No connection', withProfile: false),
        dark: true,
      );
    });
  });
}
