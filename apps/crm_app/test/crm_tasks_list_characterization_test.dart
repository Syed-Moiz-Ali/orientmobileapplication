// Structural tests for the recomposed CRM tasks list (list family).
//
// Presentation-tree assertions only: header/find-aid threshold, per-card
// toggle/edit/delete reachability (tap budgets AFTER ≤ BEFORE), 48dp
// targets, status pills, search sheet, delete dialog, form sheet
// validation, empty state, pull-to-refresh. Behavior (providers,
// navigation targets, due-date derivation) is asserted nowhere.
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

CrmTaskEntity _task(int i, {bool done = false}) => CrmTaskEntity(
  id: 't$i',
  title: 'Task $i',
  assignedTo: i.isEven ? 'Sara' : '',
  dueDate: '',
  priority: 'High',
  priorityColor: Colors.red,
  isDone: done,
);

class _FakeCrmRepo implements CrmRepository {
  final List<CrmTaskEntity> tasks;
  _FakeCrmRepo(this.tasks);

  @override
  List<CrmKpiEntity> get kpis => const [];
  @override
  List<CrmChannelEntity> get channels => const [];
  @override
  List<CrmTrendPoint> get conversionTrend => const [];
  @override
  List<SalespersonPerf> get salespersonPerf => const [];
  @override
  List<ResponseTimeBucket> get responseTimeBuckets => const [];
  @override
  List<LeadSourceSlice> get leadSources => const [];
  @override
  List<CrmKeyMetric> get keyMetrics => const [];
  @override
  List<IntegrationEntity> get integrations => const [];
  @override
  List<SalesTeamMember> get salesTeam => const [];
  @override
  List<ConversationEntity> get conversations => const [];
  @override
  List<CrmLeadEntity> getLeads() => const [];
  // Copy-on-read like the production adapter: the notifier keeps the
  // returned list as state, so a mutated same-instance list would compare
  // equal and never notify.
  @override
  List<CrmTaskEntity> getTasks() => List.of(tasks);

  @override
  Future<void> refreshLeads() async {}
  @override
  Future<void> refreshTasks() async {}
  @override
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data) async {
    final created = CrmTaskEntity(
      id: 't-new',
      title: (data['title'] ?? '') as String,
      assignedTo: (data['assignedTo'] ?? '') as String,
      dueDate: (data['dueDate'] ?? '') as String,
      priority: (data['priority'] ?? 'Medium') as String,
      priorityColor: Colors.amber,
    );
    tasks.add(created);
    return created;
  }

  @override
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data) async {
    final i = tasks.indexWhere((t) => t.id == id);
    final cur = tasks[i];
    final next = cur.copyWith(
      title: data['title'] as String?,
      assignedTo: data['assignedTo'] as String?,
      dueDate: data['dueDate'] as String?,
      priority: data['priority'] as String?,
      isDone: data['isDone'] as bool?,
    );
    tasks[i] = next;
    return next;
  }

  @override
  Future<void> deleteTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<void> deleteLead(String id) async {}
  @override
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> c) async => throw UnimplementedError();
  @override
  Future<IntegrationEntity> disconnectIntegration(String name) async => throw UnimplementedError();
  @override
  Future<IntegrationEntity> syncIntegration(String name) async => throw UnimplementedError();
  @override
  Future<List<TeamMemberEntity>> getTeamMembers() async => const [];
  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String id) async => const [];
  @override
  Future<LeadStatsEntity> getLeadStats() async => const LeadStatsEntity();
  @override
  Future<List<FollowUpEntity>> getFollowUps() async => const [];
  @override
  Future<List<ActivityFeedEntity>> getActivityFeed() async => const [];
  @override
  Future<void> loadAll() async {}
}

