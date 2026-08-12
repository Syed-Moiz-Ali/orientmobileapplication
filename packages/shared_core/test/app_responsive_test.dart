import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  test('AppResponsive maps widths to stable window classes', () {
    expect(AppResponsive.classForWidth(320), AppWindowClass.compact);
    expect(AppResponsive.classForWidth(600), AppWindowClass.medium);
    expect(AppResponsive.classForWidth(1024), AppWindowClass.expanded);
    expect(AppResponsive.classForWidth(1440), AppWindowClass.large);
  });

  testWidgets('AppResponsivePage constrains larger layouts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(1440, 900)),
          child: AppResponsivePage(
            child: SizedBox(key: ValueKey('content'), height: 10),
          ),
        ),
      ),
    );

    final page = tester.widget<ConstrainedBox>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('content')),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );

    expect(page.constraints.maxWidth, 1320);
  });

  testWidgets('AppResponsive exposes adaptive layout tokens', (tester) async {
    late AppAdaptiveSpec compact;
    late AppAdaptiveSpec desktop;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Builder(
            builder: (context) {
              compact = context.adaptive;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1440, 900)),
          child: Builder(
            builder: (context) {
              desktop = context.adaptive;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(compact.isCompact, isTrue);
    expect(compact.formMaxWidth, double.infinity);
    expect(compact.gridColumns, 1);
    expect(compact.useNavigationRail, isFalse);
    expect(compact.focusedFlowAlignment, const Alignment(0, -0.34));

    expect(desktop.isLarge, isTrue);
    expect(desktop.contentMaxWidth, 1320);
    expect(desktop.formMaxWidth, 460);
    expect(desktop.gridColumns, 4);
    expect(desktop.useNavigationRail, isTrue);
    expect(desktop.extendNavigationRail, isTrue);
    expect(desktop.navigationRailWidth, 92);
  });
}
