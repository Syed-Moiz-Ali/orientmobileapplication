import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  Widget host(Widget child, {double width = 390}) {
    return MaterialApp(
      theme: AppTheme.light(BrandConfig.orient),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 844)),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('PrimaryButton exposes a disabled loading state', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      host(
        PrimaryButton(
          label: 'Save',
          isLoading: true,
          onPressed: () => presses++,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(presses, 0);
  });

  testWidgets('AppSearchField clears text and reports the empty query', (
    tester,
  ) async {
    final changes = <String>[];
    final controller = TextEditingController(text: 'brakes');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      host(AppSearchField(controller: controller, onChanged: changes.add)),
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changes.last, isEmpty);
  });

  testWidgets('AppRecordRow is keyboard and pointer actionable', (
    tester,
  ) async {
    var selected = false;
    await tester.pumpWidget(
      host(
        AppRecordRow(
          title: 'MH 12 AB 4582',
          subtitle: 'Inspection waiting',
          onTap: () => selected = true,
        ),
      ),
    );
    await tester.tap(find.text('MH 12 AB 4582'));
    expect(selected, isTrue);
  });

  testWidgets('AppActionBar stacks on mobile and aligns on desktop', (
    tester,
  ) async {
    Widget actionBar() => AppActionBar(
      primary: const FilledButton(onPressed: null, child: Text('Save')),
      secondary: const [OutlinedButton(onPressed: null, child: Text('Cancel'))],
    );

    await tester.pumpWidget(host(actionBar()));
    expect(
      find.descendant(
        of: find.byType(AppActionBar),
        matching: find.byType(Column),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(host(actionBar(), width: 1280));
    expect(
      find.descendant(
        of: find.byType(AppActionBar),
        matching: find.byType(Row),
      ),
      findsOneWidget,
    );
  });
}
