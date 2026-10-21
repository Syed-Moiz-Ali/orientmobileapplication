// Phase-3 advisor-home capture (after redesign).
//
// Pumps the recomposed AdvisorHomeView with deterministic fixtures (reused
// from advisor_home_view_test.dart) and writes viewport PNGs into
// docs/ui-redesign/baseline/after-phase-3-advisor/ for structural review
// against the old code (no "before" PNGs exist for advisor home).
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/advisor_home_phase3_capture_test.dart   (generate)
//   flutter test --tags baseline test/advisor_home_phase3_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
//
// Harness rules followed: real bundled fonts via FontLoader in setUpAll
// (Plus Jakarta Sans + IBM Plex Sans Arabic + MaterialIcons from the SDK),
// debugShowCheckedModeBanner: false, shadows restored per test, runAsync with
// a real delay around the pump, connectivity channel mocks (check +
// checkConnectivity), ar via locale + global delegates + staff theme locale.
// No network, no file I/O in test bodies. Staff light-only.
@Tags(['baseline'])
library;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-phase-3-advisor';

// ---------------------------------------------------------------- fixtures
// Reused verbatim from advisor_home_view_test.dart: greeting, hero counts,
// 2 jobs urgent-first, approvals, offline.

const _urgent = JobCardEntity(
  id: 'JC-1042',
  customerName: 'Ahmed',
  vehicleInfo: 'Camry · ABC 1234',
  time: '10:30 AM',
  status: JobCardStatus.waitingParts,
);

const _active = JobCardEntity(
  id: 'JC-1041',
  customerName: 'Layla',
  vehicleInfo: 'Yaris · XYZ 5678',
  time: '09:15 AM',
  status: JobCardStatus.inProgress,
);

const _done = JobCardEntity(
  id: 'JC-1040',
  customerName: 'Sara',
  vehicleInfo: 'Civic · DEF 9012',
  time: 'Yesterday',
  status: JobCardStatus.completed,
);

const _stats = AdvisorStatsEntity(
  newJobCardsToday: 2,
  inspectionsToday: 6,
  pendingApprovals: 2,
  vehiclesWaiting: 1,
  readyForDelivery: 1,
  totalOpenJobCards: 3,
);

const _serviceStats = AdvisorStatsEntity(
  newJobCardsToday: 0,
  inspectionsToday: 3,
  pendingApprovals: 0,
  vehiclesWaiting: 1,
  readyForDelivery: 0,
  totalOpenJobCards: 1,
);

const _nothingStats = AdvisorStatsEntity(
  newJobCardsToday: 0,
  inspectionsToday: 0,
  pendingApprovals: 0,
  vehiclesWaiting: 0,
  readyForDelivery: 0,
  totalOpenJobCards: 1,
);

const _approvals = <PendingApprovalEntity>[
  PendingApprovalEntity(
    estimateId: 'E1',
    approvalType: 'estimate',
    customerName: 'Ahmed',
    vehicleId: 'V1',
    amount: 450,
  ),
  PendingApprovalEntity(
    estimateId: 'E2',
    approvalType: 'job_card',
    customerName: 'Layla',
    vehicleId: 'V2',
    amount: 120,
  ),
];

const _notifs = <StaffNotificationResponse>[
  StaffNotificationResponse(id: 'n1', title: 'QC passed', body: 'JC-1040'),
];

