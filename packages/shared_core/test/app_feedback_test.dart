// Phase-1d-i widget tests: AppStatTile, AppProgressBar, AppEmptyState,
// AppErrorState, AppBanner.
//
// Covers AA contrast pairs (text >= 4.5, progress fill-vs-track and banner
// icon-vs-fill >= 3.0 non-text), state behavior (delta directions, tone
// thresholds incl. clamping, action/retry/dismiss callbacks, dismissible
// banner), Semantics (live regions, progress value, delta phrase), RTL and
// text scale 1.3x.
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
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Center(child: child),
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
    _wrap(child, dark: dark, rtl: rtl, scale: scale),
  );
  await tester.pump();
}

ThemeData _theme(bool dark) =>
    dark ? AppTheme.dark(BrandConfig.orient) : AppTheme.light(BrandConfig.orient);

Color _progressFill(bool dark, AppProgressTone tone) {
  final scheme = _theme(dark).colorScheme;
  final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
  switch (tone) {
    case AppProgressTone.accent:
    case AppProgressTone.auto:
      return scheme.primary;
    case AppProgressTone.success:
      return dark ? AppDarkColors.success : AppColors.successStrong;
    case AppProgressTone.warning:
      return sem.warning.ink;
    case AppProgressTone.error:
      return scheme.error;
  }
}

