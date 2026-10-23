// AFTER captures for the customer notifications list (post-redesign).
//
// Pumps CustomerNotificationsView with deterministic fixtures and writes
// viewport PNGs into docs/ui-redesign/baseline/after-customer-notifications/
// for before/after diffing. No app code is modified; all fakes live here.
//
// Run (from apps/customer_app):
//   flutter test --tags baseline --update-goldens test/customer_notifications_list_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/customer_notifications_list_after_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
//
// Harness rules followed: real bundled fonts via FontLoader in setUpAll
// (Plus Jakarta Sans + IBM Plex Sans Arabic + MaterialIcons from the SDK),
// debugShowCheckedModeBanner: false, shadows restored per test, runAsync with
// a real delay around the pump, connectivity channel mocks (check +
// checkConnectivity), ar via locale + global delegates + AppTheme locale.
// No network, no file I/O in test bodies.
//
// Per the brief this screen has NO search/filter find-aids by design
// (triage-by-recency; sections already are the facets), so instead of a
// sheet-open capture the matrix captures the mark-all-read summary row.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _outDir = 'after-customer-notifications';

// ---------------------------------------------------------------- fixtures

const _service = CustomerNotificationEntity(
  id: 'n1',
  title: 'Booking confirmed',
  body: 'Your Camry is booked for Saturday at 10:00.',
  time: '2h ago',
  type: NotifType.bookingReceived,
);

const _approval = CustomerNotificationEntity(
  id: 'n2',
  title: 'Estimate needs approval',
  body: 'Review the brake estimate before work continues.',
  time: '3h ago',
  type: NotifType.approvalNeeded,
);

const _service2 = CustomerNotificationEntity(
  id: 'n5',
  title: 'Technician assigned',
  body: 'Ali will handle your Camry service today.',
  time: '5h ago',
  type: NotifType.bookingAssigned,
  isRead: true,
);

const _approval2 = CustomerNotificationEntity(
  id: 'n6',
  title: 'Estimate approved',
  body: 'The brake estimate was approved. Work resumes today.',
  time: '8h ago',
  type: NotifType.estimateApproved,
  isRead: true,
);

const _invoice = CustomerNotificationEntity(
  id: 'n3',
  title: 'Invoice ready',
  body: 'Invoice INV-2041 is ready for payment.',
  time: '1d ago',
  type: NotifType.invoiceReady,
  isRead: true,
);

const _general = CustomerNotificationEntity(
  id: 'n4',
  title: 'Workshop update',
  body: 'Holiday hours next week.',
  time: '2d ago',
  type: NotifType.general,
  isRead: true,
);

class _FixedDashNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedDashNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerNotificationEntity> notifications = const [],
}) => CustomerDashboardState(
  selectedIndex: 0,
  isLoading: isLoading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  vehicles: const [],
  notifications: notifications,
  profile: null,
  loadError: loadError,
);

// ---------------------------------------------------------------- harness

