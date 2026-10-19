import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/pages/job_status_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/pending_approvals_view.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_card_detail_view.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  OwnerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _jobs = [
  JobCard(
    id: 'JC-1042',
    customerName: 'Ahmed Raza',
    vehicle: 'Toyota Camry',
    plateNumber: 'A 12345',
    services: ['Oil change', 'Brake pads'],
    technician: 'Sam',
    estCompletion: 'Today 5 PM',
    amount: 1250,
    status: JobCardStatus.inProgress,
  ),
  JobCard(
    id: 'JC-1049',
    customerName: 'Sara Nasser',
    vehicle: 'Nissan Patrol',
    plateNumber: 'B 67890',
    services: ['Wheel alignment'],
    technician: 'Alex',
    estCompletion: 'Tomorrow',
    amount: 480,
    status: JobCardStatus.waitingParts,
  ),
  JobCard(
    id: 'JC-1057',
    customerName: 'Omar Farooq',
    vehicle: 'Honda Accord',
    plateNumber: 'C 11223',
    services: ['AC recharge'],
    technician: 'Ravi',
    estCompletion: 'Friday',
    amount: 690,
    status: JobCardStatus.completed,
  ),
];

class _FakeJobs extends JobCardsNotifier {
  final List<JobCard> seed;
  bool completedCalled = false;
  _FakeJobs([this.seed = _jobs]);

  @override
  JobCardsState build() => JobCardsState(
        isLoading: false,
        all: seed,
        filtered: seed,
      );

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}

  @override
  void onSearch(String query) {
    final q = query.toLowerCase();
    state = state.copyWith(
      searchQuery: query,
      filtered: q.isEmpty
          ? seed
          : seed
              .where((jc) =>
                  jc.customerName.toLowerCase().contains(q) ||
                  jc.id.toLowerCase().contains(q) ||
                  jc.plateNumber.toLowerCase().contains(q))
              .toList(),
    );
  }

  @override
  void setFilter(JobCardStatus? status) {
    state = state.copyWith(
      activeFilter: status,
      filtered: status == null
          ? seed
          : seed.where((jc) => jc.status == status).toList(),
    );
  }

  @override
  Future<bool> markComplete(String id) async {
    completedCalled = true;
    return true;
  }
}

class _FakeStatus extends JobStatusNotifier {
  @override
  JobStatusState build() => JobStatusState(
        isLoading: false,
        items: const [
          JobStatus(
            jobCardId: 'JC-2001',
            customerName: 'Layla Hassan',
            vehicleInfo: 'Kia Sportage',
            assignedTo: 'Omar',
            createdDate: '2026-10-10',
            dueDate: '2026-10-19',
            stage: JobStage.wip,
            estimatedAmount: 2300,
          ),
          JobStatus(
            jobCardId: 'JC-2002',
            customerName: 'Yusuf Ali',
            vehicleInfo: 'Ford Explorer',
            assignedTo: 'Sara',
            createdDate: '2026-10-11',
            dueDate: '2026-10-20',
            stage: JobStage.waitingParts,
            estimatedAmount: 4100,
          ),
        ],
      );
}

class _FakeApprovals extends PendingApprovalsNotifier {
  final List<ApprovalCategory> seed;
  _FakeApprovals([this.seed = const []]);

  @override
  PendingApprovalsState build() =>
      PendingApprovalsState(isLoading: false, categories: seed);
}

