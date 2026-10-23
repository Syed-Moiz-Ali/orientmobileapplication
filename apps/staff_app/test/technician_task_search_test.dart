// Behavior pins for the technician task-find sheet (ruling (a)).
//
// The detail's WorkspaceAppBar top-right search opens a full-screen sheet
// over the detail's loaded tasks: substring over task titles
// (case-insensitive), result tap reuses the row-toggle contract (reveal +
// start/resume/complete via the detail's existing callbacks), no-match +
// Clear. Presentation only: no new routes, no logic changes.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_task_search.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _tasks = [
  WorkTaskEntity(
    id: 1,
    description: 'Change engine oil',
    status: TaskStatus.completed,
    startTime: '08:30',
    endTime: '08:50',
  ),
  WorkTaskEntity(id: 2, description: 'Replace brake pads'),
  WorkTaskEntity(id: 3, description: 'Rotate tires'),
];

Future<void> _pumpSheet(
  WidgetTester tester,
  void Function(WorkTaskEntity) onSelect,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        StaffLocalizations.delegate,
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      locale: const Locale('en'),
      theme: AppTheme.light(BrandConfig.orient),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showTechnicianTaskSearch(
              context,
              tasks: _tasks,
              onSelect: onSelect,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

Finder _sheetBox() => find.descendant(
  of: find.byType(AppSearchField),
  matching: find.byType(TextField),
);

void main() {
  testWidgets('sheet filters by substring over task titles', (tester) async {
    await _pumpSheet(tester, (_) {});

    expect(_sheetBox(), findsOneWidget);
    expect(find.text('Change engine oil'), findsOneWidget);
    expect(find.text('Replace brake pads'), findsOneWidget);
    expect(find.text('Rotate tires'), findsOneWidget);

    await tester.enterText(_sheetBox(), 'OIL');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Change engine oil'), findsOneWidget);
    expect(find.text('Replace brake pads'), findsNothing);
    expect(find.text('Rotate tires'), findsNothing);
  });

  testWidgets('no match shows the message with a clear action', (tester) async {
    await _pumpSheet(tester, (_) {});

    await tester.enterText(_sheetBox(), 'zzz-no-such-task');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('No matching tasks'), findsOneWidget);

    final clears = find.textContaining('Clear');
    expect(clears, findsWidgets);
    await tester.tap(clears.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Change engine oil'), findsOneWidget);
    expect(find.text('Replace brake pads'), findsOneWidget);
    expect(find.text('Rotate tires'), findsOneWidget);
  });

  testWidgets('result tap reuses the toggle contract via onSelect', (
    tester,
  ) async {
    final selected = <WorkTaskEntity>[];
    await _pumpSheet(tester, selected.add);

    await tester.enterText(_sheetBox(), 'brake');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Replace brake pads'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(selected.map((t) => t.id), [2]);
    // The sheet closes on select, revealing the detail (sticky bar intact).
    expect(find.byType(AppSearchField), findsNothing);
  });
}
