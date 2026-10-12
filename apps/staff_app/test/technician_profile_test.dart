import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    await Hive.openBox<SyncOperation>('sync_queue');
    await Hive.openBox<SyncOperation>('sync_failed');
    await _loadFonts();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
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
      expect(find.text('mohammed.ali@orient.ae'), findsOneWidget);
      expect(find.text('+971 50 123 4567'), findsOneWidget);
    });

    testWidgets('omits absent optional fields gracefully', (tester) async {
      await _pump(tester, data: minimal);

      expect(find.text('Sara Nasser'), findsOneWidget);
      expect(find.text('Contact Details'), findsNothing);
      expect(find.text('Email'), findsNothing);
      expect(find.text('Phone'), findsNothing);
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
        'notification',
      ]) {
        expect(texts.contains(forbidden), isFalse, reason: forbidden);
      }
    });
  });

  group('Technician Profile account actions', () {
    testWidgets('Reset password routes to the real reset flow', (tester) async {
      await _pump(tester, data: technician, router: true);

      expect(find.text('Reset password'), findsOneWidget);
      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();

      expect(find.text('FORGOT_PASSWORD'), findsOneWidget);
    });

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

    testWidgets('confirming sign out signs the technician out', (tester) async {
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
      addTearDown(() => Hive.box<SyncOperation>('sync_queue').clear());

      await _pump(tester, data: technician);
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out with unsynced work?'), findsOneWidget);
      expect(find.textContaining('still waiting to sync'), findsOneWidget);
    });
  });

  group('Technician Profile responsive', () {
    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(tester, data: technician, size: Size(width, 844));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text with long values', (tester) async {
      await _pump(
        tester,
        data: ProfileData(
          name: 'Mohammed Abdulla Al Mansoori Al Suwaidi',
          id: 'EMP-REFERENCE-2026-000000099441',
          role: 'Technician',
          branch: 'Orient Workshop — Al Quoz Industrial Area 4',
          email: 'mohammed.abdulla.al.mansoori@orient.ae',
          phone: '+971 50 123 4567',
        ),
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a two-column layout on tablet and desktop', (
      tester,
    ) async {
      await _pump(tester, data: technician, size: const Size(1024, 768));
      expect(tester.takeException(), isNull);
      expect(find.text('Reset password'), findsOneWidget);

      await _pump(tester, data: technician, size: const Size(1440, 900));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(
        tester,
        data: technician,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Mohammed Ali'), findsOneWidget);
    });

    testWidgets('keeps account actions at 48px', (tester) async {
      await _pump(tester, data: technician);

      final signOut = find.ancestor(
        of: find.text('Sign out'),
        matching: find.byWidgetPredicate((w) => w is OutlinedButton),
      );
      expect(
        tester.getSize(signOut.first).height,
        greaterThanOrEqualTo(AppDimensions.touchTarget),
      );
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('Reset password'),
                    matching: find.byWidgetPredicate(
                      (w) => w is ConstrainedBox,
                    ),
                  )
                  .first,
            )
            .height,
        greaterThanOrEqualTo(AppDimensions.touchTarget),
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
  });
}

// ---------- Harness ----------

class _FakeAuth extends AuthNotifier {
  int logoutCount = 0;

  @override
  AuthState build() =>
      AuthAuthenticated(role: UserRole.technician, token: 'test');

  @override
  Future<void> logout() async {
    logoutCount++;
    state = const AuthUnauthenticated();
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required ProfileData data,
  _FakeAuth? auth,
  bool router = false,
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

  final Widget home;
  if (router) {
    home = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.light(BrandConfig.orient),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => StaffProfileScreen(data: data),
          ),
          GoRoute(
            path: AppRoutes.forgotPassword,
            builder: (_, __) => const Scaffold(body: Text('FORGOT_PASSWORD')),
          ),
        ],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
    );
  } else {
    home = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.light(BrandConfig.orient),
      home: StaffProfileScreen(data: data),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
    );
  }

  await tester.pumpWidget(ProviderScope(overrides: overrides, child: home));
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
