// Phase-1e-ii widget tests: AppBottomSheet, AppDialog, AppSnackBar/AppToast.
//
// Covers state behavior (presence, actions, barrier dismiss, auto-dismiss
// with injectable short durations, pinned-action structure, bottom-margin
// contract), measured AA contrast pairs (ink on fill, light + dark),
// Semantics (named route, header, live regions, non-blocking toast),
// RTL mirroring and text scale 1.3x (takeException null everywhere).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Exact WCAG 2.x relative luminance (kept in sync with the swatch harness).
double _luminance(Color c) {
  double lin(double v) => v <= 0.04045
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _ratio(Color a, Color b) {
  final l1 = _luminance(a), l2 = _luminance(b);
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

Widget _wrap(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: MediaQuery(
        // fromView (like the capture harness): a bare MediaQueryData has
        // Size.zero, which would collapse AppBottomSheet's 90% max height.
        data: MediaQueryData.fromView(tester.view).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: child,
        ),
      ),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
}) async {
  await tester.pumpWidget(
    _wrap(tester, child, dark: dark, rtl: rtl, scale: scale),
  );
  await tester.pump();
}

/// Reads the theme parts directly off [AppTheme] so light and dark measure
/// exactly what the widgets resolve (no pumped-tree staleness: re-pumping a
/// second MaterialApp in one test keeps the first brightness).
({ColorScheme scheme, AppSemanticColors sem}) _themeParts({bool dark = false}) {
  final brand = BrandConfig.orient;
  final theme = dark ? AppTheme.dark(brand) : AppTheme.light(brand);
  return (
    scheme: theme.colorScheme,
    sem: dark ? AppSemanticColors.dark : AppSemanticColors.light,
  );
}

/// Action labels left-to-right in an [OverflowBar], unwrapping the
/// [IntrinsicWidth] sizers around the pill buttons.
List<String> _actionOrder(WidgetTester tester) {
  final bar = tester.widget<OverflowBar>(find.byType(OverflowBar));
  return bar.children.map((c) {
    final inner = c is IntrinsicWidth ? c.child : c;
    return (inner as AppPillButton).label;
  }).toList();
}