/// Locates `<repo>/packages/shared_core/assets/fonts` regardless of whether
/// tests run from the package dir or the repo root.
String _fontRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final candidate =
        '${dir.path}${Platform.pathSeparator}packages${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory(candidate).existsSync()) return candidate;
    final local =
        '${dir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory('$local${Platform.pathSeparator}plus_jakarta_sans')
        .existsSync()) {
      return local;
    }
    dir = dir.parent;
  }
  throw StateError('shared_core font root not found from ${Directory.current.path}');
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
      );
    }
    await loader.load();
  }

  final root = _fontRoot();
  await load('packages/shared_core/Plus Jakarta Sans', [
    '$root/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
  ]);

  // MaterialIcons from the enclosing Flutter SDK (same probe as phase-1).
  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(ByteData.sublistView(candidate.readAsBytesSync())),
        );
      await loader.load();
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required CustomerDashboardState state,
  bool dark = false,
  double scale = 1.0,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double dpr = 3.0,
  bool openSearch = false,
  String searchQuery = '',
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize =
      Size(logicalSize.width * dpr, logicalSize.height * dpr);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);

  // connectivity_plus MethodChannel: offline for both the v6
  // ('checkConnectivity') and v7 ('check') method names.
  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall call) async {
      if (call.method == 'checkConnectivity' || call.method == 'check') {
        return <String>['none'];
      }
      return null;
    },
  );
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    ),
  );

  // runAsync + a real delay (proven pattern from the phase-0a baseline):
  // the pump runs on real event-loop turns while the fake clock stays fixed,
  // so shimmer/transition frames land byte-identically on every run.
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerDashboardProvider.overrideWith(
            () => _FixedDashNotifier(state),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            CustomerLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          darkTheme: AppTheme.dark(BrandConfig.orient, locale: locale),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const CustomerNotificationsView(),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  if (openSearch) {
    // New find sheet (ruling a): AppBar search action top-right, single path.
    await tester.tap(find.byTooltip('Search notifications'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    if (searchQuery.isNotEmpty) {
      await tester.enterText(find.byType(TextField), searchQuery);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(
      '../../../docs/ui-redesign/baseline/$_outDir/$name',
    ),
  );
  debugDisableShadows = oldShadows;
}

String _name(
  String state,
  String theme,
  double scale,
  String locale,
  Size size,
) =>
    '${state}_${theme}_${scale.toStringAsFixed(1)}_${locale}_${size.width.toInt()}x${size.height.toInt()}.png';

// ---------------------------------------------------------------- tests

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('notifications-list after capture: fonts ready');
  });

  // Grouped inbox: Service updates x2 (bookingReceived + bookingAssigned),
  // Approvals x2 (approvalNeeded + estimateApproved), Invoices x1, General x1.
  // Original 4 fixtures kept verbatim; 2 read extras keep unread at 2.
  const inbox = [_service, _service2, _approval, _approval2, _invoice, _general];

  group('after matrix @360x800', () {
    testWidgets('idle inbox light en 1.0 (mark-all row visible)', (
      tester,
    ) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(notifications: inbox),
      );
    });
    testWidgets('single-unread mark-all row light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('markall', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(notifications: const [_service]),
      );
    });
    testWidgets('all-read light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('allread', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(
          notifications: const [
            _invoice,
            _general,
          ],
        ),
      );
    });
    testWidgets('empty light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('empty', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(),
      );
    });
    testWidgets('loading light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('loading', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(isLoading: true),
      );
    });
    testWidgets('error light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('error', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(loadError: 'No connection'),
      );
    });
    testWidgets('stale light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('stale', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(
          notifications: inbox,
          loadError: 'No connection',
        ),
      );
    });
    testWidgets('idle dark en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'dark', 1.0, 'en', const Size(360, 800)),
        state: _state(notifications: inbox),
        dark: true,
      );
    });
    testWidgets('idle light ar 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'ar', const Size(360, 800)),
        state: _state(notifications: inbox),
        locale: const Locale('ar'),
      );
    });
    testWidgets('idle light en 1.3', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.3, 'en', const Size(360, 800)),
        state: _state(notifications: inbox),
        scale: 1.3,
      );
    });
    testWidgets('idle light en 1.0 320px', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(320, 568)),
        state: _state(notifications: inbox),
        logicalSize: const Size(320, 568),
      );
    });
    testWidgets('idle light en 1.0 tablet', (tester) async {
      await _capture(
        tester,
        name: _name('idle', 'light', 1.0, 'en', const Size(768, 1024)),
        state: _state(notifications: inbox),
        logicalSize: const Size(768, 1024),
        dpr: 2.0,
      );
    });
    testWidgets('search sheet open light en 1.0', (tester) async {
      await _capture(
        tester,
        name: _name('search-open', 'light', 1.0, 'en', const Size(360, 800)),
        state: _state(notifications: inbox),
        openSearch: true,
      );
    });
  });
}