const _advisorInfo = AdvisorInfo(
  name: 'Omar Haddad',
  id: 'A1',
  branch: 'Branch A',
  shift: 'Morning shift',
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
    if (Directory(
      '$local${Platform.pathSeparator}plus_jakarta_sans',
    ).existsSync()) {
      return local;
    }
    dir = dir.parent;
  }
  throw StateError(
    'shared_core font root not found from ${Directory.current.path}',
  );
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
  List<JobCardEntity> jobs = const [_urgent, _active],
  AdvisorStatsEntity stats = _stats,
  List<PendingApprovalEntity> approvals = _approvals,
  List<StaffNotificationResponse> notifs = _notifs,
  bool failJobs = false,
  bool hangJobs = false,
  ConnectivityResult connectivity = ConnectivityResult.wifi,
  double scale = 1.0,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double dpr = 3.0,
  String? searchQuery,
  bool clearAfterSubmit = false,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = Size(
    logicalSize.width * dpr,
    logicalSize.height * dpr,
  );
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);

  // connectivity_plus MethodChannel: both the v6 ('checkConnectivity') and
  // v7 ('check') method names resolve (all providers are overridden fakes,
  // but the mocks keep a stray plugin call from failing the capture).
  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
    MethodCall call,
  ) async {
    if (call.method == 'checkConnectivity' || call.method == 'check') {
      return <String>[connectivity.name];
    }
    return null;
  });
  addTearDown(
    () =>
        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  // runAsync + a real delay (proven pattern from the phase-0a baseline):
  // the pump runs on real event-loop turns while the fake clock stays fixed,
  // so shimmer/transition frames land byte-identically on every run.
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          advisorRecentJobCardsProvider.overrideWith((ref) async {
            if (failJobs) throw Exception('offline');
            if (hangJobs) await Completer<void>().future;
            return jobs;
          }),
          advisorDashboardProvider.overrideWith((ref) async => stats),
          advisorPendingApprovalsProvider.overrideWith(
            (ref) async => approvals,
          ),
          advisorPendingSyncCountProvider.overrideWith(
            (ref) => Stream<int>.value(0),
          ),
          advisorNotificationsProvider.overrideWith((ref) async => notifs),
          // Off-screen tabs stay mounted in the IndexedStack; keep them on
          // fakes so no backend/Hive is touched.
          advisorAssignedBookingsProvider.overrideWith((ref) async => []),
          advisorReportDataProvider.overrideWith(
            (ref) async => const AdvisorReportData(),
          ),
          advisorInfoProvider.overrideWithValue(_advisorInfo),
          connectivityStatusProvider.overrideWith(
            (ref) => Stream<ConnectivityResult>.value(connectivity),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const Scaffold(body: AdvisorHomeView()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  if (searchQuery != null) {
    await tester.enterText(find.byType(TextField).first, searchQuery);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    if (clearAfterSubmit) {
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

String _name(String state, double scale, String locale, Size size) =>
    '${state}_${scale.toStringAsFixed(1)}_${locale}_${size.width.toInt()}x${size.height.toInt()}.png';

// ---------------------------------------------------------------- tests

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('phase-3 advisor capture: fonts ready');
  });

  group('idle matrix @360x800', () {
    for (final locale in ['en', 'ar']) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('idle $scale $locale 360x800', (tester) async {
          await _capture(
            tester,
            name: _name('idle', scale, locale, const Size(360, 800)),
            scale: scale,
            locale: Locale(locale),
          );
        });
      }
    }
  });

  group('idle small phone @320x568', () {
    testWidgets('idle en 1.0 320x568', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 1.0, 'en', const Size(320, 568)),
        logicalSize: const Size(320, 568),
      );
    });
  });

  group('idle tablet', () {
    testWidgets('idle light en 1.0 768x1024', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 1.0, 'en', const Size(768, 1024)),
        logicalSize: const Size(768, 1024),
        dpr: 2.0,
      );
    });
    testWidgets('idle light en 1.0 1180x820', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 1.0, 'en', const Size(1180, 820)),
        logicalSize: const Size(1180, 820),
        dpr: 2.0,
      );
    });
  });

  group('states en @360x800', () {
    testWidgets('loading skeleton', (tester) async {
      await _capture(
        tester,
        name: _name('loading', 1.0, 'en', const Size(360, 800)),
        hangJobs: true,
      );
    });
    testWidgets('empty no jobs', (tester) async {
      await _capture(
        tester,
        name: _name('empty', 1.0, 'en', const Size(360, 800)),
        jobs: const [],
      );
    });
    testWidgets('error + retry', (tester) async {
      await _capture(
        tester,
        name: _name('error', 1.0, 'en', const Size(360, 800)),
        failJobs: true,
      );
    });
    testWidgets('offline banner + stale data', (tester) async {
      await _capture(
        tester,
        name: _name('offline', 1.0, 'en', const Size(360, 800)),
        connectivity: ConnectivityResult.none,
      );
    });
    testWidgets('hero approval-waiting', (tester) async {
      await _capture(
        tester,
        name: _name('hero-approval', 1.0, 'en', const Size(360, 800)),
        jobs: const [_done, _urgent, _active],
        stats: _stats,
        approvals: _approvals,
      );
    });
    testWidgets('hero in-service', (tester) async {
      await _capture(
        tester,
        name: _name('hero-service', 1.0, 'en', const Size(360, 800)),
        jobs: const [_active],
        stats: _serviceStats,
        approvals: const [],
        notifs: const [],
      );
    });
    testWidgets('hero nothing-active', (tester) async {
      await _capture(
        tester,
        name: _name('hero-nothing', 1.0, 'en', const Size(360, 800)),
        jobs: const [_done],
        stats: _nothingStats,
        approvals: const [],
        notifs: const [],
      );
    });
    testWidgets('search with query + recents', (tester) async {
      await _capture(
        tester,
        name: _name('search-query', 1.0, 'en', const Size(360, 800)),
        jobs: const [_done, _urgent, _active],
        searchQuery: 'LAYLA',
      );
    });
    testWidgets('search recents row after clear', (tester) async {
      await _capture(
        tester,
        name: _name('search-recents', 1.0, 'en', const Size(360, 800)),
        jobs: const [_done, _urgent, _active],
        searchQuery: 'LAYLA',
        clearAfterSubmit: true,
      );
    });
  });
}
