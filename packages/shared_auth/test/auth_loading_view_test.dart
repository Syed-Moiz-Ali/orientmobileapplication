// Phase-2b characterization: AuthLoadingView (startup splash).
//
// The branded navy splash renders without exceptions, announces itself as a
// live region, and shows branding + restoring copy + a progress indicator.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

Future<void> pumpLoadingView(WidgetTester tester) async {
  useTallSurface(tester);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: SharedAuthLocalizations.supportedLocales,
      localizationsDelegates: SharedAuthLocalizations.localizationsDelegates,
      theme: AppTheme.light(BrandConfig.orient),
      home: const AuthLoadingView(),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('AuthLoadingView', () {
    testWidgets('renders branding + restoring copy without exceptions',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoadingView(tester);

      expect(find.text(t.authBrandName), findsOneWidget);
      expect(find.text(t.authBrandSub), findsOneWidget);
      expect(find.text(t.authRestoringSession), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('announces itself as a live region', (tester) async {
      final t = enAuthL10n();
      await pumpLoadingView(tester);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.liveRegion ?? false) &&
              w.properties.label == t.authRestoringSessionSemantics,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on the navy signature surface', (tester) async {
      await pumpLoadingView(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(scaffold.backgroundColor, theme.colorScheme.inverseSurface);
      expect(tester.takeException(), isNull);
    });
  });
}
