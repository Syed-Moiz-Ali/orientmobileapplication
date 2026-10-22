// AFTER capture for the advisor jobs register (GROUP-B screen 1, recomposed).
//
// Pumps the REBUILT AdvisorJobsListView with deterministic fakes and writes
// viewport PNGs into docs/ui-redesign/baseline/after-advisor-jobs/ for
// before/after review + contact sheets. Staff light-only (no dark frames).
//
// Matrix (8 PNGs):
//   idle en 360x800 (6 cards, search icon visible) | empty en 360x800 |
//   search sheet with query en 360x800 | filter applied en 360x800 |
//   idle ar 360x800 | idle 1.3x en 360x800 | idle en 320x568 |
//   wide en 1280x800 (master-detail table, row selected).
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/advisor_jobs_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/advisor_jobs_after_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-advisor-jobs';

// ---------------------------------------------------------------- fixtures
// Same deterministic register as advisor_jobs_characterization_test.dart: one
// card per filter key (intake / inspection / approved / wip / ready) + the
// sixth card that pushes the register past the > 5 search-icon threshold +
// one assigned booking so the intake-queue section renders in idle frames.

const _jobs = [
  JobCardEntity(
    id: 'JC-2001',
    customerName: 'Zara',
    vehicleInfo: 'Corolla · DXB 111',
    time: 'Pending sync',
    status: JobCardStatus.pending,
  ),
  JobCardEntity(
    id: 'JC-2002',
    customerName: 'Ahmed',
    vehicleInfo: 'Camry · ABC 1234',
    time: '10:30 AM',
    status: JobCardStatus.inspected,
  ),
  JobCardEntity(
    id: 'JC-2003',
    customerName: 'Layla',
    vehicleInfo: 'Yaris · XYZ 5678',
    time: '09:15 AM',
    status: JobCardStatus.approved,
  ),
  JobCardEntity(
    id: 'JC-2004',
    customerName: 'Omar',
    vehicleInfo: 'Hilux · DEF 9012',
    time: 'Yesterday',
    status: JobCardStatus.inProgress,
  ),
  JobCardEntity(
    id: 'JC-2005',
    customerName: 'Sara',
    vehicleInfo: 'Civic · GHI 3456',
    time: 'Yesterday',
    status: JobCardStatus.completed,
  ),
  JobCardEntity(
    id: 'JC-2006',
    customerName: 'Rania',
    vehicleInfo: 'Patrol · JKL 789',
    time: 'Today',
    status: JobCardStatus.vehicleReceived,
  ),
];

const _booking = AdvisorBookingResponse(
  id: 7,
  customerName: 'Nadia',
  vehicleName: 'Patrol',
  serviceType: 'Oil change',
  bookingDate: '2026-10-21',
);

// ---------------------------------------------------------------- harness

String _fontRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final candidate =
        '${dir.path}${Platform.pathSeparator}packages${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory(candidate).existsSync()) return candidate;
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

/// Pumps the rebuilt jobs register with deterministic fakes, runs the
/// optional [interact] step (filter tap / search sheet / wide select), then
/// golden-captures the full MaterialApp (sheet overlays included).
Future<void> _capture(
  WidgetTester tester, {
  required String name,
  List<JobCardEntity> jobs = _jobs,
  List<AdvisorBookingResponse> bookings = const [_booking],
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = Size(
    logicalSize.width * pixelRatio,
    logicalSize.height * pixelRatio,
  );
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
    MethodCall call,
  ) async {
    if (call.method == 'checkConnectivity' || call.method == 'check') {
      return <String>['wifi'];
    }
    return null;
  });
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async => null,
  );
  binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(
      onListen: (Object? args, MockStreamHandlerEventSink events) {},
    ),
  );
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          advisorRecentJobCardsProvider.overrideWith((ref) async => jobs),
          advisorAssignedBookingsProvider.overrideWith(
            (ref) async => bookings,
          ),
          // Harness: the header search sheet also reads the approvals feed.
          advisorPendingApprovalsProvider.overrideWith((ref) async => const []),
          advisorPendingSyncCountProvider.overrideWith(
            (ref) => Stream<int>.value(0),
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
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: Scaffold(
                body: AdvisorJobsListView(onJobCard: (_) {}),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);

  if (interact != null) {
    await interact(tester);
    expect(tester.takeException(), isNull);
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

Future<void> _openSearchWithQuery(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Search'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.enterText(find.byType(TextField).first, 'ahmed');
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _applyInspectionFilter(WidgetTester tester) async {
  // No ensureVisible: the Inspection chip is already fully on-screen at
  // 360px (idle frame proves it), and scrolling the rail would leave the
  // selected chip half-clipped at the viewport edge in the golden.
  await tester.tap(find.text('Inspection'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _selectWideRow(WidgetTester tester) async {
  await tester.tap(find.text('Ahmed').first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  setUpAll(() async {
    await _loadFonts();
    final dir = await Directory.systemTemp.createTemp('advisor_jobs_after');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('inspections');
    debugPrint('advisor jobs after capture: fonts ready');
  });

  // ---- idle + states (staff light-only) ----

  testWidgets('after jobs idle en 360x800', (tester) async {
    await _capture(tester, name: 'jobs_1.0_en_360x800.png');
  });

  testWidgets('after jobs empty en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_empty_en_360x800.png',
      jobs: const [],
      bookings: const [],
    );
  });

  testWidgets('after jobs search results en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_search_en_360x800.png',
      interact: _openSearchWithQuery,
    );
  });

  testWidgets('after jobs filter applied en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_filter_en_360x800.png',
      interact: _applyInspectionFilter,
    );
  });

  // ---- locale / scale / size ----

  testWidgets('after jobs idle ar 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_ar_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('after jobs idle 1.3x en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.3_en_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('after jobs idle en 320x568', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_en_320x568.png',
      logicalSize: const Size(320, 568),
    );
  });

  // ---- wide master-detail matrix ----

  testWidgets('after jobs wide en 1280x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_en_1280x800.png',
      logicalSize: const Size(1280, 800),
      pixelRatio: 2.0,
      interact: _selectWideRow,
    );
  });
}
