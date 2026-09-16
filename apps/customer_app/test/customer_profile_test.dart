import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Profile is the account surface: a real identity, real account actions and a
/// real session control. Nothing here may be invented, and every visible action
/// must have an observable effect.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('customer_profile_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChangeTypeAdapter());
    }
  });

  tearDownAll(() async {
    // Hive.close() can block on Windows when boxes were opened per test, so the
    // temp directory is simply left for the OS to reclaim.
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  // Sign out clears every local box, so they all have to exist.
  setUp(() async {
    for (final name in const [
      'inspections',
      'repair_orders',
      'technician_jobs',
      'supervisor_assignments',
      'customer_bookings',
      'customer_breakdowns',
      'customer_cache',
      'owner_messages',
      'owner_activity',
      'pending_media',
    ]) {
      await Hive.openBox<dynamic>(name);
    }
    await Hive.openBox<SyncOperation>('sync_queue');
    await Hive.openBox<SyncOperation>('sync_failed');
    await Hive.openBox<int>('id_counters');
  });

  group('Account identity', () {
    testWidgets('renders the real name, initials and reference', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _ahmed, vehicles: const [_camry]);

      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);
      expect(find.text('CUST-042'), findsOneWidget);
    });

    testWidgets('never invents a reference when the server sends none', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _unknownReference);

      expect(find.text('102'), findsNothing);
      expect(find.textContaining('Member #'), findsNothing);
      expect(find.textContaining('Verified'), findsNothing);
      // The honest name is still shown.
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
    });

    testWidgets('falls back to a neutral label when there is no name', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _noName);

      expect(find.text('Your account'), findsOneWidget);
      expect(find.text('Customer Profile'), findsNothing);
      expect(find.text('Customer'), findsNothing);
      expect(find.textContaining('Customer #'), findsNothing);
      // No avatar letter is invented either.
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('derives initials from a real name when none are sent', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        profile: const CustomerEntity(
          name: 'Fatima Al Zaabi',
          firstName: 'Fatima',
          avatarInitials: '',
          memberId: '',
        ),
      );

      expect(find.text('FZ'), findsOneWidget);
    });

    testWidgets('shows the session contact details when available', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        session: const MeResponse(
          name: 'Ahmed Al Mansoori',
          email: 'ahmed@example.com',
          phone: '+971 50 123 4567',
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('ahmed@example.com'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('+971 50 123 4567'), findsOneWidget);
    });

    testWidgets('omits contact details when the session has none', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _ahmed);

      expect(find.text('Email'), findsNothing);
      expect(find.text('Phone'), findsNothing);
      expect(find.textContaining('@'), findsNothing);
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
    });

    testWidgets('summarises real vehicles and a live service', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
        activeService: _liveService,
      );

      expect(find.text('2 vehicles  •  Service in progress'), findsOneWidget);
    });

    testWidgets('summarises an empty garage honestly', (tester) async {
      await _pumpProfile(tester, profile: _ahmed, vehicles: const []);

      expect(find.text('No vehicles yet'), findsOneWidget);
    });
  });

  group('No unsupported account content', () {
    testWidgets('renders no membership, rewards or campaign copy', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry],
        session: const MeResponse(email: 'ahmed@example.com', phone: '+971 5'),
      );

      final rendered = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join('\n');

      for (final banned in const [
        'VIP',
        'Loyalty',
        'PTS',
        'Refer',
        'Invite friends',
        'AED 50',
        'AED 14.50',
        'Claim',
        'Rewards',
        'Verified',
        '24/7',
        'Biometric',
        'Face ID',
        'Fingerprint',
        'Push Notifications',
      ]) {
        expect(
          rendered.toLowerCase().contains(banned.toLowerCase()),
          isFalse,
          reason: '"$banned" must not appear on Profile',
        );
      }
    });

    test('never reintroduces fake account content or no-op controls', () {
      // Every file that renders Profile, including its private part file.
      final source = const [
        'lib/features/customer/presentation/widgets/customer_profile_tab.dart',
        'lib/features/customer/presentation/widgets/customer_profile_rows.dart',
      ].map((path) => File(path).readAsStringSync()).join();

      for (final banned in const [
        'VIP',
        'Loyalty',
        'PTS',
        'Refer & Earn',
        'Invite friends',
        'AED 50',
        'AED 14.50',
        'Verified',
        '24/7',
        'Member #',
        "'102'",
        'Biometrics',
        'Face ID',
        'Push Notifications',
      ]) {
        expect(
          source.toLowerCase().contains(banned.toLowerCase()),
          isFalse,
          reason: '"$banned" must not return to Profile',
        );
      }

      expect(
        RegExp(r'\bMOT\b', caseSensitive: false).hasMatch(source),
        isFalse,
      );

      // A visible control with no effect must fail the build.
      expect(source.contains('onTap: () {}'), isFalse);
      expect(source.contains('onChanged: (_) {}'), isFalse);
      expect(source.contains('onPressed: () {}'), isFalse);
    });

    test('has no profile-only dead fixture left behind', () {
      expect(File('lib/core/models/profile_data.dart').existsSync(), isFalse);
    });
  });

  group('Account actions', () {
    testWidgets('Vehicles switches to the permanent Vehicles destination', (
      tester,
    ) async {
      final harness = await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
      );

      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();

      expect(harness.dashboard.selectedTabs, [CustomerDestination.vehicles]);
    });

    testWidgets('Roadside assistance opens the real breakdown route', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _ahmed);

      await tester.tap(find.text('Roadside assistance'));
      await tester.pumpAndSettle();

      expect(find.text('BREAKDOWN_HELP'), findsOneWidget);
    });

    testWidgets('Reset password opens the real recovery flow', (tester) async {
      await _pumpProfile(tester, profile: _ahmed);

      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();

      expect(find.text('FORGOT_PASSWORD'), findsOneWidget);
    });

    testWidgets('Open source licences opens the licence registry', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _ahmed);

      await tester.tap(find.text('Open source licences'));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('keeps the account actions usable when the profile fails', (
      tester,
    ) async {
      await _pumpProfile(tester, loadError: 'boom');

      expect(find.text("We couldn't load your account."), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('Reset password'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });
  });

  group('Sign out', () {
    testWidgets('asks for confirmation before clearing the session', (
      tester,
    ) async {
      final harness = await _pumpProfile(tester, profile: _ahmed);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      expect(harness.auth.logoutCount, 0);
    });

    testWidgets('cancelling keeps the customer signed in', (tester) async {
      final harness = await _pumpProfile(tester, profile: _ahmed);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(harness.auth.logoutCount, 0);
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
    });

    testWidgets('confirming clears the session', (tester) async {
      final harness = await _pumpProfile(tester, profile: _ahmed);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Sign out'),
        findsOneWidget,
        reason: 'the dialog confirm must exist',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();
      expect(
        find.text('Sign out?'),
        findsNothing,
        reason: 'confirming must dismiss the dialog',
      );
      // Signing out clears thirteen real local stores, so alternate real I/O
      // time with frame pumps until the callback lands.
      for (var attempt = 0; attempt < 80; attempt++) {
        if (harness.auth.logoutCount > 0) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }

      expect(harness.auth.logoutCount, 1);
    });
  });

  group('Loading, error and refresh', () {
    testWidgets('shows an account-shaped skeleton on first load', (
      tester,
    ) async {
      await _pumpProfile(tester, loading: true, settle: false);
      await tester.pump();

      expect(find.byType(CustomerSkeleton), findsOneWidget);
      expect(find.text('Profile'), findsNothing);
      expect(find.text('Your account'), findsNothing);
    });

    testWidgets('a failed first load is honest and recoverable', (
      tester,
    ) async {
      final harness = await _pumpProfile(tester, loadError: 'boom');

      expect(find.text("We couldn't load your account."), findsOneWidget);
      expect(find.textContaining('network'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(harness.dashboard.refreshCount, 1);
    });

    testWidgets('a failed refresh keeps the account on screen', (tester) async {
      await _pumpProfile(tester, profile: _ahmed, loadError: 'boom');

      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
      expect(find.text('CUST-042'), findsOneWidget);
      expect(
        find.text("We couldn't refresh your information."),
        findsOneWidget,
      );
    });

    testWidgets('pull to refresh re-fetches the account', (tester) async {
      final harness = await _pumpProfile(tester, profile: _ahmed);

      await tester.fling(
        find.byType(CustomerProfileTab),
        const Offset(0, 320),
        1000,
      );
      await tester.pumpAndSettle();

      expect(harness.dashboard.refreshCount, 1);
    });
  });

  group('Profile layout', () {
    testWidgets('stays overflow-free on every supported width', (tester) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpProfile(
          tester,
          profile: _verbose,
          vehicles: const [_camry, _patrol],
          activeService: _liveService,
          session: const MeResponse(
            email: 'abdulrahman.al-mansoori.al-falasi@example.com',
            phone: '+971 50 123 4567',
          ),
          size: Size(width, 844),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'Profile must not overflow at ${width}px',
        );
      }
    });

    testWidgets('survives 320px at 1.6x text with long values', (tester) async {
      await _pumpProfile(
        tester,
        profile: _verbose,
        vehicles: const [_camry],
        session: const MeResponse(
          email: 'abdulrahman.al-mansoori.al-falasi@example.com',
          phone: '+971 50 123 4567',
        ),
        size: const Size(320, 844),
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.text('abdulrahman.al-mansoori.al-falasi@example.com'),
        findsOneWidget,
      );
      expect(find.text('Vehicles'), findsOneWidget);
    });

    testWidgets('survives 1.6x text and a very long identity', (tester) async {
      await _pumpProfile(
        tester,
        profile: _verbose,
        vehicles: const [_camry],
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Abdulrahman'), findsOneWidget);
    });

    testWidgets('renders in dark mode without a custom surface', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry],
        activeService: _liveService,
        session: _session,
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
    });

    testWidgets('puts the actions beside the identity when there is room', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry],
        size: const Size(1440, 900),
      );

      final identity = tester.getTopLeft(find.text('Ahmed Al Mansoori')).dx;
      final action = tester.getTopLeft(find.text('Vehicles')).dx;
      expect(action, greaterThan(identity));

      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry],
        size: const Size(390, 844),
      );

      // On a phone the actions stack under the identity instead.
      expect(
        tester.getTopLeft(find.text('Vehicles')).dy,
        greaterThan(tester.getTopLeft(find.text('Ahmed Al Mansoori')).dy),
      );
    });

    testWidgets('labels the account surface as a heading', (tester) async {
      await _pumpProfile(tester, profile: _ahmed);

      final semantics = tester.getSemantics(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.header == true,
        ),
      );
      expect(semantics.label, contains('Profile'));
    });
  });

  group('Profile wide composition', () {
    testWidgets('stacks instead of cramping below the wide breakpoint', (
      tester,
    ) async {
      for (final width in const [600.0, 800.0, 900.0]) {
        await _pumpProfile(
          tester,
          profile: _verbose,
          vehicles: const [_camry, _patrol],
          session: _session,
          size: Size(width, 900),
        );

        expect(tester.takeException(), isNull, reason: 'no overflow at $width');
        // Stacked: the identity sits above the account actions and there is no
        // side-by-side session column.
        expect(
          tester.getTopLeft(find.text('Vehicles')).dy,
          greaterThan(tester.getTopLeft(find.textContaining('Abdulrahman')).dy),
          reason: 'must stay stacked at $width',
        );
        expect(find.text('Session'), findsNothing, reason: 'at $width');
      }
    });

    testWidgets('does not stretch rows to fill the canvas', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
        session: _session,
        size: const Size(1440, 900),
      );

      // Three action rows share one compact group: none of them may balloon.
      final vehicles = tester.getRect(find.text('Vehicles'));
      final roadside = tester.getRect(find.text('Roadside assistance'));
      final rowPitch = roadside.top - vehicles.top;
      expect(
        rowPitch,
        inInclusiveRange(48, 90),
        reason: 'action rows stay compact, never stretched cells',
      );
    });

    testWidgets('composes two columns with matched bottom edges', (
      tester,
    ) async {
      for (final width in const [1024.0, 1440.0]) {
        await _pumpProfile(
          tester,
          profile: _ahmed,
          vehicles: const [_camry, _patrol],
          session: _session,
          size: Size(width, 900),
        );
        final label = 'at ${width.toInt()}px';

        expect(tester.takeException(), isNull, reason: 'no overflow $label');

        final identityLeft = tester
            .getTopLeft(find.text('Ahmed Al Mansoori'))
            .dx;
        final actionsLeft = tester.getTopLeft(find.text('Vehicles')).dx;
        expect(
          actionsLeft,
          greaterThan(identityLeft),
          reason: 'the actions sit beside the identity $label',
        );

        final panel = tester.getRect(find.byType(CustomerSurfacePanel));
        final workspace = tester.getRect(_workspace);
        final signOut = tester.getRect(find.text('Sign out'));
        expect(
          panel.bottom,
          closeTo(workspace.bottom, 2),
          reason: 'the identity column fills the workspace height $label',
        );
        expect(
          signOut.bottom,
          inInclusiveRange(workspace.bottom - 60, workspace.bottom),
          reason: 'the session control is anchored low, not floating $label',
        );
        expect(
          workspace.bottom,
          greaterThan(900 * 0.7),
          reason: 'the workspace reaches past the upper half $label',
        );
      }
    });

    testWidgets('uses most of the desktop width', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
        session: _session,
        size: const Size(1440, 900),
      );

      final workspace = tester.getRect(_workspace);
      expect(
        workspace.width,
        greaterThan(1440 * 0.6),
        reason: 'a two-column account workspace must not be a narrow column',
      );
      // It is still a bounded, deliberate column rather than edge to edge.
      expect(workspace.width, lessThan(1440 * 0.95));
    });

    testWidgets('sparse wide data leaves no empty labelled surface', (
      tester,
    ) async {
      await _pumpProfile(tester, profile: _noName, size: const Size(1440, 900));

      expect(tester.takeException(), isNull);
      expect(find.text('Your account'), findsOneWidget);
      expect(find.text('Contact'), findsNothing);
      expect(find.text('Email'), findsNothing);
      expect(find.text('Phone'), findsNothing);
      // The workspace survives: actions and session are still composed.
      expect(find.byType(CustomerSurfacePanel), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('enlarged text falls back to the readable single column', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        profile: _verbose,
        vehicles: const [_camry],
        session: _session,
        size: const Size(1440, 900),
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Session'), findsNothing);
      expect(find.textContaining('Abdulrahman'), findsOneWidget);
    });

    testWidgets('shows a wide, two-sided skeleton while loading', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        loading: true,
        size: const Size(1440, 900),
        settle: false,
      );
      await tester.pump();

      expect(find.byType(CustomerSkeleton), findsOneWidget);
      final boxes = tester.widgetList<CustomerSkeletonBox>(
        find.byType(CustomerSkeletonBox),
      );
      expect(boxes.length, greaterThanOrEqualTo(3));
      expect(find.text('Profile'), findsNothing);
    });
  });

  group('Profile visual references', () {
    testWidgets('mobile', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
        session: _session,
      );
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_mobile.png'),
      );
    });

    testWidgets('sparse data mobile', (tester) async {
      await _pumpProfile(tester, profile: _noName);
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_sparse_data_mobile.png'),
      );
    });

    testWidgets('sparse data desktop', (tester) async {
      await _pumpProfile(tester, profile: _noName, size: const Size(1440, 900));
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_sparse_data_desktop.png'),
      );
    });

    testWidgets('long name mobile', (tester) async {
      await _pumpProfile(
        tester,
        profile: _verbose,
        vehicles: const [_camry],
        session: _session,
      );
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_long_name_mobile.png'),
      );
    });

    testWidgets('tablet', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
        activeService: _liveService,
        session: _session,
        size: const Size(1024, 900),
      );
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_tablet.png'),
      );
    });

    testWidgets('desktop', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry, _patrol],
        activeService: _liveService,
        session: _session,
        size: const Size(1440, 900),
      );
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_desktop.png'),
      );
    });

    testWidgets('dark mobile', (tester) async {
      await _pumpProfile(
        tester,
        profile: _ahmed,
        vehicles: const [_camry],
        activeService: _liveService,
        session: _session,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/customer_profile_dark_mobile.png'),
      );
    });
  });
}

