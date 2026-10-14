import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 04 closure — focused tests for the app-bar refinements:
/// frosted glass (with accessibility fallback), the integrated offline
/// telemetry pill, and the omnichannel ⌘K / Ctrl+K search shortcut.
void main() {
  Widget host(
    Widget child, {
    bool dark = false,
    Locale locale = const Locale('en'),
    ConnectivityResult connectivity = ConnectivityResult.wifi,
    bool reduceTransparency = false,
  }) {
    return ProviderScope(
      overrides: [
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(connectivity),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          SharedCoreLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        builder: reduceTransparency
            ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                ),
                child: child!,
              )
            : null,
        home: Scaffold(body: child),
      ),
    );
  }

  group('WorkspaceAppBar frosted glass', () {
    testWidgets('default (solid) renders no blur', (tester) async {
      await tester.pumpWidget(
        _scaffoldWithBar(const WorkspaceAppBar(title: 'Today')),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('frosted adds a BackdropFilter and stays readable', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scaffoldWithBar(const WorkspaceAppBar(title: 'Today', frosted: true)),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessibility reduce-transparency falls back to opaque', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scaffoldWithBar(
          const WorkspaceAppBar(title: 'Today', frosted: true),
          reduceTransparency: true,
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('OfflineStatusPill', () {
    testWidgets('online renders the synced state', (tester) async {
      await tester.pumpWidget(host(const OfflineStatusPill()));
      await tester.pump();
      expect(find.text('Synced'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
    });

    testWidgets('offline renders the warning state', (tester) async {
      await tester.pumpWidget(
        host(const OfflineStatusPill(), connectivity: ConnectivityResult.none),
      );
      await tester.pump();
      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('queued work shows the auto-sync count', (tester) async {
      await tester.pumpWidget(
        host(
          const OfflineStatusPill(pendingSyncCount: 3),
          connectivity: ConnectivityResult.none,
        ),
      );
      await tester.pump();
      expect(find.text('3 queued'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });

    testWidgets('localizes in Arabic', (tester) async {
      await tester.pumpWidget(
        host(
          const OfflineStatusPill(),
          locale: const Locale('ar'),
          connectivity: ConnectivityResult.none,
        ),
      );
      await tester.pump();
      expect(find.text('غير متصل'), findsOneWidget);
    });
  });

  group('Omnichannel search trigger + shortcut', () {
    testWidgets('trigger is present and fires onSearch on tap', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        _scaffoldWithBar(
          WorkspaceAppBar(title: 'Today', onSearch: () => fired++),
        ),
      );
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search_rounded));
      expect(fired, 1);
    });

    testWidgets('no trigger when onSearch is null', (tester) async {
      await tester.pumpWidget(_scaffoldWithBar(const WorkspaceAppBar(title: 'Today')));
      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    testWidgets('Ctrl+K fires the shortcut', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        host(
          WorkspaceSearchShortcuts(
            onSearch: () => fired++,
            child: const Scaffold(body: TextField()),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(fired, 1);
    });

    testWidgets('Meta+K (⌘K) fires the shortcut', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        host(
          WorkspaceSearchShortcuts(
            onSearch: () => fired++,
            child: const Scaffold(body: TextField()),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      expect(fired, 1);
    });

    testWidgets('shortcut hint follows platform (⌘K vs Ctrl K)', (
      tester,
    ) async {
      expect(
        WorkspaceAppBar.defaultSearchShortcutLabel(),
        defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.iOS
            ? '⌘K'
            : 'Ctrl K',
      );
    });
  });
}

Widget _scaffoldWithBar(
  PreferredSizeWidget bar, {
  bool reduceTransparency = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: const Locale('en'),
  supportedLocales: AppLocales.supported,
  localizationsDelegates: const [
    SharedCoreLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: AppTheme.light(BrandConfig.orient),
  builder: reduceTransparency
      ? (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        )
      : null,
  home: Scaffold(appBar: bar, body: const SizedBox.shrink()),
);
