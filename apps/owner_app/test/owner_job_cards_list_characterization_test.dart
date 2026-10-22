// Characterization baseline for the owner job-cards register (GROUP-C list-ops).
//
// Behavior pins against the CURRENT register UI. These tests assert behavior
// only (header count with no header search, inline search predicate,
// milestone filter, presentation sort, compact open + wide select/preview/open
// contracts, empty/no-match/loading affordances, tabular money) — never
// legacy widget types — so they stay green across the App* recomposition and
// become the migration baseline. Do NOT modify these tests after the
// recomposition (see
// docs/ui-redesign/evaluation/owner-job-cards-list-test-migration.md).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/domain/repositories/job_card_repository.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

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

class _FakeJobCardRepository implements JobCardRepository {
  _FakeJobCardRepository(this.cards);

  final List<JobCard> cards;

  @override
  Future<List<JobCard>> getJobCards() async => List.of(cards);
}

class _Marker extends StatelessWidget {
  final String location;
  const _Marker(this.location);

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('at:$location')));
}

GoRouter _router() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const JobCardsListView()),
    GoRoute(
      path: AppRoutes.jobCardDetail,
      builder: (_, s) => _Marker(s.matchedLocation),
    ),
  ],
);

Widget _app(GoRouter router, {Locale locale = const Locale('en')}) =>
    MaterialApp.router(
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
      routerConfig: router,
    );

Future<ProviderContainer> _pumpRegister(
  WidgetTester tester,
  List<JobCard> cards, {
  Size surface = const Size(390, 844),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(surface.width * 3, surface.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      jobCardRepositoryProvider.overrideWithValue(
        _FakeJobCardRepository(cards),
      ),
    ],
  );
  addTearDown(container.dispose);
  final router = _router();
  addTearDown(router.dispose);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(router, locale: locale),
      ),
    );
    for (var i = 0; i < 40; i++) {
      if (!container.read(jobCardsProvider).isLoading) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
  return container;
}

Finder _searchBox() => find.descendant(
  of: find.byType(AppSearchField),
  matching: find.byType(TextField),
);

