import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('tech_profile_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChangeTypeAdapter());
    }
    // Mirrors HiveRegistry.initHive() so HiveCleaner.clearAll() (real logout)
    // works end-to-end in tests.
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
    await _loadFonts();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    await Hive.box<SyncOperation>('sync_queue').clear();
    await Hive.box<SyncOperation>('sync_failed').clear();
  });

  final technician = ProfileData(
    name: 'Mohammed Ali',
    id: 'EMP-1024',
    role: 'Technician',
    branch: 'Orient Workshop — Al Quoz',
    shift: 'Morning',
    email: 'mohammed.ali@orient.ae',
    phone: '+971 50 123 4567',
    avatarInitials: 'MA',
  );

  final minimal = ProfileData(
    name: 'Sara Nasser',
    id: '',
    role: 'Technician',
    branch: '',
  );

  group('Technician Profile identity', () {
    testWidgets('shows the real signed-in identity', (tester) async {
      await _pump(tester, data: technician);

      expect(find.text('Mohammed Ali'), findsOneWidget);
      expect(find.text('MA'), findsOneWidget);
      expect(find.text('EMP-1024'), findsOneWidget);
      expect(find.text('Technician'), findsWidgets);
      expect(find.text('Orient Workshop — Al Quoz'), findsWidgets);
    });

    testWidgets('shows real work and contact details', (tester) async {
      await _pump(tester, data: technician);

      expect(find.text('Work Information'), findsOneWidget);
      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Branch'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('mohammed.ali@orient.ae'), findsOneWidget);
      expect(find.text('+971 50 123 4567'), findsOneWidget);
    });

    testWidgets('omits absent optional fields gracefully', (tester) async {
      await _pump(tester, data: minimal);

      expect(find.text('Sara Nasser'), findsOneWidget);
      expect(find.text('Contact Details'), findsNothing);
      expect(find.text('Email'), findsNothing);
      expect(find.text('Phone'), findsNothing);
      expect(find.text('Not available'), findsNothing);
      expect(find.text('Not set'), findsNothing);
      expect(find.text('—'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('never shows fake performance or HR content', (tester) async {
      await _pump(tester, data: technician);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final forbidden in const [
        'performance',
        'efficiency',
        'rating',
        'achievement',
        'badge',
        'reward',
        'points',
        'member since',
        'joined',
        'certification',
        'manager',
        'emergency contact',
        'edit profile',
        'change photo',
        'upload',
        'notification',
        'preference',
      ]) {
        expect(texts.contains(forbidden), isFalse, reason: forbidden);
      }
    });

    testWidgets('offers no fake profile or avatar editing affordances', (
      tester,
    ) async {
      await _pump(tester, data: technician);

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.photo_camera), findsNothing);
      expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
      expect(find.byIcon(Icons.camera_alt), findsNothing);
      expect(find.textContaining('Edit'), findsNothing);
      expect(find.textContaining('Change photo'), findsNothing);
    });
  });

  group('Technician Profile account actions', () {
    testWidgets('sign out asks for confirmation and can be cancelled', (
      tester,
    ) async {
      final auth = _FakeAuth();
      await _pump(tester, data: technician, auth: auth);

      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      await tester.tap(find.text('Stay signed in'));
      await tester.pumpAndSettle();

      expect(auth.logoutCount, 0);
      expect(find.text('Mohammed Ali'), findsOneWidget);
    });

    testWidgets('confirming sign out invokes the session logout', (
      tester,
    ) async {
      final auth = _FakeAuth();
      await _pump(tester, data: technician, auth: auth);

      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(auth.logoutCount, 1);
    });

    testWidgets('warns truthfully when work is still waiting to sync', (
      tester,
    ) async {
      // Hive writes are real file I/O, so they must run outside the
      // fake-async zone used by testWidgets.
      await tester.runAsync(() async {
        await Hive.box<SyncOperation>('sync_queue').put(
          'op1',
          SyncOperation(
            id: 'op1',
            entityType: 'work_item',
            entityId: 'JO-1|t1|start',
            changeType: ChangeType.update,
            payload: const {},
            timestamp: 1,
          ),
        );
      });

      await _pump(tester, data: technician);
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out with unsynced work?'), findsOneWidget);
      expect(find.textContaining('still waiting to sync'), findsOneWidget);
    });

    testWidgets('opens the platform licence page from the account section', (
      tester,
    ) async {
      final observer = _RecordingNavigatorObserver();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authNotifierProvider.overrideWith(() => _FakeAuth())],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            navigatorObservers: [observer],
            home: StaffProfileScreen(data: technician),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Open source licences'));
      await tester.pumpAndSettle();

      // Deliberately no pump after the tap: the real Flutter licence page
      // collects its registry asynchronously in a way that never settles in a
      // widget test. Asserting the pushed route proves the real action runs.
      final initialRoutes = observer.pushed.length;
      await tester.tap(find.text('Open source licences'));
      expect(observer.pushed.length, initialRoutes + 1);
      expect(observer.pushed.last, isA<MaterialPageRoute<dynamic>>());
    });

    testWidgets('every visible action has a real callback', (tester) async {
      await _pump(tester, data: technician);

      final inkWells = tester.widgetList<InkWell>(
        find.descendant(
          of: find.byType(StaffProfileScreen),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWells, isNotEmpty);
      for (final inkWell in inkWells) {
        expect(inkWell.onTap, isNotNull);
      }

      final signOut = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Sign out'),
          matching: find.byWidgetPredicate((w) => w is OutlinedButton),
        ),
      );
      expect(signOut.onPressed, isNotNull);
    });

    testWidgets('pushed profile supports working back navigation', (
      tester,
    ) async {
      final auth = _FakeAuth();
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('HOME')),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => StaffProfileScreen(data: technician),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authNotifierProvider.overrideWith(() => auth)],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          ),
        ),
      );
      router.push(AppRoutes.profile);
      await tester.pumpAndSettle();

      final back = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back_rounded),
      );
      expect(back.onPressed, isNotNull);
      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.arrow_back_rounded),
      );
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });
  });

  group('Technician Profile session safety', () {
    testWidgets(
      'reset password reaches the real recovery flow while signed in, and '
      'logout closes authenticated routes and shows the new identity',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);

        final auth = _FakeAuth(
          profile: const MeResponse(
            name: 'Mohammed Ali',
            empId: 'EMP-1024',
            role: 'technician',
          ),
        );
        final container = ProviderContainer(
          overrides: [authNotifierProvider.overrideWith(() => auth)],
        );
        addTearDown(container.dispose);
        final router = container.read(appRouterProvider);
        router.go(AppRoutes.profile);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(BrandConfig.orient),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Real router shows the signed-in profile.
        expect(find.text('Mohammed Ali'), findsOneWidget);
        expect(find.text('Reset password'), findsOneWidget);

        // Reset password opens the real OTP recovery flow instead of being
        // redirected back to the dashboard (regression: dead account action).
        await tester.tap(find.text('Reset password'));
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPasswordView), findsOneWidget);
        expect(find.text('Forgot your password?'), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('Mohammed Ali'), findsOneWidget);

        // Logout: the authenticated profile route is no longer reachable and
        // the login screen is shown.
        auth.emit(const AuthUnauthenticated());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(LoginView), findsOneWidget);
        expect(find.byType(StaffProfileScreen), findsNothing);

        // A different account signing in must never see the previous
        // technician's identity.
        auth.emit(
          const AuthAuthenticated(
            role: UserRole.technician,
            token: 'token2',
            profile: MeResponse(
              name: 'Sara Nasser',
              empId: 'EMP-2002',
              role: 'technician',
            ),
          ),
        );
        router.go(AppRoutes.profile);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Sara Nasser'), findsOneWidget);
        expect(find.text('Mohammed Ali'), findsNothing);
        expect(find.text('EMP-2002'), findsOneWidget);
        expect(find.text('EMP-1024'), findsNothing);
      },
    );

    test('real logout clears credentials, caches and queued work', () async {
      final storage = _FakeTokenStorage();
      final datasource = _FakeAuthDatasource();
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
          authDatasourceProvider.overrideWithValue(datasource),
        ],
      );
      addTearDown(container.dispose);

      container.read(authNotifierProvider.notifier);
      for (var i = 0; i < 100; i++) {
        if (container.read(authNotifierProvider) is! AuthLoading) break;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());

      await Hive.box<dynamic>(
        'technician_jobs',
      ).put('technician_profile', {'name': 'Mohammed Ali'});
      await Hive.box<SyncOperation>('sync_queue').put(
        'op1',
        SyncOperation(
          id: 'op1',
          entityType: 'work_item',
          entityId: 'JO-1|t1|start',
          changeType: ChangeType.update,
          payload: const {},
          timestamp: 1,
        ),
      );
      expect(HiveCleaner.hasPendingSync(), isTrue);

      await container.read(authNotifierProvider.notifier).logout();

      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
      expect(datasource.logoutCalls, 1);
      expect(storage.cleared, isTrue);
      expect(await storage.getToken(), isNull);
      expect(await storage.getRole(), isNull);
      expect(Hive.box<dynamic>('technician_jobs').isEmpty, isTrue);
      expect(HiveCleaner.hasPendingSync(), isFalse);
    });
  });

  group('Technician Profile responsive', () {
    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(tester, data: technician, size: Size(width, 844));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('shows long values in full at 1.6x text without truncation', (
      tester,
    ) async {
      const longName = 'Mohammed Abdulla Al Mansoori Al Suwaidi';
      const longEmpId = 'EMP-REFERENCE-2026-000000099441';
      const longEmail = 'mohammed.abdulla.al.mansoori@orient-workshop.ae';
      const longBranch = 'Orient Workshop — Al Quoz Industrial Area 4';

      await _pump(
        tester,
        data: ProfileData(
          name: longName,
          id: longEmpId,
          role: 'Technician',
          branch: longBranch,
          email: longEmail,
          phone: '+971 50 123 4567',
        ),
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(longName), findsOneWidget);
      expect(find.text(longEmpId), findsOneWidget);
      expect(find.text(longEmail), findsOneWidget);
      expect(find.text(longBranch), findsOneWidget);

      // Identity values must wrap rather than being clipped with ellipsis.
      for (final value in const [longName, longEmpId, longEmail, longBranch]) {
        final text = tester.widget<Text>(find.text(value));
        expect(text.maxLines, isNull, reason: value);
        expect(text.overflow, anyOf(isNull, TextOverflow.clip), reason: value);
      }
    });

    testWidgets('composes two columns on tablet and desktop', (tester) async {
      await _pump(tester, data: technician, size: const Size(1024, 768));
      expect(tester.takeException(), isNull);

      final name = tester.getTopLeft(find.text('Mohammed Ali'));
      final work = tester.getTopLeft(find.text('Work Information'));
      expect(work.dx, greaterThan(name.dx));
      expect((work.dy - name.dy).abs(), lessThan(48));

      final bounded = find.byWidgetPredicate(
        (w) => w is ConstrainedBox && w.constraints.maxWidth == 1000,
      );
      expect(bounded, findsOneWidget);
      expect(tester.getSize(bounded).width, lessThanOrEqualTo(1000));

      await _pump(tester, data: technician, size: const Size(1440, 900));
      expect(tester.takeException(), isNull);
      final desktopName = tester.getTopLeft(find.text('Mohammed Ali'));
      final desktopWork = tester.getTopLeft(find.text('Work Information'));
      expect(desktopWork.dx, greaterThan(desktopName.dx));
    });

    testWidgets('stacks sections vertically on mobile', (tester) async {
      await _pump(tester, data: technician, size: const Size(390, 844));
      final name = tester.getTopLeft(find.text('Mohammed Ali'));
      final work = tester.getTopLeft(find.text('Work Information'));
      expect(work.dy, greaterThan(name.dy + 40));
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(
        tester,
        data: technician,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Mohammed Ali'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('keeps every account action at 48px', (tester) async {
      await _pump(tester, data: technician);

      Future<void> expectMinTouchTarget(Finder finder) async {
        expect(
          tester.getSize(finder.first).height,
          greaterThanOrEqualTo(AppDimensions.touchTarget),
        );
      }

      await expectMinTouchTarget(
        find.ancestor(
          of: find.text('Sign out'),
          matching: find.byWidgetPredicate((w) => w is OutlinedButton),
        ),
      );
      await expectMinTouchTarget(
        find.ancestor(
          of: find.text('Reset password'),
          matching: find.byType(ConstrainedBox),
        ),
      );
      await expectMinTouchTarget(
        find.ancestor(
          of: find.text('Open source licences'),
          matching: find.byType(ConstrainedBox),
        ),
      );
    });
  });

  group('Technician Profile references', () {
    Future<void> golden(WidgetTester tester, String name) => expectLater(
      find.byType(StaffProfileScreen),
      matchesGoldenFile('goldens/$name.png'),
    );

    testWidgets('mobile', (tester) async {
      await _pump(tester, data: technician);
      await golden(tester, 'technician_profile_mobile');
    });

    testWidgets('minimal mobile', (tester) async {
      await _pump(tester, data: minimal);
      await golden(tester, 'technician_profile_minimal_mobile');
    });

    testWidgets('tablet', (tester) async {
      await _pump(tester, data: technician, size: const Size(1024, 768));
      await golden(tester, 'technician_profile_tablet');
    });

    testWidgets('desktop', (tester) async {
      await _pump(tester, data: technician, size: const Size(1440, 900));
      await golden(tester, 'technician_profile_desktop');
    });

    testWidgets('dark mobile', (tester) async {
      await _pump(
        tester,
        data: technician,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await golden(tester, 'technician_profile_dark_mobile');
    });

    testWidgets('large text mobile', (tester) async {
      await _pump(
        tester,
        data: technician,
        textScaler: const TextScaler.linear(1.6),
      );
      await golden(tester, 'technician_profile_large_text_mobile');
    });

    testWidgets('sign-out dialog', (tester) async {
      await _pump(tester, data: technician);
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile('goldens/technician_profile_signout_mobile.png'),
      );
    });

    // The profile screen is shared by all staff personas; these two references
    // guard the common composition against Advisor/Supervisor regressions.
    testWidgets('advisor profile reference', (tester) async {
      await _pump(
        tester,
        data: ProfileData(
          name: 'Sarah Jenkins',
          id: 'ADV-201',
          role: 'Service Advisor',
          branch: 'Dubai Marina',
          shift: 'Morning Shift',
          email: 'sarah.jenkins@orient.ae',
          phone: '+971 50 555 0101',
          avatarInitials: 'SJ',
        ),
        auth: _FakeAuth(role: UserRole.advisor),
      );
      await golden(tester, 'staff_profile_advisor_mobile');
    });

    testWidgets('supervisor profile reference', (tester) async {
      await _pump(
        tester,
        data: ProfileData(
          name: 'Tariq Aziz',
          id: 'SUP-77',
          role: 'Supervisor',
          branch: 'Al Quoz Central',
          shift: 'Day Shift',
          email: 'tariq.aziz@orient.ae',
          avatarInitials: 'TA',
        ),
        auth: _FakeAuth(role: UserRole.supervisor),
      );
      await golden(tester, 'staff_profile_supervisor_mobile');
    });
  });
}