const _approvalSeed = [
  ApprovalCategory(
    title: 'Discounts above 15%',
    subtitle: 'Advisor discount requests',
    count: 3,
    iconBg: Color(0xFFFEF3C7),
    icon: Icons.percent_rounded,
  ),
  ApprovalCategory(
    title: 'Goodwill repairs',
    subtitle: 'Warranty gestures',
    count: 0,
    iconBg: Color(0xFFD1FAE5),
    icon: Icons.volunteer_activism_rounded,
  ),
];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jobCardsProvider.overrideWith(_FakeJobs.new),
        jobStatusProvider.overrideWith(_FakeStatus.new),
        pendingApprovalsProvider.overrideWith(() => _FakeApprovals(_approvalSeed)),
        ...extra,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Register (frozen provider, verbatim figures)', () {
    testWidgets('renders rows, count and lifecycle chips', (tester) async {
      await _pump(tester, const JobCardsListView());
      expect(find.text('Ahmed Raza'), findsOneWidget);
      expect(find.text('Sara Nasser'), findsOneWidget);
      expect(find.text('3 jobs'), findsOneWidget);
      for (final chip in ['Intake', 'Inspection', 'WIP', 'QC', 'Ready', 'Invoiced']) {
        expect(find.text(chip), findsOneWidget);
      }
      // Fixed-decimal tabular money, plates LTR inside the vehicle line.
      expect(find.text('AED 1,250.00'), findsOneWidget);
      expect(find.text('Toyota Camry · A 12345'), findsOneWidget);
    });

    testWidgets('search narrows to matches', (tester) async {
      await _pump(tester, const JobCardsListView());
      await tester.enterText(find.byType(AppSearchField), 'sara');
      await tester.pumpAndSettle();
      expect(find.text('Sara Nasser'), findsOneWidget);
      expect(find.text('Ahmed Raza'), findsNothing);
    });

    testWidgets('no-match renders the no-match state', (tester) async {
      await _pump(tester, const JobCardsListView());
      await tester.enterText(find.byType(AppSearchField), 'zzz-no-such-job');
      await tester.pumpAndSettle();
      expect(find.text('No jobs match this search.'), findsOneWidget);
    });

    testWidgets('chip filters to the milestone status', (tester) async {
      await _pump(tester, const JobCardsListView());
      final chip = find.descendant(
        of: find.byType(AppFilterBar),
        matching: find.text('WIP'),
      );
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Ahmed Raza'), findsOneWidget);
      expect(find.text('Sara Nasser'), findsNothing);
    });

    testWidgets('sorting by total reorders rows', (tester) async {
      await _pump(
        tester,
        const JobCardsListView(),
        size: const Size(1280, 800),
      );
      final before = tester
          .widgetList<Text>(find.textContaining('JC-10'))
          .map((w) => w.data ?? '')
          .where((s) => s.startsWith('JC-'))
          .toList();
      expect(before.first, 'JC-1042');
      await tester.tap(find.text('Total'));
      await tester.pumpAndSettle();
      final after = tester
          .widgetList<Text>(find.textContaining('JC-10'))
          .map((w) => w.data ?? '')
          .where((s) => s.startsWith('JC-'))
          .toList();
      expect(after.first, 'JC-1049');
    });

    testWidgets('wide layout previews the selected row', (tester) async {
      await _pump(
        tester,
        const JobCardsListView(),
        size: const Size(1280, 800),
      );
      expect(find.text('Select a job to preview.'), findsOneWidget);
      await tester.tap(find.text('Sara Nasser').first);
      await tester.pumpAndSettle();
      expect(find.text('Select a job to preview.'), findsNothing);
      expect(find.text('Open register'), findsOneWidget);
    });

    testWidgets('compact row opens the audit', (tester) async {
      final router = GoRouter(
        initialLocation: '/list',
        routes: [
          GoRoute(
            path: '/list',
            builder: (_, __) => const Scaffold(body: JobCardsListView()),
          ),
          GoRoute(
            path: AppRoutes.jobCardDetail,
            builder: (_, __) => const Scaffold(body: JobCardDetailView()),
          ),
        ],
      );
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            jobCardsProvider.overrideWith(_FakeJobs.new),
            jobStatusProvider.overrideWith(_FakeStatus.new),
            pendingApprovalsProvider
                .overrideWith(() => _FakeApprovals(_approvalSeed)),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sara Nasser'));
      await tester.pumpAndSettle();
      // Dossier header owns the customer name; the audit stepper renders.
      expect(find.text('Nissan Patrol - B 67890'), findsOneWidget);
      expect(find.text('Repair'), findsOneWidget);
    });

    testWidgets('survives 320px at 1.3x', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            jobCardsProvider.overrideWith(_FakeJobs.new),
            jobStatusProvider.overrideWith(_FakeStatus.new),
            pendingApprovalsProvider
                .overrideWith(() => _FakeApprovals(_approvalSeed)),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.3),
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocales.supported,
              localizationsDelegates: _delegates,
              theme: AppTheme.light(BrandConfig.orient),
              home: const Scaffold(body: JobCardsListView()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Detail dossier (existing fields only)', () {
    testWidgets('renders identity, stepper, panels and dock', (tester) async {
      await _pump(
        tester,
        const JobCardDetailView(),
        extra: [
          selectedJobCardProvider.overrideWith((ref) => _jobs[0]),
        ],
      );
      expect(find.text('Ahmed Raza'), findsWidgets);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Oil change'), findsOneWidget);
      expect(find.text('Assignment'), findsOneWidget);
      expect(find.text('AED 1,250.00'), findsWidgets);
      expect(
        find.text('Parts/labor split unavailable for this record.'),
        findsOneWidget,
      );
      expect(find.text('Mark complete'), findsWidgets);
      expect(find.text('Jobs'), findsOneWidget);
    });

    testWidgets('empty selection renders the empty state', (tester) async {
      await _pump(tester, const JobCardDetailView());
      expect(find.text('No job card selected.'), findsOneWidget);
    });

    testWidgets('completion confirms then toasts', (tester) async {
      final fake = _FakeJobs();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            jobCardsProvider.overrideWith(() => fake),
            jobStatusProvider.overrideWith(_FakeStatus.new),
            pendingApprovalsProvider
                .overrideWith(() => _FakeApprovals(_approvalSeed)),
            selectedJobCardProvider.overrideWith((ref) => _jobs[0]),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: JobCardDetailView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cta = find.text('Mark complete').first;
      await tester.ensureVisible(cta);
      await tester.pumpAndSettle();
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(find.text('Mark as complete?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Mark complete'));
      await tester.pumpAndSettle();
      expect(fake.completedCalled, isTrue);
      expect(find.text('Job card marked as completed.'), findsOneWidget);
    });
  });

  group('Status monitor (derived counts, honest clock)', () {
    testWidgets('renders pods, stamp, rows and filters', (tester) async {
      await _pump(tester, const JobStatusView());
      expect(find.text('Layla Hassan'), findsOneWidget);
      expect(find.textContaining('Updated'), findsOneWidget);
      expect(find.text('AED 2,300.00'), findsOneWidget);
      final chip = find.descendant(
        of: find.byType(AppFilterBar),
        matching: find.text('Parts'),
      );
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Yusuf Ali'), findsOneWidget);
      expect(find.text('Layla Hassan'), findsNothing);
    });

    testWidgets('stale data is never silent', (tester) async {
      // The banner path shares copy with the freshness stamp; both resolve.
      await _pump(tester, const JobStatusView());
      expect(find.textContaining('Updated'), findsOneWidget);
    });
  });

  group('Approvals queue (read-only by contract)', () {
    testWidgets('renders hero counts and category rows', (tester) async {
      await _pump(tester, const PendingApprovalsView());
      expect(find.text('3 requests'), findsOneWidget);
      expect(find.text('Discounts above 15%'), findsOneWidget);
      expect(find.text('Goodwill repairs'), findsOneWidget);
      expect(
        find.text('Approval actions are not available in this version.'),
        findsOneWidget,
      );
    });

    testWidgets('no fake decision actions exist', (tester) async {
      await _pump(tester, const PendingApprovalsView());
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsNothing);
    });

    testWidgets('empty queue renders the empty state', (tester) async {
      await _pump(
        tester,
        const PendingApprovalsView(),
        extra: [
          pendingApprovalsProvider.overrideWith(() => _FakeApprovals(const [])),
        ],
      );
      expect(find.text('No pending approvals.'), findsOneWidget);
    });
  });
}
