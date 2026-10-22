// BEFORE capture for the advisor jobs register (GROUP-B screen 1).
//
// Pumps the CURRENT AdvisorJobsListView with deterministic fakes and writes
// viewport PNGs into docs/ui-redesign/baseline/before-advisor-jobs/ for
// before/after review. Staff light-only (en + ar 360x800, empty 360x800,
// 320x568 data, 1280x800 wide matrix). Frozen record: do NOT --update-goldens
// this file after the recomposition. (Screen 2 — inspection / repair-order
// lists — has no separate surface; see
// docs/ui-redesign/briefs/advisor-inspection-repairorder-lists.md.)
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/advisor_jobs_before_capture_test.dart   (generate)
//   flutter test --tags baseline test/advisor_jobs_before_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'before-advisor-jobs';

// ---------------------------------------------------------------- fixtures
// Same deterministic register as advisor_jobs_characterization_test.dart: one
// card per filter key (intake / inspection / approved / wip / ready) + one
// assigned booking so the intake-queue section renders in the data frames.

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

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required List<JobCardEntity> jobs,
  required List<AdvisorBookingResponse> bookings,
  Locale locale = const Locale('en'),
  Size size = const Size(360, 800),
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorRecentJobCardsProvider.overrideWith((ref) async => jobs),
        advisorAssignedBookingsProvider.overrideWith((ref) async => bookings),
        advisorPendingSyncCountProvider.overrideWith(
          (ref) => Stream<int>.value(0),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          StaffLocalizations.delegate,
          SharedCoreLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: AdvisorJobsListView(onJobCard: (_) {})),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  setUpAll(() async {
    await _loadFonts();
    debugPrint('advisor jobs before capture: fonts ready');
  });

  testWidgets('before jobs light en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_en_360x800.png',
      jobs: _jobs,
      bookings: const [_booking],
    );
  });

  testWidgets('before jobs light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_ar_360x800.png',
      jobs: _jobs,
      bookings: const [_booking],
      locale: const Locale('ar'),
    );
  });

  testWidgets('before jobs empty en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_empty_en_360x800.png',
      jobs: const [],
      bookings: const [],
    );
  });

  testWidgets('before jobs light en 320x568', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_en_320x568.png',
      jobs: _jobs,
      bookings: const [_booking],
      size: const Size(320, 568),
    );
  });

  testWidgets('before jobs wide en 1280x800', (tester) async {
    await _capture(
      tester,
      name: 'jobs_1.0_en_1280x800.png',
      jobs: _jobs,
      bookings: const [_booking],
      size: const Size(1280, 800),
    );
  });
}
