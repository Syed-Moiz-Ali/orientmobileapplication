// AFTER capture for the supervisor Review list tab (GROUP-C list-ops).
//
// Pumps the CURRENT (recomposed) SupervisorReviewTab with deterministic fakes
// and writes viewport PNGs into docs/ui-redesign/baseline/after-supervisor-review/
// for before/after review. Staff light-only (en + ar 360x800, empty/error/
// loading 360x800, QC sheet entry 360x800, 320x568 data, 1.3x data, tablet
// data). No filter rail (nothing honest to facet — U3); the surface's one
// search path is the scaffold bar bay-search (deviation B).
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/supervisor_review_list_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/supervisor_review_list_after_capture_test.dart                    (compare)
// Default `flutter test` excludes this tag.
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
import 'package:staff_app/features/supervisor/data/datasources/supervisor_remote_datasource.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-supervisor-review';

// ---------------------------------------------------------------- fixtures

const _qcOne = AwaitingCompletionResponse(
  jobCardId: 7,
  jobCardRef: 'JC-207',
  customerName: 'Layla',
  vehicleInfo: 'Yaris XYZ 5678',
  technician: 'Omar Haddad',
  done: 4,
  total: 4,
  updatedAt: '2026-10-20 14:00',
  items: [WorkItemDetail(id: 1, description: 'Change engine oil')],
);

const _qcTwo = AwaitingCompletionResponse(
  jobCardId: 8,
  jobCardRef: 'JC-208',
  customerName: 'Ahmed',
  vehicleInfo: 'Camry ABC 1234',
  technician: 'Sara Ali',
  done: 3,
  total: 5,
  updatedAt: '2026-10-20 15:00',
  items: [WorkItemDetail(id: 2, description: 'Replace brake pads')],
);

class _ReviewData {
  const _ReviewData({
    this.awaiting = const [_qcOne, _qcTwo],
    this.fail = false,
    this.hang = false,
  });

  final List<AwaitingCompletionResponse> awaiting;
  final bool fail;
  final bool hang;
}

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  _FakeSupervisorRemote(this.data);

  final _ReviewData data;

  Future<T> _maybeHang<T>(T value) async {
    if (data.fail) throw Exception('offline');
    if (data.hang) await Completer<void>().future;
    return value;
  }

  @override
  Future<List<KpiResponse>> getKpis() => _maybeHang(const []);
  @override
  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() =>
      _maybeHang(const []);
  @override
  Future<List<JobTypeResponse>> getJobTypes() => _maybeHang(const []);
  @override
  Future<List<RevenueMetricResponse>> getRevenueMetrics() =>
      _maybeHang(const []);
  @override
  Future<List<PendingStatusResponse>> getPendingStatuses() =>
      _maybeHang(const []);
  @override
  Future<List<String>> getDepartments() => _maybeHang(const []);
  @override
  Future<List<String>> getTechnicians() => _maybeHang(const []);
  @override
  Future<List<SupervisorAssignedJob>> getAssignedJobs() =>
      _maybeHang(const <SupervisorAssignedJob>[]);
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() =>
      _maybeHang(const []);
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() =>
      _maybeHang(const []);
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() =>
      _maybeHang(const []);
  @override
  Future<bool> assignBooking(int id, int advisorId) async => true;
  @override
  Future<bool> assignBreakdown(int id, int advisorId) async => true;
  @override
  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() =>
      _maybeHang(List.of(data.awaiting));
  @override
  Future<bool> approveCompletion(int jobCardId) async => true;
  @override
  Future<bool> rejectCompletion(int jobCardId, String reason) async => true;
  @override
  Future<bool> qcReview(
    String jobCardRef,
    String action, {
    bool checklistPassed = true,
    String notes = '',
    String rejectReason = '',
  }) async => true;
  @override
  Future<List<StaffNotificationResponse>> getStaffNotifications() =>
      _maybeHang(const []);
  @override
  Future<bool> markStaffNotificationRead(String id) async => true;
}

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
  _ReviewData data = const _ReviewData(),
  Locale locale = const Locale('en'),
  Size size = const Size(360, 800),
  double scale = 1.0,
  bool refresh = false,
  Future<void> Function(WidgetTester)? interact,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  addTearDown(() => debugDisableShadows = oldShadows);
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      supervisorRemoteDataSourceProvider.overrideWithValue(
        _FakeSupervisorRemote(data),
      ),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
          home: const Scaffold(body: SupervisorReviewTab()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      try {
        if (!container.read(supervisorDashboardProvider).isReviewLoading) {
          break;
        }
      } catch (_) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  if (refresh) {
    // Review error/loading only surface via refreshReview (provider-owned).
    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
  if (interact != null) {
    await interact(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

String _name(String state, double scale, String locale, Size size) =>
    '${state}_light_${scale.toStringAsFixed(1)}_${locale}_${size.width.toInt()}x${size.height.toInt()}.png';

void main() {
  setUp(() {
    final binding = TestDefaultBinaryMessengerBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall call) async => null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall call) async {
        if (call.method == 'checkConnectivity' || call.method == 'check') {
          return 'wifi';
        }
        return null;
      },
    );
  });

  setUpAll(() async {
    await _loadFonts();
    debugPrint('supervisor review after capture: fonts ready');
  });

  testWidgets('after idle light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(360, 800)),
    );
  });

  testWidgets('after idle light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'ar', const Size(360, 800)),
      locale: const Locale('ar'),
    );
  });

  testWidgets('after empty light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('empty', 1.0, 'en', const Size(360, 800)),
      data: const _ReviewData(awaiting: []),
    );
  });

  testWidgets('after error light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('error', 1.0, 'en', const Size(360, 800)),
      data: const _ReviewData(fail: true),
      refresh: true,
    );
  });

  testWidgets('after loading light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('loading', 1.0, 'en', const Size(360, 800)),
      data: const _ReviewData(hang: true),
      refresh: true,
    );
  });

  testWidgets('after qc sheet light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('sheet', 1.0, 'en', const Size(360, 800)),
      interact: (t) async {
        await t.tap(find.text('Start QC').first);
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
      },
    );
  });

  testWidgets('after idle light en 320x568', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(320, 568)),
      size: const Size(320, 568),
    );
  });

  testWidgets('after idle light en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.3, 'en', const Size(360, 800)),
      scale: 1.3,
    );
  });

  testWidgets('after idle light en 768x1024', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(768, 1024)),
      size: const Size(768, 1024),
    );
  });
}
