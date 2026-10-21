import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  testWidgets('debug: isolate overflow pump', (tester) async {
    final t = enAuthL10n();
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: Text('x'))),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
