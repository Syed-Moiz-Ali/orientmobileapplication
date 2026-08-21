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

  test('AppResponsive distinguishes all target device tiers', () {
    expect(AppResponsive.deviceClassForWidth(320), AppDeviceClass.smallMobile);
    expect(AppResponsive.deviceClassForWidth(390), AppDeviceClass.mobile);
    expect(AppResponsive.deviceClassForWidth(430), AppDeviceClass.largeMobile);
    expect(AppResponsive.deviceClassForWidth(600), AppDeviceClass.tablet);
    expect(AppResponsive.deviceClassForWidth(1024), AppDeviceClass.desktop);
    expect(
      AppResponsive.deviceClassForWidth(1920),
      AppDeviceClass.largeDesktop,
    );
  });

  testWidgets('page padding follows mobile and large desktop tiers', (
    tester,
  ) async {
    Future<AppAdaptiveSpec> specAt(Size size) async {
      late AppAdaptiveSpec spec;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                spec = context.adaptive;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      return spec;
    }

    expect((await specAt(const Size(320, 640))).pagePadding.left, 12);
    expect((await specAt(const Size(390, 844))).pagePadding.left, 16);
    expect((await specAt(const Size(430, 932))).pagePadding.left, 20);
    expect((await specAt(const Size(1920, 1080))).contentMaxWidth, 1440);
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

  testWidgets(
    'adaptive page, grid, split view, and actions do not overflow target widths',
    (tester) async {
      const widths = <double>[
        320,
        360,
        390,
        430,
        600,
        800,
        1024,
        1280,
        1440,
        1920,
      ];
      addTearDown(tester.view.reset);

      for (final width in widths) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppResponsivePage(
                child: Column(
                  children: [
                    AppAdaptiveGrid(
                      minChildWidth: 220,
                      childAspectRatio: 2,
                      children: List.generate(
                        6,
                        (index) => ColoredBox(
                          color: Colors.blueGrey.shade50,
                          child: Center(child: Text('Record $index')),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppSplitView(
                      primary: SizedBox(height: 80, child: Text('Primary')),
                      secondary: SizedBox(height: 80, child: Text('Secondary')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflow at ${width}px',
        );
      }
    },
  );
}
