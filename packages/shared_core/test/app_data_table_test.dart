// Phase-1f widget tests: AppDataTable + AppDataTableHeader.
//
// Covers wide vs compact rendering via surface widths, sort taps (order
// change + sort-state Semantics), tabular figures on numeric cells, header
// background token, sticky header pinning, AA contrast (header ink on
// surfaceSunken) and text scale 1.3x without overflow.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

double _luminance(Color c) {
  double lin(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _ratio(Color a, Color b) {
  final l1 = _luminance(a), l2 = _luminance(b);
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

const _columns = [
  AppDataColumn(label: 'Invoice'),
  AppDataColumn(label: 'Amount', numeric: true, sortable: true),
];

const _rows = [
  ['INV-102', 'AED 200.00'],
  ['INV-101', 'AED 100.00'],
  ['INV-103', 'AED 300.00'],
];

Widget _wrap(
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
  double width = 800,
}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
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
  double width = 800,
}) async {
  await tester.pumpWidget(
    _wrap(child, dark: dark, rtl: rtl, scale: scale, width: width),
  );
  await tester.pump();
}

/// Sortable harness: taps on the header re-sort [rows] in place.
class _SortHarness extends StatefulWidget {
  const _SortHarness();

  @override
  State<_SortHarness> createState() => _SortHarnessState();
}

class _SortHarnessState extends State<_SortHarness> {
  var rows = [for (final r in _rows) [...r]];
  int? sortIndex;
  var ascending = true;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      columns: _columns,
      rows: rows,
      sortColumnIndex: sortIndex,
      sortAscending: ascending,
      onSort: (i) => setState(() {
        if (sortIndex == i) {
          ascending = !ascending;
        } else {
          sortIndex = i;
          ascending = true;
        }
        rows.sort(
          (a, b) => ascending
              ? a[i].compareTo(b[i])
              : b[i].compareTo(a[i]),
        );
      }),
    );
  }
}

void main() {
  group('wide vs compact via surface widths', () {
    testWidgets('800px renders the table header, no cards', (tester) async {
      await _pump(
        tester,
        const AppDataTable(columns: _columns, rows: _rows)
        ,
      );
      expect(find.byType(AppDataTableHeader), findsOneWidget);
      expect(find.byType(AppSurfaceCard), findsNothing);
      expect(find.text('Invoice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('350px stacks one card per row, no table', (tester) async {
      await _pump(
        tester,
        const AppDataTable(columns: _columns, rows: _rows),
        width: 350,
      );
      expect(find.byType(AppDataTableHeader), findsNothing);
      expect(find.byType(AppSurfaceCard), findsNWidgets(_rows.length));
      // Every row shows both label and value inside its card.
      expect(find.text('Invoice'), findsNWidgets(_rows.length));
      expect(tester.takeException(), isNull);
    });

    testWidgets('breakpoint is the surface, not the window', (tester) async {
      // Window is 800 wide (default test surface) but the table only gets
      // 350 px: it must still stack cards.
      await _pump(
        tester,
        const AppDataTable(columns: _columns, rows: _rows),
        width: 350,
      );
      expect(find.byType(AppSurfaceCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });

  group('sort semantics + behavior', () {
    testWidgets('tap re-sorts rows and announces state', (tester) async {
      await _pump(tester, const _SortHarness());
      expect(find.bySemanticsLabel('Sort by Amount'), findsOneWidget);

      await tester.tap(find.text('Amount'));
      await tester.pump();
      // Ascending: INV-101 first.
      final first = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(AppDataTable),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data ?? '')
          .toList();
      expect(first.indexOf('INV-101') < first.indexOf('INV-102'), isTrue);
      expect(
        find.bySemanticsLabel('Amount, sorted ascending'),
        findsOneWidget,
      );

      await tester.tap(find.text('Amount'));
      await tester.pump();
      expect(
        find.bySemanticsLabel('Amount, sorted descending'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('non-sortable column has no button semantics', (tester) async {
      await _pump(
        tester,
        const AppDataTable(columns: _columns, rows: _rows)
        ,
      );
      expect(find.bySemanticsLabel('Sort by Invoice'), findsNothing);
    });
  });

  group('numbers + header chrome', () {
    testWidgets('numeric cells use tabular figures, LTR-locked', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppDataTable(columns: _columns, rows: _rows)
        ,
      );
      final text = tester.widget<Text>(find.text('AED 100.00'));
      expect(
        text.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      // LTR isolate above the numeric text.
      final dir = tester.widget<Directionality>(
        find.ancestor(
          of: find.text('AED 100.00'),
          matching: find.byType(Directionality),
        ).first,
      );
      expect(dir.textDirection, TextDirection.ltr);
    });

    testWidgets('header sits on surfaceSunken', (tester) async {
      for (final dark in [false, true]) {
        await _pump(
          tester,
          const AppDataTable(columns: _columns, rows: _rows)
          ,
          dark: dark,
        );
        // ThemeMode flips animate (AnimatedTheme, 200ms): settle past the
        // lerp or the header still reads the previous mode's token.
        await tester.pump(const Duration(milliseconds: 300));
        final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
        final headerBox = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(AppDataTableHeader),
                matching: find.byType(Container),
              ),
            )
            .first;
        expect(headerBox.color, sem.surfaceSunken);
      }
    });

    test('header ink on surfaceSunken >= 4.5, both themes', () {
      for (final dark in [false, true]) {
        final theme = dark
            ? AppTheme.dark(BrandConfig.orient)
            : AppTheme.light(BrandConfig.orient);
        final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
        final ratio = _ratio(theme.colorScheme.onSurface, sem.surfaceSunken);
        debugPrint('1f header ${dark ? 'dark' : 'light'}=$ratio');
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('sticky header + scale', () {
    testWidgets('pinned header does not move when the body scrolls', (
      tester,
    ) async {
      final many = [
        for (var i = 0; i < 30; i++)
          ['INV-${100 + i}', 'AED ${100 + i}.00'],
      ];
      await _pump(
        tester,
        AppDataTable(columns: _columns, rows: many, maxHeight: 220)
        ,
      );
      final before = tester.getTopLeft(find.text('Amount')).dy;
      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Amount')).dy, before);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x: no overflow at 350, 320 or 800', (tester) async {
      for (final width in [350.0, 320.0, 800.0]) {
        await _pump(
          tester,
          const AppDataTable(columns: _columns, rows: _rows),
          width: width,
          scale: 1.3,
        );
        expect(tester.takeException(), isNull, reason: 'width $width');
      }
    });

    testWidgets('1.3x RTL compact: no overflow', (tester) async {
      await _pump(
        tester,
        const AppDataTable(columns: _columns, rows: _rows),
        width: 350,
        scale: 1.3,
        rtl: true,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