void main() {
  group('AppBottomSheet', () {
    testWidgets('renders handle, title, body and pinned primary fires',
        (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        AppBottomSheet(
          title: 'Filter bookings',
          primaryLabel: 'Apply filters',
          onPrimary: () => tapped++,
          child: const Text('Filter rows go here'),
        ),
      );
      expect(find.textContaining('Filter bookings'), findsOneWidget);
      expect(find.textContaining('Filter rows go here'), findsOneWidget);

      // 36x4 drag handle on the border color.
      final handle = find.byKey(
        const ValueKey<String>('AppBottomSheet.dragHandle'),
      );
      expect(handle, findsOneWidget);
      expect(tester.getSize(handle), const Size(36, 4));

      // Pinned action: body scrolls, the CTA lives outside the scroll view.
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.textContaining('Filter rows go here'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.text('Apply filters'),
        ),
        findsNothing,
      );
      await tester.tap(find.text('Apply filters'));
      expect(tapped, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no CTA without primary label; announces as named route',
        (tester) async {
      await _pump(
        tester,
        const AppBottomSheet(child: Text('Bare content')),
      );
      expect(find.byType(AppPillButton), findsNothing);
      final semantics = tester.getSemantics(find.byType(AppBottomSheet));
      expect(semantics.flagsCollection.namesRoute, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens as a route and dismisses via tap-outside',
        (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (ctx) => Center(
            child: TextButton(
              onPressed: () => showAppBottomSheet<void>(
                ctx,
                title: 'Filter bookings',
                primaryLabel: 'Apply',
                onPrimary: () {},
                child: const Text('Rows'),
              ),
              child: const Text('Open sheet'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL + 1.3x: no overflow', (tester) async {
      await _pump(
        tester,
        AppBottomSheet(
          title: 'Long sheet title that wraps onto two lines',
          primaryLabel: 'Apply filters now',
          onPrimary: () {},
          child: const Text(
            'Body copy that must wrap or grow and never clip at large text.',
          ),
        ),
        rtl: true,
        scale: 1.3,
      );
      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppDialog', () {
    testWidgets('renders title, body and end-aligned secondary + primary',
        (tester) async {
      var secondary = 0;
      var primary = 0;
      await _pump(
        tester,
        AppDialog(
          title: 'Discard changes?',
          message: 'Unsent edits will be lost.',
          secondaryLabel: 'Keep editing',
          onSecondary: () => secondary++,
          primaryLabel: 'Discard',
          onPrimary: () => primary++,
        ),
      );
      expect(find.textContaining('Discard changes?'), findsOneWidget);
      expect(find.textContaining('Unsent edits'), findsOneWidget);

      // Order: secondary first (safe choice), primary last.
      final ordered = _actionOrder(tester);
      expect(ordered, ['Keep editing', 'Discard']);

      // Side-by-side at 1.0 (end-aligned row, not stacked full-width).
      final secondaryDy = tester.getCenter(find.text('Keep editing')).dy;
      final primaryDy = tester.getCenter(find.text('Discard')).dy;
      expect(secondaryDy, primaryDy);

      // Title is a header for screen readers.
      final titleSemantics =
          tester.getSemantics(find.textContaining('Discard changes?'));
      expect(titleSemantics.flagsCollection.isHeader, isTrue);

      await tester.tap(find.text('Keep editing'));
      expect(secondary, 1);
      await tester.tap(find.text('Discard'));
      expect(primary, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('destructive variant keeps order and fires both actions',
        (tester) async {
      var secondary = 0;
      var primary = 0;
      await _pump(
        tester,
        AppDialog.destructive(
          title: "Delete 'Invoice #123'?",
          message: 'This cannot be undone.',
          secondaryLabel: 'Cancel',
          onSecondary: () => secondary++,
          primaryLabel: 'Delete',
          onPrimary: () => primary++,
        ),
      );
      final dialog = tester.widget<AppDialog>(find.byType(AppDialog));
      expect(dialog.destructive, isTrue);
      final ordered = _actionOrder(tester);
      expect(ordered, ['Cancel', 'Delete']);
      await tester.tap(find.text('Cancel'));
      expect(secondary, 1);
      await tester.tap(find.text('Delete'));
      expect(primary, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens as a route and dismisses via tap-outside',
        (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (ctx) => Center(
            child: TextButton(
              onPressed: () => showAppDialog<void>(
                ctx,
                title: 'Discard changes?',
                message: 'Unsent edits will be lost.',
                secondaryLabel: 'Keep editing',
                primaryLabel: 'Discard',
              ),
              child: const Text('Open dialog'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AA: title and body ink on the dialog surface', (tester) async {
      for (final dark in [false, true]) {
        final parts = _themeParts(dark: dark);
        final scheme = parts.scheme;
        expect(
          _ratio(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'title ink ${dark ? 'dark' : 'light'}',
        );
        expect(
          _ratio(scheme.onSurfaceVariant, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'body ink ${dark ? 'dark' : 'light'}',
        );
      }
    });

    testWidgets('RTL + 1.3x with long copy: actions wrap, no overflow',
        (tester) async {
      await _pump(
        tester,
        AppDialog.destructive(
          title: 'A very long destructive title naming the object plainly',
          message:
              'A long explanation that must wrap across lines and can push '
              'the actions to stack vertically instead of clipping.',
          secondaryLabel: 'Keep everything as it is',
          onSecondary: () {},
          primaryLabel: 'Delete everything now',
          onPrimary: () {},
        ),
        rtl: true,
        scale: 1.3,
      );
      expect(find.byType(AppDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacked at 1.3x: actions stay end-aligned', (tester) async {
      await _pump(
        tester,
        AppDialog.destructive(
          title: 'A very long destructive title naming the object plainly',
          message:
              'A long explanation that must wrap across lines and can push '
              'the actions to stack vertically instead of clipping.',
          secondaryLabel: 'Keep everything as it is',
          onSecondary: () {},
          primaryLabel: 'Delete everything now',
          onPrimary: () {},
        ),
        scale: 1.3,
      );
      expect(find.byType(AppDialog), findsOneWidget);
      final secondaryRect = tester.getRect(find.byType(AppPillButton).at(0));
      final primaryRect = tester.getRect(find.byType(AppPillButton).at(1));
      // Stacked vertically (centers differ in dy by at least one button).
      expect(
        (secondaryRect.center.dy - primaryRect.center.dy).abs(),
        greaterThan(20),
      );
      // End-aligned: right edges coincide within rounding tolerance.
      expect(
        (secondaryRect.right - primaryRect.right).abs(),
        lessThanOrEqualTo(1.0),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSnackBar', () {
    testWidgets('renders icon + message + action; action fires',
        (tester) async {
      var acted = 0;
      await _pump(
        tester,
        AppSnackBar(
          message: 'Booking saved.',
          kind: AppSnackBarKind.success,
          actionLabel: 'Undo',
          onAction: () => acted++,
        ),
      );
      expect(find.textContaining('Booking saved.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      await tester.tap(find.text('Undo'));
      expect(acted, 1);
      final semantics = tester.getSemantics(find.byType(AppSnackBar));
      expect(semantics.flagsCollection.isLiveRegion, isTrue);
      expect(semantics.label, 'Booking saved.');
      expect(tester.takeException(), isNull);
    });

    testWidgets('auto-dismisses after displayDuration; honors bottomMargin',
        (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (ctx) => Center(
            child: TextButton(
              onPressed: () => AppSnackBar.show(
                ctx,
                message: 'Syncing…',
                actionLabel: 'Retry',
                onAction: () {},
                displayDuration: const Duration(milliseconds: 50),
                bottomMargin: 72,
              ),
              child: const Text('Show snackbar'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show snackbar'));
      await tester.pump();
      expect(find.textContaining('Syncing'), findsOneWidget);

      // Positioning contract: the card floats above the nav/sticky bar.
      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      final margin = bar.margin!.resolve(TextDirection.ltr);
      expect(margin.bottom, 72);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(find.textContaining('Syncing'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AA: ink on fill for every kind, light + dark',
        (tester) async {
      const kinds = AppSnackBarKind.values;
      for (final dark in [false, true]) {
        final parts = _themeParts(dark: dark);
        final scheme = parts.scheme;
        final sem = parts.sem;
        final fills = {
          AppSnackBarKind.neutral: scheme.inverseSurface,
          AppSnackBarKind.success: dark
              ? AppDarkColors.successStrongSoft
              : AppColors.successStrongSoft,
          AppSnackBarKind.error: sem.danger.subtle,
        };
        final inks = {
          AppSnackBarKind.neutral: scheme.onInverseSurface,
          AppSnackBarKind.success: dark
              ? AppDarkColors.successStrongInk
              : AppColors.successStrongInk,
          AppSnackBarKind.error: sem.danger.ink,
        };
        for (final kind in kinds) {
          expect(
            _ratio(inks[kind]!, fills[kind]!),
            greaterThanOrEqualTo(4.5),
            reason: '$kind ${dark ? 'dark' : 'light'}',
          );
        }
      }
    });

    testWidgets('RTL + 1.3x: wraps, no overflow', (tester) async {
      await _pump(
        tester,
        const AppSnackBar(
          message:
              'A long outcome message that must wrap inside the floating '
              'card next to its action instead of overflowing.',
          kind: AppSnackBarKind.error,
          actionLabel: 'Try again',
        ),
        rtl: true,
        scale: 1.3,
      );
      // onAction null + label set = no action rendered (both required).
      expect(find.byType(TextButton), findsNothing);
      expect(find.textContaining('long outcome'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppToast', () {
    testWidgets('centered, non-blocking, auto-dismisses, live region',
        (tester) async {
      await _pump(tester, const SizedBox.expand());
      AppToast.show(
        tester.element(find.byType(SizedBox)),
        message: 'Synced just now.',
        kind: AppSnackBarKind.success,
        displayDuration: const Duration(milliseconds: 50),
      );
      await tester.pump();
      expect(find.textContaining('Synced just now.'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.textContaining('Synced just now.'),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
      // Non-blocking: taps pass through; announced via live region.
      expect(
        find.ancestor(
          of: find.textContaining('Synced just now.'),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
      final semantics = tester.getSemantics(find.byType(AppToast));
      expect(semantics.flagsCollection.isLiveRegion, isTrue);
      expect(semantics.label, 'Synced just now.');

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      expect(find.textContaining('Synced just now.'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL + 1.3x: no overflow', (tester) async {
      await _pump(
        tester,
        const AppToast(
          message: 'A toast message long enough that it must wrap to a '
              'second line inside the centered card at large text.',
          kind: AppSnackBarKind.error,
        ),
        rtl: true,
        scale: 1.3,
      );
      expect(find.byType(AppToast), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
