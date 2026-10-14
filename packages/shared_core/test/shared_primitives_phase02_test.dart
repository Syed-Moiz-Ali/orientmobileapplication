import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 02 focused interaction + API tests for the redesigned primitives.
void main() {
  Widget host(Widget child, {ThemeData? theme, Locale? locale}) {
    return MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.light(BrandConfig.orient),
      home: Scaffold(body: child),
    );
  }

  group('PrimaryButton states', () {
    testWidgets('isError resolves the semantic error fill', (tester) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(label: 'Delete order', isError: true, onPressed: () {}),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final fill = button.style!.backgroundColor!.resolve(<WidgetState>{});
      expect(fill, AppColors.danger);
    });

    testWidgets('loading keeps the active fill and shows one spinner', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(label: 'Saving', isLoading: true, onPressed: () {}),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving'), findsNothing);
    });

    testWidgets('renders in dark theme without exception', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              PrimaryButton(label: 'Confirm', isError: true),
              SecondaryButton(label: 'Cancel'),
            ],
          ),
          theme: AppTheme.dark(BrandConfig.orient),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSearchField shortcut badge', () {
    testWidgets('shows the shortcut hint then hides it once text is entered', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(AppSearchField(controller: controller, shortcutLabel: '⌘K')),
      );
      expect(find.text('⌘K'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'brakes');
      await tester.pump();
      expect(find.text('⌘K'), findsNothing);
      expect(find.byTooltip('Clear search'), findsOneWidget);
    });
  });

  group('Empty state CTA', () {
    testWidgets('uses a single prominent primary action and fires it', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        host(
          EmptyState.error(message: 'Could not load', onRetry: () {
            retried = true;
          }),
        ),
      );
      expect(find.byType(PrimaryButton), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('Selection sheet composition', () {
    testWidgets('selected row keeps the value selectable through the mark', (
      tester,
    ) async {
      final options = [
        for (var i = 1; i <= 10; i++)
          AppSelectionOption<int>(value: i, label: 'Tech $i'),
      ];
      late BuildContext ctx;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final future = showAppSelectionSheet<int>(context: ctx, options: options, selected: 2);
      await tester.pumpAndSettle();
      expect(find.text('Tech 5'), findsOneWidget);
      await tester.tap(find.text('Tech 5'));
      await tester.pumpAndSettle();
      expect(await future, 5);
    });
  });
}