// ─── Harness ─────────────────────────────────────────────────────────────────

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;
  int refreshCount = 0;
  final List<CustomerDestination> selectedTabs = [];

  @override
  CustomerDashboardState build() => _initial;

  @override
  Future<void> refresh() async {
    refreshCount++;
  }

  @override
  void selectDestination(CustomerDestination destination) {
    selectedTabs.add(destination);
    state = state.copyWith(selectedIndex: destination.index);
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._session);

  final MeResponse? _session;
  int logoutCount = 0;

  @override
  AuthState build() => AuthAuthenticated(
    role: UserRole.customer,
    token: 'test-token',
    profile: _session,
  );

  @override
  Future<void> logout() async {
    logoutCount++;
    state = const AuthUnauthenticated();
  }
}

Future<_Harness> _pumpProfile(
  WidgetTester tester, {
  CustomerEntity? profile,
  List<CustomerVehicleEntity> vehicles = const [],
  CustomerServiceEntity? activeService,
  MeResponse? session,
  String loadError = '',
  bool loading = false,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final dashboard = _FakeDashboardNotifier(
    CustomerDashboardState(
      selectedIndex: 0,
      isLoading: loading,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      loadError: loadError,
      vehicles: vehicles,
      notifications: const [],
      activeService: activeService,
      profile: profile,
    ),
  );

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: CustomerProfileTab()),
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownHelp,
        builder: (_, __) => const Scaffold(body: Text('BREAKDOWN_HELP')),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const Scaffold(body: Text('FORGOT_PASSWORD')),
      ),
    ],
  );

  final auth = _FakeAuthNotifier(session);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(() => dashboard),
        authNotifierProvider.overrideWith(() => auth),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return _Harness(dashboard: dashboard, auth: auth);
}