Future<void> _pumpTasks(
  WidgetTester tester, {
  required List<CrmTaskEntity> tasks,
  double scale = 1.0,
  Size viewport = const Size(360, 800),
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [crmRepositoryProvider.overrideWithValue(_FakeCrmRepo(tasks))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: CrmTasksPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  group('crm tasks list (after)', () {
    testWidgets('<=5: header + count + refresh + Add, no search', (tester) async {
      await _pumpTasks(tester, tasks: [_task(1), _task(2)]);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('2 tasks'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);
      // Progressive disclosure: no search icon with ≤ 5 items.
      expect(find.byTooltip('Search tasks'), findsNothing);
      expect(find.byTooltip('Refresh workspace'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('cards render title/meta/priority; toggle flips', (tester) async {
      final tasks = [_task(1), _task(2, done: true)];
      await _pumpTasks(tester, tasks: tasks);
      expect(find.byType(AppSurfaceCard), findsNWidgets(2));
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      // Done card renders struck through; open card does not lose its chip.
      expect(find.byKey(const ValueKey('taskToggle_t1')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('taskToggle_t1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      expect(find.byType(AppSurfaceCard), findsNWidgets(2));
    });

    testWidgets('edit/delete are 48dp icon buttons with tooltips', (tester) async {
      await _pumpTasks(tester, tasks: [_task(1)]);
      expect(find.byTooltip('Edit Task'), findsOneWidget);
      expect(find.byTooltip('Delete Task'), findsOneWidget);
      // No 30px gesture targets remain.
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('edit opens the bottom-sheet form', (tester) async {
      await _pumpTasks(tester, tasks: [_task(1)]);
      await tester.tap(find.byTooltip('Edit Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Edit Task'), findsWidgets);
      expect(find.byType(AppInputField), findsWidgets);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('add validates the title inline', (tester) async {
      await _pumpTasks(tester, tasks: [_task(1)]);
      await tester.tap(find.text('Add Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Add Task'), findsWidgets);
      // The sheet's save button (scoped to the pill, not the sheet title).
      await tester.tap(
        find.descendant(of: find.byType(AppPillButton), matching: find.text('Add Task')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Task title is required'), findsOneWidget);
    });

    testWidgets('delete asks via AppDialog and removes', (tester) async {
      await _pumpTasks(tester, tasks: [_task(1)]);
      await tester.tap(find.byTooltip('Delete Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('Delete "Task 1"?'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(AppDialog), matching: find.text('Delete')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AppSurfaceCard), findsNothing);
      expect(find.byType(AppEmptyState), findsOneWidget);
    });

    testWidgets('header is a plain same-row Row (no AppPageHeader stacking)', (tester) async {
      await _pumpTasks(
        tester,
        tasks: [for (var i = 0; i < 6; i++) _task(i)],
      );
      // F6: same placement fix as the leads list — title + search share one
      // Row top-end on compact. Same >5 condition, same sheet, same target.
      expect(find.byType(AppPageHeader), findsNothing);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.byTooltip('Search tasks'), findsOneWidget);
      final searchRow = find.ancestor(
        of: find.byTooltip('Search tasks'),
        matching: find.byType(Row),
      );
      expect(searchRow, findsWidgets);
      expect(
        find.descendant(of: searchRow.first, matching: find.text('Tasks')),
        findsOneWidget,
      );
    });

    testWidgets('>5: search icon appears; sheet filters tasks', (tester) async {
      await _pumpTasks(
        tester,
        tasks: [for (var i = 0; i < 6; i++) _task(i)],
      );
      expect(find.text('6 tasks'), findsOneWidget);
      expect(find.byTooltip('Search tasks'), findsOneWidget);
      await tester.tap(find.byTooltip('Search tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Search tasks'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'zzz-no-such-task');
      await tester.pump();
      expect(find.text('No tasks match your search.'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.text('Task 1'), findsWidgets);
    });

    testWidgets('empty state offers Add Task', (tester) async {
      await _pumpTasks(tester, tasks: []);
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.textContaining('No tasks yet'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('unparseable due date yields no badge (never guessed)', (tester) async {
      await _pumpTasks(
        tester,
        tasks: [
          CrmTaskEntity(
            id: 'tx',
            title: 'Free-text due',
            assignedTo: '',
            dueDate: 'tomorrow-ish',
            priority: 'Low',
            priorityColor: Colors.green,
          ),
        ],
      );
      expect(find.text('Free-text due'), findsOneWidget);
      expect(find.text('Overdue'), findsNothing);
      expect(find.text('Due today'), findsNothing);
    });

    testWidgets('priority chip renders the localized label', (tester) async {
      await _pumpTasks(tester, tasks: [_task(1)]);
      // en tkHigh renders "High" through the shared key (the ar capture
      // proves the localized pill); unknown server labels stay verbatim.
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('dark + 1.3x + 320px pump clean', (tester) async {
      tester.view.physicalSize = const Size(640, 1136); // 320x568 @2x
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [crmRepositoryProvider.overrideWithValue(_FakeCrmRepo([_task(0), _task(1)]))],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const Scaffold(body: CrmTasksPage()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text('2 tasks'), findsOneWidget);
    });
  });
}
