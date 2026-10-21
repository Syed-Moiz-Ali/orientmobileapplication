// THROWAWAY BASELINE CAPTURE (phase-0a safety net).
//
// Pumps the real crm_app root with the REAL bundled fonts and shadows on,
// then writes PNGs into docs/ui-redesign/baseline/ for before/after diffing.
// No app code is modified; all fakes live in this file.
//
// Backend + fonts initialize in setUpAll (REAL async): Hive-style file I/O
// hangs under the testWidgets FakeAsync clock, so nothing async-backend may
// run inside test bodies. This screen needs no Hive (login path only; the
// auth restore path guards unopened boxes itself).
//
// Run (from apps/crm_app):
//   flutter test --tags baseline --update-goldens test/baseline_capture_test.dart   (generate)
//   flutter test --tags baseline test/baseline_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag (see melos.yaml).
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:crm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Test-only backend fakes: dotenv override (no .env asset in tests),
/// flutter_secure_storage stubbed to "no session", connectivity_plus stubbed
/// to offline with a silent stream.
Future<void> _initTestBackend() async {
  EnvironmentConfig.setBaseUrlForTesting('https://baseline.test');

  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async => null,
  );
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall call) async {
      if (call.method == 'checkConnectivity' || call.method == 'check') {
        return <String>['none'];
      }
      return null;
    },
  );
  binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(
      onListen: (Object? args, MockStreamHandlerEventSink events) {},
    ),
  );
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

void main() {
  setUpAll(() async {
    await _initTestBackend();
    await _loadRealFonts();
    await _loadMaterialIcons();
    debugPrint('baseline: backend + fonts ready');
  });

  testWidgets('baseline crm light (real app root)', (tester) async {
    // Shadows ON for capture; restored inline before the framework's
    // painting invariant check (addTearDown is too late for it).
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(1170, 2532); // 390x844 @3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // runAsync: the auth restore only completes on real event-loop turns
    // (fake-clock pumps alone leave the splash up forever — see phase-0a
    // notes). Fixed frames only, never pumpAndSettle.
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: CrmApp()));
      await tester.pump();
      await Future<void>.delayed(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
    // Let the splash -> login redirect transition finish before capture.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('baseline: pumped frames done');

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../docs/ui-redesign/baseline/after-phase-2/crm_login_one_screen_idle_light_1.0_en_390x844.png'),
    );
    debugDisableShadows = true;
  });
}
