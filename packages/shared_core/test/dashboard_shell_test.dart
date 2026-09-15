import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// The Customer workspace has no app bar, so DashboardShell must apply the
/// status bar inset itself. Screens that do have an app bar keep the previous
/// behaviour: the app bar owns the inset and the body starts beneath it.
void main() {
  const bodyKey = Key('shell-body');
  const statusBarTop = 40.0;
  const media = MediaQueryData(
    size: Size(400, 800),
    padding: EdgeInsets.only(top: statusBarTop),
    viewPadding: EdgeInsets.only(top: statusBarTop),
  );

  Future<void> pumpShell(
    WidgetTester tester, {
    PreferredSizeWidget? appBar,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityStatusProvider.overrideWith(
            (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: MediaQuery(
            data: media,
            child: DashboardShell(
              appBar: appBar,
              body: const SizedBox(key: bodyKey, height: 10),
              bottomNavigationBar: const SizedBox(height: 56),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('insets the body below the status bar when there is no app bar', (
    tester,
  ) async {
    await pumpShell(tester);

    expect(tester.getTopLeft(find.byKey(bodyKey)).dy, statusBarTop);
  });

  testWidgets('keeps the app bar responsible for the inset when present', (
    tester,
  ) async {
    await pumpShell(tester, appBar: AppBar());

    final bodyTop = tester.getTopLeft(find.byKey(bodyKey)).dy;
    expect(bodyTop, greaterThanOrEqualTo(kToolbarHeight + statusBarTop));
  });
}