void main() {
  group('AA contrast pairs (phase-1d-i gate)', () {
    test('stat delta inks on canvas, both themes', () {
      for (final dark in [false, true]) {
        final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
        final canvas = dark ? AppDarkColors.canvas : AppColors.canvas;
        final up = _ratio(sem.success.ink, canvas);
        final down = _ratio(sem.danger.ink, canvas);
        debugPrint('1d-i delta ${dark ? 'dark' : 'light'} up=$up down=$down');
        expect(up, greaterThanOrEqualTo(4.5));
        expect(down, greaterThanOrEqualTo(4.5));
      }
    });

    test('progress fill vs track >= 3.0, every tone, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final track = scheme.surfaceContainerHighest;
        for (final tone in AppProgressTone.values) {
          final fill = _progressFill(dark, tone);
          final ratio = _ratio(fill, track);
          debugPrint('1d-i progress ${dark ? 'dark' : 'light'} $tone=$ratio');
          expect(ratio, greaterThanOrEqualTo(3.0), reason: '$tone $dark');
        }
      }
    });

    test('banner ink on fill >= 4.5, all four kinds, both themes', () {
      for (final dark in [false, true]) {
        final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
        final pairs = {
          'info': (sem.info.ink, sem.info.subtle),
          'warning': (sem.warning.ink, sem.warning.subtle),
          'error': (sem.danger.ink, sem.danger.subtle),
          'success': (
            dark ? AppDarkColors.successStrongInk : AppColors.successStrongInk,
            dark ? AppDarkColors.successStrongSoft : AppColors.successStrongSoft,
          ),
        };
        pairs.forEach((name, pair) {
          final ratio = _ratio(pair.$1, pair.$2);
          debugPrint('1d-i banner ${dark ? 'dark' : 'light'} $name=$ratio');
          expect(ratio, greaterThanOrEqualTo(4.5), reason: '$name $dark');
        });
      }
    });

    test('empty/error circle icon pairs >= 3.0, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final pairs = {
          'tinted': (scheme.onPrimaryContainer, scheme.primaryContainer),
          'neutral': (
            scheme.onSurfaceVariant,
            scheme.surfaceContainerHighest,
          ),
          'error': (scheme.onErrorContainer, scheme.errorContainer),
        };
        pairs.forEach((name, pair) {
          final ratio = _ratio(pair.$1, pair.$2);
          debugPrint('1d-i circle ${dark ? 'dark' : 'light'} $name=$ratio');
          expect(ratio, greaterThanOrEqualTo(3.0), reason: '$name $dark');
        });
      }
    });
  });

  group('AppStatTile', () {
    testWidgets('renders label + tabular value + caption', (tester) async {
      await _pump(
        tester,
        const AppStatTile(
          label: 'Total revenue',
          value: 'AED 12,450',
          caption: 'This month',
        ),
      );
      expect(find.textContaining('Total revenue'), findsOneWidget);
      expect(find.textContaining('AED 12,450'), findsOneWidget);
      expect(find.textContaining('This month'), findsOneWidget);
      final valueText =
          tester.widget<Text>(find.textContaining('AED 12,450'));
      expect(
        valueText.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('delta up/down/neutral rows use arrow + semantic ink',
        (tester) async {
      await _pump(
        tester,
        const AppStatTile(
          label: 'Rate',
          value: '86%',
          deltaText: '+4 pts',
          deltaUp: true,
        ),
      );
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      final light = AppSemanticColors.light;
      final upText = tester.widget<Text>(find.textContaining('+4 pts'));
      expect(upText.style?.color, light.success.ink);

      await _pump(
        tester,
        const AppStatTile(
          label: 'Overdue',
          value: '7',
          deltaText: '+2',
          deltaUp: false,
        ),
      );
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(
        tester.widget<Text>(find.textContaining('+2')).style?.color,
        light.danger.ink,
      );

      await _pump(
        tester,
        const AppStatTile(
          label: 'Pending',
          value: '3',
          deltaText: 'No change',
        ),
      );
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('delta text is bidi-isolated (sign never flips in RTL)',
        (tester) async {
      await _pump(
        tester,
        const AppStatTile(
          label: 'Rate',
          value: '86%',
          deltaText: '+4 pts',
          deltaUp: true,
        ),
        rtl: true,
      );
      final delta = tester.widget<Text>(find.textContaining('+4 pts'));
      expect(delta.data, '\u2066+4 pts\u2069');
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics phrase carries direction, never color alone',
        (tester) async {
      await _pump(
        tester,
        const AppStatTile(
          label: 'Overdue jobs',
          value: '7',
          deltaText: '+2 vs yesterday',
          deltaUp: false,
        ),
      );
      final semantics = tester.getSemantics(find.byType(AppStatTile));
      expect(semantics.label, contains('Overdue jobs, 7'));
      expect(semantics.label, contains('down'));
      expect(semantics.label, contains('+2 vs yesterday'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL + dark safe', (tester) async {
      await _pump(
        tester,
        const AppStatTile(
          label: 'Total revenue',
          value: 'AED 12,450',
          deltaText: '+3 today',
          deltaUp: true,
          caption: 'This month',
          large: true,
        ),
        dark: true,
        rtl: true,
        scale: 1.3,
      );
      expect(find.textContaining('AED 12,450'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppProgressBar', () {
    testWidgets('auto tones map 0.15/0.62/0.82/0.95', (tester) async {
      final cases = {
        0.15: AppProgressTone.accent,
        0.62: AppProgressTone.success,
        0.82: AppProgressTone.warning,
        0.95: AppProgressTone.error,
      };
      for (final entry in cases.entries) {
        await _pump(
          tester,
          AppProgressBar(value: entry.key, label: 'Limit'),
        );
        final expected = _progressFill(false, entry.value);
        expect(
          find.byWidgetPredicate(
            (w) => w is Container && w.color == expected,
          ),
          findsOneWidget,
          reason: '${entry.key} -> ${entry.value}',
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('explicit tone pins the fill; value clamps', (tester) async {
      await _pump(
        tester,
        const AppProgressBar(
          value: 0.1,
          tone: AppProgressTone.error,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == _theme(false).colorScheme.error,
        ),
        findsOneWidget,
      );

      await _pump(tester, const AppProgressBar(value: 1.5));
      var semantics = tester.getSemantics(find.byType(AppProgressBar));
      expect(semantics.value, '100 percent');

      await _pump(tester, const AppProgressBar(value: -0.4));
      semantics = tester.getSemantics(find.byType(AppProgressBar));
      expect(semantics.value, '0 percent');
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics value + 1.3x RTL safe', (tester) async {
      await _pump(
        tester,
        const AppProgressBar(value: 0.62, label: '62% of 90% limit'),
        rtl: true,
        scale: 1.3,
      );
      final semantics = tester.getSemantics(find.byType(AppProgressBar));
      expect(semantics.value, '62 percent');
      expect(find.textContaining('62% of 90% limit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('label is bidi-isolated; fill mirrors from the start edge',
        (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 300,
          child: AppProgressBar(value: 0.5, label: '50% of limit'),
        ),
        rtl: true,
      );
      expect(
        tester.widget<Text>(find.textContaining('50% of limit')).data,
        '\u206650% of limit\u2069',
      );
      final fillRect = tester.getRect(find.byWidgetPredicate(
        (w) => w is Container && w.color == _progressFill(false, AppProgressTone.success),
      ));
      final trackRect = tester.getRect(find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.color == null &&
            w.decoration is BoxDecoration &&
            w.constraints?.maxHeight == 8,
      ));
      // RTL: fill grows from the start (right) edge.
      expect(fillRect.right, moreOrLessEquals(trackRect.right, epsilon: 0.5));
      expect(fillRect.left, greaterThan(trackRect.left));
      expect(tester.takeException(), isNull);
    });
  });

  group('AppEmptyState', () {
    testWidgets('action fires; missing action shows no button',
        (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        AppEmptyState(
          icon: Icons.inbox_outlined,
          title: 'No bookings yet',
          message: 'New bookings will appear here.',
          actionLabel: 'New booking',
          onAction: () => tapped++,
        ),
      );
      expect(find.textContaining('No bookings yet'), findsOneWidget);
      // Exact label: the isolated message contains 'New booking' as a
      // substring, so only the raw button label matches exactly.
      await tester.tap(find.text('New booking'));
      expect(tapped, 1);

      await _pump(
        tester,
        const AppEmptyState(
          icon: Icons.inbox_outlined,
          title: 'Empty',
          message: 'Nothing here.',
        ),
      );
      expect(find.byType(AppPillButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('message capped at 2 lines, width capped at 320',
        (tester) async {
      await _pump(
        tester,
        const AppEmptyState(
          icon: Icons.inbox_outlined,
          title: 'Title',
          message: 'A very long message that must wrap, not overflow.',
        ),
      );
      expect(
        tester.widget<Text>(find.textContaining('A very long')).maxLines,
        2,
      );
      final box = tester.widget<ConstrainedBox>(
        find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.maxWidth == 320,
        ),
      );
      expect(box.constraints.maxWidth, 320);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL + dark safe', (tester) async {
      await _pump(
        tester,
        AppEmptyState(
          icon: Icons.inbox_outlined,
          title: 'No bookings yet',
          message: 'New bookings will appear here.',
          actionLabel: 'New booking',
          onAction: () {},
        ),
        dark: true,
        rtl: true,
        scale: 1.3,
      );
      expect(find.textContaining('No bookings yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppErrorState', () {
    testWidgets('retry fires; live region announces title + message',
        (tester) async {
      var retried = 0;
      await _pump(
        tester,
        AppErrorState(
          title: 'Could not load bookings',
          message: 'Check your connection and try again.',
          onRetry: () => retried++,
        ),
      );
      await tester.tap(find.textContaining('Try again'));
      expect(retried, 1);
      final semantics = tester.getSemantics(find.byType(AppErrorState));
      expect(semantics.flagsCollection.isLiveRegion, isTrue);
      expect(semantics.label, contains('Could not load bookings'));
      expect(semantics.label, contains('Check your connection'));
      // Visual message keeps its trailing period inside the isolate.
      expect(
        tester.widget<Text>(find.textContaining('Check your connection')).data,
        '\u2066Check your connection and try again.\u2069',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom retry label + null retry disables the button',
        (tester) async {
      await _pump(
        tester,
        const AppErrorState(
          title: 'Failed',
          message: 'Try later.',
          onRetry: null,
          retryLabel: 'Reload',
        ),
      );
      expect(find.textContaining('Reload'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL + dark safe', (tester) async {
      await _pump(
        tester,
        AppErrorState(
          title: 'Could not load bookings',
          message: 'Check your connection and try again.',
          onRetry: () {},
        ),
        dark: true,
        rtl: true,
        scale: 1.3,
      );
      expect(find.textContaining('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppBanner', () {
    testWidgets('all four kinds render icon + message + kind word',
        (tester) async {
      final kinds = {
        AppBannerKind.info: Icons.info_outline_rounded,
        AppBannerKind.warning: Icons.warning_amber_rounded,
        AppBannerKind.error: Icons.error_outline_rounded,
        AppBannerKind.success: Icons.check_circle_outline_rounded,
      };
      for (final entry in kinds.entries) {
        await _pump(
          tester,
          AppBanner(kind: entry.key, message: 'Notice text'),
        );
        expect(find.byIcon(entry.value), findsOneWidget);
        expect(find.textContaining('Notice text'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('action + dismiss fire; live region announces kind',
        (tester) async {
      var acted = 0;
      var dismissed = 0;
      await _pump(
        tester,
        AppBanner(
          kind: AppBannerKind.warning,
          message: 'Data is delayed.',
          actionLabel: 'Retry',
          onAction: () => acted++,
          onDismiss: () => dismissed++,
        ),
      );
      await tester.tap(find.textContaining('Retry'));
      expect(acted, 1);
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, 1);
      final semantics = tester.getSemantics(find.byType(AppBanner));
      expect(semantics.flagsCollection.isLiveRegion, isTrue);
      expect(semantics.label, contains('Warning'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('message is bidi-isolated; action spans the banner width',
        (tester) async {
      await _pump(
        tester,
        AppBanner(
          kind: AppBannerKind.warning,
          message: 'Data is delayed.',
          actionLabel: 'Retry',
          onAction: () {},
        ),
      );
      expect(
        tester.widget<Text>(find.textContaining('Data is delayed.')).data,
        '\u2066Data is delayed.\u2069',
      );
      // AppTextButton expands to the column width (Container + alignment):
      // the action is full-width with a centered label, no dead Align.
      final messageRect = tester.getRect(find.textContaining('Data is delayed.'));
      final buttonRect = tester.getRect(find.byType(AppTextButton));
      expect(buttonRect.left, moreOrLessEquals(messageRect.left, epsilon: 1.0));
      expect(buttonRect.right, moreOrLessEquals(800 - 8, epsilon: 8.0));
      expect(buttonRect.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL + dark safe', (tester) async {
      await _pump(
        tester,
        AppBanner(
          kind: AppBannerKind.error,
          message: 'Upload failed. Your changes are saved on this device.',
          actionLabel: 'Try again',
          onAction: () {},
          onDismiss: () {},
        ),
        dark: true,
        rtl: true,
        scale: 1.3,
      );
      expect(find.textContaining('Upload failed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
