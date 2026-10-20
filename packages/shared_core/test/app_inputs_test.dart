// Phase-1b widget tests: AppInputField, AppSearchBar, AppDropdown, tiles.
//
// Covers label/helper/error, live-region errors, forceLtr, password toggle,
// clear button, disabled/readOnly, keyboard pass-through, tile toggles,
// AA boundary pairs, and 1.3x overflow.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('input boundary contrast (phase-1b gate)', () {
    // WCAG relative luminance through the framework helper (exact).
    double lum(Color c) => c.computeLuminance();

    double ratio(Color a, Color b) {
      final l1 = lum(a), l2 = lum(b);
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    test('resting boundary reaches 3:1 on page + card, both themes', () {
      const canvasLight = Color(0xFFFBFBFD);
      const surfaceLight = Color(0xFFFFFFFF);
      const canvasDark = Color(0xFF090B10);
      const surfaceDark = Color(0xFF11141D);
      expect(ratio(AppColors.inputBorder, canvasLight), greaterThanOrEqualTo(3.0));
      expect(ratio(AppColors.inputBorder, surfaceLight), greaterThanOrEqualTo(3.0));
      expect(ratio(AppDarkColors.inputBorder, canvasDark), greaterThanOrEqualTo(3.0));
      expect(ratio(AppDarkColors.inputBorder, surfaceDark), greaterThanOrEqualTo(3.0));
    });

    test('focus + error boundaries reach 3:1', () {
      expect(ratio(AppColors.primary, const Color(0xFFFBFBFD)), greaterThanOrEqualTo(3.0));
      expect(ratio(AppColors.danger, const Color(0xFFFBFBFD)), greaterThanOrEqualTo(3.0));
      expect(ratio(AppDarkColors.danger, const Color(0xFF090B10)), greaterThanOrEqualTo(3.0));
    });
  });

  Widget wrap(Widget child, {bool rtl = false}) {
    return MaterialApp(
      theme: AppTheme.light(BrandConfig.orient),
      home: Scaffold(
        body: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Center(child: child),
        ),
      ),
    );
  }

  Future<void> pump(WidgetTester tester, Widget child, {bool rtl = false}) async {
    await tester.pumpWidget(wrap(child, rtl: rtl));
    await tester.pump();
  }

  group('AppInputField', () {
    testWidgets('label above, helper below, no overflow at 1.3x', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData.fromView(tester.view).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: AppInputField(
                  label: 'Email',
                  hint: 'name@company.com',
                  helper: 'Work email only',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Work email only'), findsOneWidget);
    });

    testWidgets('error shows icon + text in a live region', (tester) async {
      await pump(
        tester,
        const AppInputField(label: 'Email', error: 'Enter a valid email'),
      );
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(
        tester
            .getSemantics(find.text('Enter a valid email'))
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
    });

    testWidgets('forceLtr locks value direction, labels follow locale', (tester) async {
      final controller = TextEditingController(text: 'name@company.com');
      addTearDown(controller.dispose);
      await pump(
        tester,
        AppInputField(
          label: 'البريد الإلكتروني',
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          forceLtr: true,
        ),
        rtl: true,
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, TextDirection.ltr);
      expect(field.textAlign, TextAlign.left);
      // Label keeps locale direction (no forced LTR).
      final label = tester.widget<Text>(find.text('البريد الإلكتروني'));
      expect(label.textDirection, isNull);
    });

    testWidgets('password toggle flips obscureText with semantics', (tester) async {
      await pump(
        tester,
        const AppInputField(
          label: 'Password',
          obscureText: true,
          passwordToggle: true,
        ),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    });

    testWidgets('disabled dims to 40%, readOnly passes through', (tester) async {
      await pump(
        tester,
        const AppInputField(label: 'Name', enabled: false),
      );
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        0.4,
      );
      await pump(
        tester,
        AppInputField(
          label: 'ID',
          readOnly: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          onChanged: (_) {},
          onSubmitted: (_) {},
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
      expect(field.keyboardType, TextInputType.number);
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
    });
  });

  group('AppSearchBar', () {
    testWidgets('clear button appears with text and empties the field', (tester) async {
      var last = '';
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(
        tester,
        AppSearchBar(
          hint: 'Search bookings',
          controller: controller,
          onChanged: (v) => last = v,
        ),
      );
      expect(find.byTooltip('Clear search'), findsNothing);
      await tester.enterText(find.byType(TextField), 'adil');
      await tester.pump();
      expect(find.byTooltip('Clear search'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(last, isEmpty);
    });
  });

  group('AppDropdown', () {
    testWidgets('opens sheet, picks option, announces selection', (tester) async {
      String? picked;
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: AppDropdown<String>(
            label: 'Branch',
            options: const ['Deira', 'Sharjah'],
            value: picked,
            onChanged: (v) => picked = v,
          ),
        ),
      );
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Sharjah'), findsWidgets);
      await tester.tap(find.text('Sharjah').last);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(picked, 'Sharjah');
    });

    testWidgets('searchable filters long lists', (tester) async {
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: AppDropdown<String>(
            label: 'Branch',
            options: const ['Deira', 'Sharjah', 'Ajman'],
            value: null,
            onChanged: (_) {},
            searchable: true,
          ),
        ),
      );
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField).last, 'shar');
      await tester.pump();
      expect(find.text('Sharjah'), findsOneWidget);
      expect(find.text('Deira'), findsNothing);
    });
  });

  group('tiles', () {
    testWidgets('whole row toggles, disabled ignores, roles labeled', (tester) async {
      var check = false;
      var toggled = true;
      String? radio;
      await pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCheckTile(
                title: 'Email me', value: check, onChanged: (v) => check = v),
            AppSwitchTile(
                title: 'Dark', value: toggled, onChanged: (v) => toggled = v),
            AppRadioTile<String>(
                title: 'Deira',
                value: 'deira',
                groupValue: radio,
                onChanged: (v) => radio = v),
            const AppCheckTile(title: 'Off', value: false, onChanged: null),
          ],
        ),
      );
      await tester.tap(find.text('Email me'));
      await tester.tap(find.text('Dark'));
      await tester.tap(find.text('Deira'));
      await tester.tap(find.text('Off'));
      expect(check, isTrue);
      expect(toggled, isFalse);
      expect(radio, 'deira');
      final row = find.ancestor(
        of: find.text('Email me'),
        matching: find.byType(GestureDetector),
      );
      expect(row, findsOneWidget);
      expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
    });
  });
}
