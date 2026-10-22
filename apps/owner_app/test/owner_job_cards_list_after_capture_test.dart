// AFTER capture for the owner job-cards register (GROUP-C list-ops).
//
// Pumps the CURRENT (recomposed) JobCardsListView with a deterministic fake
// repository and writes viewport PNGs into
// docs/ui-redesign/baseline/after-owner-job-cards/ for before/after review.
// Owner light + dark (dark must not regress), en + ar 360x800, empty/loading
// 360x800, search + milestone-filter 360x800, 320x568 data, 1.3x data, wide
// 1280x800 (table + preview pane, incl. selected preview). U1/C16
// search-first: the header search icon opens the register filter as a full
// sheet over the same provider predicate; no inline field lives in the page
// at any size. No row taps except the wide select (push only fires on tap;
// wide select is in-place preview).
//
// Run (from apps/owner_app):
//   flutter test --tags baseline --update-goldens test/owner_job_cards_list_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/owner_job_cards_list_after_capture_test.dart                    (compare)
// Default `flutter test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/domain/repositories/job_card_repository.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

const _outDir = 'after-owner-job-cards';

// ---------------------------------------------------------------- fixtures

const _wipJob = JobCard(
  id: 'JC-1042',
  customerName: 'Ahmed',
  vehicle: 'Camry',
  plateNumber: 'ABC 1234',
  services: ['Oil change'],
  technician: 'Omar',
  estCompletion: '2026-10-23',
  amount: 2450.0,
  status: JobCardStatus.inProgress,
);

const _qcJob = JobCard(
  id: 'JC-1043',
  customerName: 'Sara',
  vehicle: 'Civic',
  plateNumber: 'DEF 9012',
  services: ['Brake pads'],
  technician: 'Ali',
  estCompletion: '2026-10-24',
  amount: 899.5,
  status: JobCardStatus.qualityCheck,
);

const _readyJob = JobCard(
  id: 'JC-1044',
  customerName: 'Khalid',
  vehicle: 'Hilux',
  plateNumber: 'XYZ 1111',
  services: ['Inspection'],
  technician: 'Omar',
  estCompletion: '2026-10-25',
  amount: 0.0,
  status: JobCardStatus.completed,
);

class _RegisterData {
  const _RegisterData({
    this.cards = const [_wipJob, _qcJob, _readyJob],
    this.hang = false,
  });

  final List<JobCard> cards;
  final bool hang;
}

class _FakeJobCardRepository implements JobCardRepository {
  _FakeJobCardRepository(this.data);

  final _RegisterData data;

  @override
  Future<List<JobCard>> getJobCards() async {
    if (data.hang) await Completer<void>().future;
    return List.of(data.cards);
  }
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

/// Drains the exception queue, tolerating ONLY RenderFlex overflows (owner
/// home precedent: narrow/dense stills keep the overflow striped as redesign
/// evidence instead of failing). Anything else rethrows.
void _drainExpected(WidgetTester tester, String name) {
  Object? error;
  while ((error = tester.takeException()) != null) {
    final current = error;
    if (current is FlutterError && current.message.contains('overflowed')) {
      debugPrint('after capture $name tolerates: ${current.message}');
      continue;
    }
    throw TestFailure('unexpected exception in $name: $current');
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  _RegisterData data = const _RegisterData(),
  Locale locale = const Locale('en'),
  Size size = const Size(360, 800),
  double scale = 1.0,
  bool dark = false,
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
      jobCardRepositoryProvider.overrideWithValue(
        _FakeJobCardRepository(data),
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
            OwnerLocalizations.delegate,
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
          home: const JobCardsListView(),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      if (!container.read(jobCardsProvider).isLoading) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  if (interact != null) {
    await interact(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
  // Extra settle: scrollbar-thumb fades on scrollable stills (320/1.3x/wide)
  // otherwise land mid-fade and flake the compare.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  _drainExpected(tester, name);

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  // Restored here (not only in tearDown): the framework verifies painting
  // invariants before tearDowns run.
  debugDisableShadows = oldShadows;
}

String _name(String state, String theme, double scale, String locale, Size size) =>
    '${state}_${theme}_${scale.toStringAsFixed(1)}_${locale}_${size.width.toInt()}x${size.height.toInt()}.png';

Finder _searchBox() => find.descendant(
  of: find.byType(AppSearchField),
  matching: find.byType(TextField),
);

/// Header search icon (U1/C16 search-first): opens the register filter as a
/// full sheet over the same predicate.
Finder _headerSearchIcon() => find.descendant(
  of: find.byType(WorkspaceAppBar),
  matching: find.byIcon(Icons.search_rounded),
);

Future<void> _tapMilestone(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(AppFilterBar),
    matching: find.text(label),
  );
  expect(chip, findsOneWidget);
  // Wrap mode (U5): chips flow at word boundaries, always in view.
  await tester.tap(chip, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

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
    debugPrint('owner job-cards after capture: fonts ready');
  });

  testWidgets('after idle light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 'light', 1.0, 'en', const Size(360, 800)),
    );
  });

  testWidgets('after idle dark en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 'dark', 1.0, 'en', const Size(360, 800)),
      dark: true,
    );
  });

  testWidgets('after idle light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 'light', 1.0, 'ar', const Size(360, 800)),
      locale: const Locale('ar'),
    );
  });

  testWidgets('after empty light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('empty', 'light', 1.0, 'en', const Size(360, 800)),
      data: const _RegisterData(cards: []),
    );
  });

  testWidgets('after loading light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('loading', 'light', 1.0, 'en', const Size(360, 800)),
      data: const _RegisterData(hang: true),
    );
  });

  testWidgets('after search light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('search', 'light', 1.0, 'en', const Size(360, 800)),
      interact: (t) async {
        // Header icon opens the full search sheet (U1/C16 search-first);
        // typing filters over the same provider predicate.
        await t.tap(_headerSearchIcon());
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
        await t.enterText(_searchBox(), 'sara');
        await t.pump();
        await t.pump(const Duration(milliseconds: 100));
      },
    );
  });

  testWidgets('after filter light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('filter', 'light', 1.0, 'en', const Size(360, 800)),
      interact: (t) => _tapMilestone(t, 'QC'),
    );
  });

  testWidgets('after idle light en 320x568', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 'light', 1.0, 'en', const Size(320, 568)),
      size: const Size(320, 568),
    );
  });

  testWidgets('after idle light en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 'light', 1.3, 'en', const Size(360, 800)),
      scale: 1.3,
    );
  });

  testWidgets('after wide light en 1280x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle-wide', 'light', 1.0, 'en', const Size(1280, 800)),
      size: const Size(1280, 800),
    );
  });

  testWidgets('after wide selected light en 1280x800', (tester) async {
    await _capture(
      tester,
      name: _name('selected-wide', 'light', 1.0, 'en', const Size(1280, 800)),
      size: const Size(1280, 800),
      interact: (t) async {
        await t.tap(find.text('JC-1043').first);
        await t.pump();
        await t.pump(const Duration(milliseconds: 100));
      },
    );
  });
}
