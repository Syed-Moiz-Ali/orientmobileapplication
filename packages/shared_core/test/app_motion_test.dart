import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 — reduced-motion resolver.
///
/// `AppMotion.resolve` collapses every token duration to instant when the
/// platform requests reduced motion (`MediaQuery.disableAnimations`), and the
/// shared animated widgets keep working in that mode.
void main() {
  testWidgets('resolve collapses durations under disableAnimations', (
    tester,
  ) async {
    Duration? resolved;
    bool? reduced;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              reduced = AppMotion.reducedMotion(context);
              resolved = AppMotion.resolve(context, AppMotion.emphasized);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(reduced, isTrue);
    expect(resolved, Duration.zero);
  });

  testWidgets('resolve passes durations through when animations are allowed', (
    tester,
  ) async {
    Duration? resolved;
    bool? reduced;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            reduced = AppMotion.reducedMotion(context);
            resolved = AppMotion.resolve(context, AppMotion.standard);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(reduced, isFalse);
    expect(resolved, AppMotion.standard);
  });

  testWidgets('shared animated widgets render under reduced motion', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(BrandConfig.orient),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: ListView(
              children: [
                AppCard.standard(child: const Text('Card')),
                EmptyState(message: 'Nothing here yet', title: 'Empty'),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () => taps++,
                ),
                const AppSkeleton.card(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Card'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  test('motion tokens stay within the frozen 100/160/220/280 ms set', () {
    expect(AppMotion.instant.inMilliseconds, 100);
    expect(AppMotion.fast.inMilliseconds, 160);
    expect(AppMotion.standard.inMilliseconds, 220);
    expect(AppMotion.emphasized.inMilliseconds, 280);
  });
}
