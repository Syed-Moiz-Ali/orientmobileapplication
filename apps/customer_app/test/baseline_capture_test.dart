// THROWAWAY BASELINE CAPTURE (phase-0a safety net).
//
// Pumps the real customer_app UI with the REAL bundled fonts and shadows on,
// then writes PNGs into docs/ui-redesign/baseline/ for before/after diffing.
// No app code is modified; all fakes live in this file.
//
// Run (from apps/customer_app):
//   flutter test --tags baseline --update-goldens test/baseline_capture_test.dart   (generate)
//   flutter test --tags baseline test/baseline_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag (see melos.yaml).
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:customer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Backend fakes so the REAL app root pumps without Firebase/Hive/dotenv.
///
/// Allowed by the phase-0a brief ("first try provider overrides / fakes in
/// the test itself"): dotenv gets a test override, flutter_secure_storage is
/// stubbed to "no session" (logged-out baseline), connectivity_plus is
/// stubbed to offline with a silent stream (otherwise the real SyncEngine's
/// platform-channel subscription hangs/fails the fake-async clock), and Hive
/// is initialized on a temp dir with the same boxes/adapters as
/// [HiveRegistry] (no path_provider in tests).
Future<void> _initTestBackend() async {
  EnvironmentConfig.setBaseUrlForTesting('https://baseline.test');

  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async => null,
  );
  // connectivity_plus MethodChannel: always offline so SyncEngine never
  // attempts network. (Real app only ever sees offline in this harness.)
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall call) async {
      // connectivity_plus v6 uses 'checkConnectivity', the v7 platform
      // interface uses 'check'. Both must resolve offline, otherwise the
      // SyncEngine's initial check throws and login never settles.
      if (call.method == 'checkConnectivity' || call.method == 'check') {
        return <String>['none'];
      }
      return null;
    },
  );
  // connectivity_plus EventChannel: silent stream, no events, no errors.
  binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(onListen: (Object? args, MockStreamHandlerEventSink events) {}),
  );

  debugPrint('baseline: channels mocked');
  if (!Hive.isBoxOpen('sync_queue')) {
    debugPrint('baseline: opening hive boxes');
    final dir = await Directory.systemTemp.createTemp('baseline_hive');
    Hive.init(dir.path);
    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(ChangeTypeAdapter());
    await Hive.openBox<dynamic>('inspections');
    await Hive.openBox<dynamic>('repair_orders');
    await Hive.openBox<dynamic>('technician_jobs');
    await Hive.openBox<dynamic>('supervisor_assignments');
    await Hive.openBox<dynamic>('customer_bookings');
    await Hive.openBox<dynamic>('customer_breakdowns');
    await Hive.openBox<dynamic>('customer_cache');
    await Hive.openBox<dynamic>('owner_messages');
    await Hive.openBox<dynamic>('owner_activity');
    await Hive.openBox<SyncOperation>('sync_queue');
    await Hive.openBox<SyncOperation>('sync_failed');
    await Hive.openBox<dynamic>('pending_media');
    await Hive.openBox<int>('id_counters');
    await Hive.openBox<dynamic>('settings');
  }
}

Future<void> _loadRealFonts() async {
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

  const root = '../../packages/shared_core/assets/fonts';
  await load('packages/shared_core/Plus Jakarta Sans', [
    '$root/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
  ]);
}

/// Loads the real MaterialIcons font so icons render instead of tofu boxes.
///
/// Resolved from the enclosing Flutter SDK (walk-up from the test runner
/// executable): `<sdk>/bin/cache/artifacts/material_fonts/`.
/// All four apps + shared packages declare `uses-material-design: true` and
/// use only Material `Icons.*` (zero Cupertino/custom icon fonts in the
/// captured screens), so this one family completes the harness.
Future<void> _loadMaterialIcons() async {
  var dir = Directory(Platform.resolvedExecutable).parent;
  File? found;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      found = candidate;
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  if (found == null) {
    debugPrint('baseline: WARNING MaterialIcons not found; icons stay tofu');
    return;
  }
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(found.readAsBytesSync())));
  await loader.load();
  debugPrint('baseline: material icons loaded from ${found.path}');
}

void _phoneSurface(WidgetTester tester) {
  // Shadows stay ON for the capture (debugDisableShadows = false) and are
  // restored inline at the end of each test: the framework's painting
  // invariant check runs before addTearDown callbacks, so restoring in a
  // tearDown is too late.
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(1170, 2532); // 390x844 @3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void _restoreShadows() => debugDisableShadows = true;

/// Pumps the real app and waits out the async auth restore.
///
/// Proven by probe (auth_probe_test.dart): the restore future only completes
/// on real event-loop turns — fake-clock pumps alone leave the app on the
/// "Restoring your session" splash forever. So the pump sequence runs inside
/// [tester.runAsync] with one real delay, then normal fake frames rebuild
/// the redirected login screen. Fixed frames only (never pumpAndSettle):
/// sync/connectivity timers in the real app root must not hang the harness.
Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(ProviderScope(child: app));
    await tester.pump();
    await Future<void>.delayed(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
  // The router redirects splash -> login only after the restore lands; the
  // 250ms page transition must finish before capture or the golden shows a
  // mid-fade splash. These fake-clock pumps are safe (no pumpAndSettle).
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  if (find.text('Restoring your session').evaluate().isNotEmpty) {
    debugPrint('baseline: WARNING splash still showing');
  } else {
    debugPrint('baseline: pumped frames done');
  }
}

void main() {
  // Backend + fonts initialize in setUpAll (REAL async). They must NOT run
  // inside testWidgets bodies: Hive's file I/O hangs under the FakeAsync
  // clock (proven by probe: plain-test Hive is instant, testWidgets Hive
  // never completes).
  setUpAll(() async {
    await _initTestBackend();
    await _loadRealFonts();
    await _loadMaterialIcons();
    debugPrint('baseline: backend + fonts ready');
  });

  testWidgets('baseline customer light (real app root)', (tester) async {
    _phoneSurface(tester);

    await _pumpApp(tester, const CustomerApp());

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../../../docs/ui-redesign/baseline/customer_light.png',
      ),
    );
    _restoreShadows();
  });

  testWidgets('baseline customer dark (shared login under AppTheme.dark)',
      (tester) async {
    _phoneSurface(tester);

    // CustomerApp hardcodes ThemeMode.light; the dark baseline therefore
    // pumps the exact screen the logged-out customer sees (LoginView, with
    // registration enabled as in the customer router) under the real dark
    // theme. This guards the dark token path phase-0b must not regress.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(BrandConfig.orient),
          darkTheme: AppTheme.dark(BrandConfig.orient),
          themeMode: ThemeMode.dark,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            CustomerLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LoginView(
            onLoginSuccess: () {},
            allowRegistration: true,
            appName: 'Orient Customer',
            appPurpose: 'Track bookings, approvals and service updates.',
            intendedUsers: 'Customers',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../../../docs/ui-redesign/baseline/customer_dark.png',
      ),
    );
    _restoreShadows();
  });
}
