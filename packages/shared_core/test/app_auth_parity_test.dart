// Phase-2c extension tests: App* parity behaviors needed by shared auth.
//
// Covers the additive-only extensions introduced for the auth redesign:
// - AppInputField: belowField slot, labelTrailing, localized password-toggle
//   tooltips, textCapitalization pass-through.
// - AppPillButton: busyLabel swap (text + spinner, width preserved, taps
//   ignored, busy Semantics).
// - AppSegmentedControl: optional option icons.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(BrandConfig.orient),
    home: Scaffold(body: Center(child: child)),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_wrap(child));
  await tester.pump();
}

void main() {
  group('AppInputField auth parity', () {
    testWidgets('belowField renders under the control', (tester) async {
      await _pump(
        tester,
        const AppInputField(
          label: 'Password',
          belowField: Text('strength-meter'),
        ),
      );
      expect(find.text('strength-meter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('labelTrailing renders beside the label', (tester) async {
      await _pump(
        tester,
        const AppInputField(
          label: 'Create a password',
          labelTrailing: Text('Min. 6 characters'),
        ),
      );
      expect(find.text('Create a password'), findsOneWidget);
      expect(find.text('Min. 6 characters'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password toggle uses localized tooltips', (tester) async {
      await _pump(
        tester,
        const AppInputField(
          label: 'Password',
          obscureText: true,
          passwordToggle: true,
          showPasswordTooltip: 'إظهار كلمة المرور',
          hidePasswordTooltip: 'إخفاء كلمة المرور',
        ),
      );
      expect(find.byTooltip('إظهار كلمة المرور'), findsOneWidget);
      await tester.tap(find.byTooltip('إظهار كلمة المرور'));
      await tester.pump();
      expect(find.byTooltip('إخفاء كلمة المرور'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('textCapitalization passes through to the field',
        (tester) async {
      await _pump(
        tester,
        const AppInputField(
          label: 'Full name',
          textCapitalization: TextCapitalization.words,
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textCapitalization, TextCapitalization.words);
      expect(tester.takeException(), isNull);
    });

    testWidgets('extension defaults preserve phase-1b behavior',
        (tester) async {
      await _pump(tester, const AppInputField(label: 'Email'));
      final field = tester.widget<AppInputField>(
        find.byType(AppInputField),
      );
      expect(field.belowField, isNull);
      expect(field.labelTrailing, isNull);
      expect(field.showPasswordTooltip, 'Show password');
      expect(field.hidePasswordTooltip, 'Hide password');
      expect(field.textCapitalization, TextCapitalization.none);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppPillButton busyLabel', () {
    testWidgets('busy swaps the label and keeps a spinner', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppPillButton.primary(
            label: 'Continue',
            busyLabel: 'Signing in…',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Signing in…'), findsOneWidget);
      // The rest label stays laid out invisibly (width preservation).
      final rest = find.text('Continue');
      expect(rest, findsOneWidget);
      final opacities = tester.widgetList<Opacity>(
        find.ancestor(of: rest, matching: find.byType(Opacity)),
      );
      expect(opacities.any((o) => o.opacity == 0.0), isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rest label preserved without busyLabel', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppPillButton.primary(
            label: 'Continue',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );
      // No busy copy: the rest label stays laid out (invisibly) with an
      // overlaid spinner, so nothing readable changes.
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('busy announces itself and ignores taps', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppPillButton.primary(
            label: 'Continue',
            busyLabel: 'Signing in…',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      final semantics = tester.getSemantics(
        find.widgetWithText(AppPillButton, 'Signing in…'),
      );
      expect(semantics.label, contains('loading'));
      await tester.tap(find.text('Signing in…'));
      await tester.pump();
      expect(taps, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSegmentedControl icons', () {
    testWidgets('options render optional icons + selected semantics',
        (tester) async {
      String selected = 'password';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => AppSegmentedControl<String>(
                  options: const [
                    AppSegmentedOption(
                      value: 'password',
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                    ),
                    AppSegmentedOption(
                      value: 'code',
                      label: 'One-time code',
                      icon: Icons.sms_outlined,
                    ),
                  ],
                  selected: selected,
                  onChanged: (v) => setState(() => selected = v),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sms_outlined), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('One-time code'), findsOneWidget);

      await tester.tap(find.text('One-time code'));
      await tester.pump();
      expect(selected, 'code');
      expect(tester.takeException(), isNull);
    });

    testWidgets('icon-less options still build (backwards compatible)',
        (tester) async {
      await _pump(
        tester,
        AppSegmentedControl<String>(
          options: const [
            AppSegmentedOption(value: 'a', label: 'A'),
            AppSegmentedOption(value: 'b', label: 'B'),
          ],
          selected: 'a',
          onChanged: (_) {},
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
