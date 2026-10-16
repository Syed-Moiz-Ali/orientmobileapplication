import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  group('dispatch flow', () {
    testWidgets('tapping a bay opens the dispatch sheet', (tester) async {
      var opened = false;
      final fake = _RecordingNotifier();
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () => opened = true,
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
        notifier: fake,
      );
      await tester.tap(find.text('B-01'));
      await tester.pump();
      expect(opened, isTrue);
    });

    testWidgets('selecting a technician then dispatching records the tech', (
      tester,
    ) async {
      final fake = _RecordingNotifier();
      await _pump(tester, const SupervisorAssignSheet(), notifier: fake);
      await tester.tap(find.text('Alex Morgan'));
      await tester.pump();
      await tester.tap(find.text('Dispatch'));
      await tester.pumpAndSettle();
      expect(fake.dispatchedTechs, contains('Alex Morgan'));
    });
  });

  group('QC review flow', () {
    testWidgets('approve calls qcReview(approve) once all checkpoints pass', (
      tester,
    ) async {
      final fake = _RecordingNotifier();
      await _pump(tester, const SupervisorReviewTab(), notifier: fake);
      await tester.tap(find.text('Start QC'));
      await tester.pumpAndSettle();

      // Check all four standard checkpoints + repair items.
      for (final label in [
        'Road test',
        'Torque audit',
        'Fluid levels',
        'Final wash',
        'Inspect front brake pads',
        'Torque wheel lug nuts to spec',
      ]) {
        await tester.tap(find.text(label));
        await tester.pump();
      }
      await tester.tap(find.text('Approve & pass'));
      await tester.pumpAndSettle();
      expect(fake.qcActions, contains('approve'));
    });

    testWidgets('reject requires a reason then calls qcReview(reject)', (
      tester,
    ) async {
      final fake = _RecordingNotifier();
      await _pump(tester, const SupervisorReviewTab(), notifier: fake);
      await tester.tap(find.text('Start QC'));
      await tester.pumpAndSettle();

      // Reject without a reason: no provider call.
      await tester.tap(find.text('Send back'));
      await tester.pump();
      expect(fake.qcActions, isEmpty);

      await tester.enterText(find.byType(TextField), 'Refit brake pads');
      await tester.pump();
      await tester.tap(find.text('Send back'));
      await tester.pumpAndSettle();
      expect(fake.qcActions, contains('reject'));
    });
  });

  group('states', () {
    testWidgets('floor renders an empty board when nothing is active', (
      tester,
    ) async {
      final fake = _RecordingNotifier(empty: true);
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () {},
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
        notifier: fake,
      );
      expect(find.text('Idle'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('jobs tab shows the empty state with no jobs', (tester) async {
      final fake = _RecordingNotifier(empty: true);
      await _pump(
        tester,
        SupervisorJobsTab(onOpenAssign: () {}),
        notifier: fake,
      );
      expect(find.text('No active jobs'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('accessibility', () {
    testWidgets('bay tiles meet the 48 dp touch target', (tester) async {
      final fake = _RecordingNotifier();
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () {},
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
        notifier: fake,
      );
      final tile = tester.getSize(
        find.ancestor(
          of: find.text('B-01'),
          matching: find.byType(InkWell),
        ).first,
      );
      expect(tile.height, greaterThanOrEqualTo(48));
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required SupervisorDashboardNotifier notifier,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supervisorDashboardProvider.overrideWith(() => notifier),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _RecordingNotifier extends SupervisorDashboardNotifier {
  _RecordingNotifier({this.empty = false});

  final bool empty;
  final List<String> dispatchedTechs = [];
  final List<String> qcActions = [];

  @override
  SupervisorDashboardState build() {
    return SupervisorDashboardState(
      isDashboardLoading: false,
      isQueueLoading: false,
      isReviewLoading: false,
      assignmentRows: [
        const WorkAssignmentEntity(id: 1, description: 'Brake service'),
      ],
    );
  }

  @override
  List<String> get technicians =>
      empty ? const [] : const ['Alex Morgan', 'Sam Rivera'];

  @override
  List<String> get departments => empty ? const [] : const ['Mechanical'];

  @override
  List<BookingQueueResponse> get bookings => empty
      ? const []
      : const [
          BookingQueueResponse(
            id: 1,
            customerName: 'Fatima',
            vehicleName: 'Lexus LX 600',
            plateNumber: 'DXB B 1042',
            bookingDate: '2026-09-18 10:00 AM',
            serviceType: 'Engine Oil',
            status: 'pending',
          ),
        ];

  @override
  List<BreakdownQueueResponse> get breakdowns => const [];

  @override
  List<AssignedJobEntity> get jobs => empty
      ? const []
      : const [
          AssignedJobEntity(
            jobCard: 'JC-2026-1042',
            customer: 'Rashid',
            vehicle: 'Toyota Land Cruiser',
            status: 'In Progress',
            dateAssigned: '17 Sep',
            done: 2,
            total: 3,
          ),
        ];

  @override
  List<AwaitingCompletionResponse> get awaitingCompletions => empty
      ? const []
      : const [
          AwaitingCompletionResponse(
            jobCardId: 1042,
            jobCardRef: 'JC-2026-1042',
            customerName: 'Rashid',
            vehicleInfo: '2024 Toyota Land Cruiser',
            technician: 'Alex Morgan',
            done: 2,
            total: 2,
            items: [
              WorkItemDetail(id: 1, description: 'Inspect front brake pads'),
              WorkItemDetail(id: 2, description: 'Torque wheel lug nuts to spec'),
            ],
          ),
        ];

  @override
  List<AssignableStaffResponse> get advisors => const [];

  @override
  Future<void> saveAndAssign() async {
    dispatchedTechs.add(state.assignmentRows.first.technicianName);
    state = state.copyWith(
      assignWorkSuccess: 'Work assignment submitted (1 task)',
      assignWorkError: '',
    );
  }

  @override
  Future<String> qcReview(
    String jobCardRef,
    String action, {
    bool checklistPassed = true,
    String notes = '',
    String rejectReason = '',
  }) async {
    qcActions.add(action);
    return action == 'approve' ? 'QC passed — job approved' : 'Sent back for revision';
  }
}
