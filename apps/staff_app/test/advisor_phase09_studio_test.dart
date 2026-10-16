import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_local_datasource.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/repair_order_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 09 — studio tier + state widget tests.
///
/// The deterministic safety split lives in `classifyRepairTier` (unit-tested
/// in `advisor_phase09_estimates_test.dart`); these tests pin the
/// presentation contract on top: both tiers open on arrival, either tier
/// collapses and reopens, search auto-opens tiers, category headers pin as
/// slivers, and loading/error/no-match states render with retry.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Slivers build lazily below the fold: drag until the target is built (or
/// give up after a full-length scroll), so below-fold assertions are real.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 8 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await _settle(tester);
  }
}

const _seed = InspectionState(
  serviceLines: [
    ServiceLineItem(name: 'Brake pads replacement', qty: 1, rate: 180),
    ServiceLineItem(name: 'Wheel alignment', qty: 1, rate: 150),
  ],
  partLines: [
    PartLineItem(name: 'Brake pad set', qty: 2, rate: 220),
    PartLineItem(name: 'Oil filter', qty: 1, rate: 45),
  ],
  jobCardId: 'JC-1042',
);

class _SeededInspection extends InspectionNotifier {
  final InspectionState seed;
  _SeededInspection(this.seed);

  @override
  InspectionState build() => seed;
}

class _FakeLocal implements AdvisorLocalDataSource {
  @override
  Future<void> saveDraft(Map<String, dynamic> data) async {}

  @override
  Map<String, dynamic>? getDraft() => null;

  @override
  Future<Map<String, dynamic>?> getDraftAsync() async => null;

  @override
  Future<void> deleteDraft() async {}

  @override
  Future<void> saveInspection(String id, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>?> getInspection(String id) async => null;

  @override
  Future<void> save(String id, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>?> get(String id) async => null;

  @override
  Future<List<Map<String, dynamic>>> getAll() async => const [];

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clear() async {}
}

class _FakeRemote implements AdvisorRemoteDataSource {
  @override
  Future<List<WorkItemResponse>> getWorkItems(String jobCardRef) async =>
      const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpStudio(
  WidgetTester tester,
  InspectionState seed, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inspectionProvider.overrideWith(() => _SeededInspection(seed)),
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: StaffLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: RepairOrderView(onBack: () {}),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  group('tier groups (Mandatory expanded, Optional collapsible)', () {
    testWidgets('both tiers open on arrival with every line visible',
        (tester) async {
      await _pumpStudio(tester, _seed);
      final t =
          await StaffLocalizations.delegate.load(const Locale('en'));

      expect(find.text(t.advisorStudioTierMandatory), findsOneWidget);
      await _reveal(tester, find.text(t.advisorStudioTierOptional));
      expect(find.text(t.advisorStudioTierOptional), findsOneWidget);
      // Mandatory lines render in the first viewport already.
      expect(find.text('Brake pad set'), findsOneWidget);
      await _reveal(tester, find.text('Brake pads replacement'));
      expect(find.text('Brake pads replacement'), findsOneWidget);
      await _reveal(tester, find.text('Wheel alignment'));
      expect(find.text('Wheel alignment'), findsOneWidget);
      await _reveal(tester, find.text('Oil filter'));
      expect(find.text('Oil filter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapsing Optional hides its lines, reopening restores',
        (tester) async {
      await _pumpStudio(tester, _seed);
      final t =
          await StaffLocalizations.delegate.load(const Locale('en'));

      await _reveal(tester, find.text(t.advisorStudioTierOptional));
      await tester.tap(find.text(t.advisorStudioTierOptional));
      await _settle(tester);

      expect(find.text('Wheel alignment'), findsNothing);
      expect(find.text('Oil filter'), findsNothing);
      // Mandatory group is untouched: its lines reveal on scroll.
      await _reveal(tester, find.text('Brake pads replacement'));
      expect(find.text('Brake pads replacement'), findsOneWidget);
      await _reveal(tester, find.text('Brake pad set'));
      expect(find.text('Brake pad set'), findsOneWidget);

      await _reveal(tester, find.text(t.advisorStudioTierOptional));
      await tester.tap(find.text(t.advisorStudioTierOptional));
      await _settle(tester);

      await _reveal(tester, find.text('Wheel alignment'));
      expect(find.text('Wheel alignment'), findsOneWidget);
      await _reveal(tester, find.text('Oil filter'));
      expect(find.text('Oil filter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search auto-opens a collapsed tier for its match',
        (tester) async {
      await _pumpStudio(tester, _seed);
      final t =
          await StaffLocalizations.delegate.load(const Locale('en'));

      await _reveal(tester, find.text(t.advisorStudioTierOptional));
      await tester.tap(find.text(t.advisorStudioTierOptional));
      await _settle(tester);
      expect(find.text('Oil filter'), findsNothing);

      // The search box lives at the top: scroll home before typing.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 2000));
      await _settle(tester);
      await tester.enterText(find.byType(AppSearchField), 'oil');
      await _settle(tester);

      await _reveal(tester, find.text('Oil filter'));
      expect(find.text('Oil filter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('category headers pin as slivers', (tester) async {
      await _pumpStudio(tester, _seed);

      // The first viewport already pins the Mandatory parts header; the
      // rest pin as their categories scroll into range.
      expect(find.byType(SliverPersistentHeader), findsWidgets);
      await _reveal(tester, find.text('SUBLET'));
      expect(find.text('SUBLET'), findsOneWidget);
      expect(find.byType(SliverPersistentHeader), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('studio states', () {
    testWidgets('empty estimate with failed load shows error and retry',
        (tester) async {
      await _pumpStudio(
        tester,
        const InspectionState(jobCardId: 'JC-1042'),
      );
      final t =
          await StaffLocalizations.delegate.load(const Locale('en'));

      // The fake remote throws on getJobCard, so the load fails with no
      // lines to show: the error state (not blank space) owns the pane.
      expect(find.text(t.advisorStudioError), findsOneWidget);

      // Retry re-runs the load; the fake still fails, so the error persists
      // instead of stranding the advisor on a spinner.
      await tester.tap(find.textContaining('etry'));
      await _settle(tester);
      expect(find.text(t.advisorStudioError), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('arabic renders tiers without exceptions', (tester) async {
      await _pumpStudio(tester, _seed, locale: const Locale('ar'));
      final t = await StaffLocalizations.delegate.load(const Locale('ar'));

      expect(find.text(t.advisorStudioTierMandatory), findsOneWidget);
      await _reveal(tester, find.text(t.advisorStudioTierOptional));
      expect(find.text(t.advisorStudioTierOptional), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