// ---------- Harness ----------

class _FakeAuth extends AuthNotifier {
  int logoutCount = 0;
  final AuthState _initialState;

  _FakeAuth({MeResponse? profile, UserRole role = UserRole.technician})
    : _initialState = AuthAuthenticated(
        role: role,
        token: 'test',
        profile: profile,
      );

  @override
  AuthState build() => _initialState;

  void emit(AuthState state) => this.state = state;

  @override
  Future<void> logout() async {
    logoutCount++;
    state = const AuthUnauthenticated();
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }
}

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(const FlutterSecureStorage());

  bool cleared = false;
  String? _token = 'seed-token';
  String? _refresh = 'seed-refresh';
  String? _role = 'technician';

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<String?> getRefreshToken() async => _refresh;

  @override
  Future<String?> getRole() async => _role;

  @override
  Future<void> save({
    required String token,
    String? refreshToken,
    required String role,
  }) async {
    _token = token;
    _refresh = refreshToken ?? _refresh;
    _role = role;
  }

  @override
  Future<void> updateToken(String token) async {
    _token = token;
  }

  @override
  Future<void> setMetadata(String key, String value) async {}

  @override
  Future<String?> getMetadata(String key) async => null;

  @override
  Future<void> clearAll() async {
    cleared = true;
    _token = null;
    _refresh = null;
    _role = null;
  }
}

class _FakeAuthDatasource implements AuthDatasource {
  int logoutCalls = 0;

  @override
  Future<Result<MeResponse>> getMe() async => const Success(
    MeResponse(name: 'Mohammed Ali', empId: 'EMP-1024', role: 'technician'),
  );

  @override
  Future<Result<void>> logout() async {
    logoutCalls++;
    return const Success(null);
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async =>
      const Failure(UnauthorizedException('refresh disabled in tests'));

  @override
  Future<Result<void>> sendOtp(String phone) async =>
      const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async =>
      const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<void>> sendEmailOtp(String email) async =>
      const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) async =>
      const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async => const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) async => const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) async => const Failure(NetworkException('not used in tests'));

  @override
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  ) async => const Failure(NetworkException('not used in tests'));
}

Future<void> _pump(
  WidgetTester tester, {
  required ProfileData data,
  _FakeAuth? auth,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final overrides = <Override>[
    authNotifierProvider.overrideWith(() => auth ?? _FakeAuth()),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        home: StaffProfileScreen(data: data),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
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