/// Taps a milestone chip inside the shared filter bar (the table header and
/// the preview pane never repeat these labels, so the bar scope keeps the
/// finder unambiguous).
Future<void> _tapFilter(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(AppFilterBar),
    matching: find.text(label),
  );
  expect(chip, findsOneWidget);
  // The six-chip rail scrolls horizontally: one drag reveals the later chips
  // (the `findsOneWidget` passes while the chip is still off-screen, so the
  // assertion after the tap is what proves the tap landed).
  final rail = find.descendant(
    of: find.byType(AppFilterBar),
    matching: find.byType(Scrollable),
  );
  await tester.drag(rail.first, const Offset(-300, 0));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
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

  testWidgets('header shows title, subtitle and live count, no header search', (
    tester,
  ) async {
    await _pumpRegister(tester, const [_wipJob, _qcJob, _readyJob]);

    expect(find.text('Job register'), findsWidgets);
    expect(find.text('All active workshop jobs'), findsOneWidget);
    expect(find.text('3 jobs'), findsOneWidget);
    // Audited single affordance: the inline field below owns search; the app
    // bar carries no search entry point at any size.
    expect(find.byType(AppSearchField), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WorkspaceAppBar),
        matching: find.byIcon(Icons.search_rounded),
      ),
      findsNothing,
    );
  });

  testWidgets('compact rows render identity, tabular money and status', (
    tester,
  ) async {
    await _pumpRegister(tester, const [_wipJob, _qcJob, _readyJob]);

    expect(find.text('JC-1042'), findsWidgets);
    expect(find.text('Ahmed'), findsWidgets);
    expect(find.text('Camry · ABC 1234'), findsOneWidget);
    // Fixed-cents tabular money, verbatim; zero renders as AED 0.00 (U11).
    expect(find.textContaining('AED 2,450.00'), findsWidgets);
    expect(find.textContaining('AED 0.00'), findsWidgets);
    // Status pills come from the real JobCardStatus only, upper-cased by the
    // shared helper (also serving the detail view — STOP boundary, kept
    // byte-identical; see the migration doc).
    expect(find.text('IN PROGRESS'), findsWidgets);
    expect(find.text('QUALITY CHECK'), findsWidgets);
    expect(find.text('COMPLETED'), findsWidgets);
  });

  testWidgets('inline search narrows by customer, plate and job ref', (
    tester,
  ) async {
    await _pumpRegister(tester, const [_wipJob, _qcJob, _readyJob]);

    await tester.enterText(_searchBox(), 'sara');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-1043'), findsWidgets);
    expect(find.text('JC-1042'), findsNothing);
    expect(find.text('JC-1044'), findsNothing);

    await tester.enterText(_searchBox(), 'XYZ 1111');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-1044'), findsWidgets);
    expect(find.text('JC-1043'), findsNothing);
  });

  testWidgets('milestone rail filters and re-tap clears', (tester) async {
    await _pumpRegister(tester, const [_wipJob, _qcJob, _readyJob]);

    await _tapFilter(tester, 'QC');
    expect(find.text('JC-1043'), findsWidgets);
    expect(find.text('JC-1042'), findsNothing);
    expect(find.text('JC-1044'), findsNothing);

    // Re-tap clears: the selected chip is already in view (rail keeps its
    // scroll offset), so no drag is needed the second time.
    await tester.tap(
      find.descendant(
        of: find.byType(AppFilterBar),
        matching: find.text('QC'),
      ),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-1042'), findsWidgets);
    expect(find.text('JC-1043'), findsWidgets);
    expect(find.text('JC-1044'), findsWidgets);
  });

  testWidgets('compact row tap opens the job audit', (tester) async {
    await _pumpRegister(tester, const [_wipJob, _qcJob, _readyJob]);

    await tester.tap(find.text('JC-1042').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.text('at:${AppRoutes.jobCardDetail}'), findsOneWidget);
  });

  testWidgets('wide row select previews then opens the audit', (tester) async {
    await _pumpRegister(
      tester,
      const [_wipJob, _qcJob, _readyJob],
      surface: const Size(1280, 800),
    );

    // Nothing selected yet: the pane prompts honestly, no dead CTA.
    expect(find.textContaining('Select a job to preview.'), findsOneWidget);

    await tester.tap(find.text('JC-1043').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Select a job to preview.'), findsNothing);
    // Preview carries the same dossier-mini (pill + tabular total).
    expect(find.textContaining('AED 899.50'), findsWidgets);

    await tester.tap(find.text('Open register'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('at:${AppRoutes.jobCardDetail}'), findsOneWidget);
  });

  testWidgets('empty register shows the empty state', (tester) async {
    await _pumpRegister(tester, const []);

    expect(find.textContaining('No job cards found.'), findsOneWidget);
    expect(find.text('JC-1042'), findsNothing);
  });

  testWidgets('no match shows the no-match state and clears', (tester) async {
    await _pumpRegister(tester, const [_wipJob]);

    await tester.enterText(_searchBox(), 'zzz-no-such-job');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.textContaining('No jobs match this search.'),
      findsOneWidget,
    );

    await tester.enterText(_searchBox(), '');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-1042'), findsWidgets);
  });

  testWidgets('sort header re-orders without mutating the provider list', (
    tester,
  ) async {
    final container = await _pumpRegister(
      tester,
      const [_wipJob, _qcJob, _readyJob],
      surface: const Size(1280, 800),
    );

    // Provider order is load order (untouched by presentation sorting).
    expect(
      container.read(jobCardsProvider).all.map((j) => j.id).toList(),
      ['JC-1042', 'JC-1043', 'JC-1044'],
    );

    // Tapping a sortable header only re-orders the rendered table.
    await tester.tap(find.text('Customer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-1042'), findsWidgets);
    expect(
      container.read(jobCardsProvider).all.map((j) => j.id).toList(),
      ['JC-1042', 'JC-1043', 'JC-1044'],
    );
  });
}