/// The two notifiers a Profile test observes.
class _Harness {
  final _FakeDashboardNotifier dashboard;
  final _FakeAuthNotifier auth;

  const _Harness({required this.dashboard, required this.auth});
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}

// ─── Fixtures ────────────────────────────────────────────────────────────────

/// The wide account workspace, measured by geometry tests.
final Finder _workspace = find.byKey(
  const ValueKey('profile-account-workspace'),
);

const _session = MeResponse(
  name: 'Ahmed Al Mansoori',
  email: 'ahmed@example.com',
  phone: '+971 50 123 4567',
);

const _ahmed = CustomerEntity(
  name: 'Ahmed Al Mansoori',
  firstName: 'Ahmed',
  avatarInitials: 'AM',
  memberId: 'CUST-042',
);

const _unknownReference = CustomerEntity(
  name: 'Ahmed Al Mansoori',
  firstName: 'Ahmed',
  avatarInitials: 'AM',
  memberId: '',
);

const _noName = CustomerEntity(
  name: '',
  firstName: '',
  avatarInitials: '',
  memberId: '',
);

const _verbose = CustomerEntity(
  name: 'Abdulrahman Mohammed Al-Mansoori Al-Falasi',
  firstName: 'Abdulrahman',
  avatarInitials: 'AA',
  memberId: 'CUST-1042',
);

const _camry = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _patrol = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'A 99999',
  vin: '',
  color: 'Black',
  year: 2019,
  mileage: '92,000 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Camry',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  currentStage: 'quality_check',
  technicianName: 'Ravi',
  stages: [],
);
