import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/features/common/presentation/simple_pages.dart';
import 'package:staff_app/features/common/presentation/staff_attendance_screen.dart';
import 'package:staff_app/features/common/presentation/staff_shimmer_skeletons.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final MeResponse? _profile;
  final UserRole _role;

  _FakeAuthNotifier({MeResponse? profile, UserRole role = UserRole.technician})
    : _profile = profile,
      _role = role;

  @override
  AuthState build() {
    return AuthAuthenticated(
      role: _role,
      token: 'test_token',
      profile: _profile,
    );
  }
}

class _TestAttendanceNotifier extends StaffAttendanceNotifier {
  final StaffAttendanceState _initialState;
  bool punchInCalled = false;
  bool punchOutCalled = false;
  bool loadCalled = false;

  _TestAttendanceNotifier(this._initialState);

  @override
  StaffAttendanceState build() => _initialState;

  @override
  Future<void> load() async {
    loadCalled = true;
  }

  @override
  Future<bool> punchIn() async {
    punchInCalled = true;
    state = state.copyWith(
      status: StaffAttendanceStatus.working,
      punchIn: '08:30 AM',
    );
    return true;
  }

  @override
  Future<bool> punchOut() async {
    punchOutCalled = true;
    state = state.copyWith(
      status: StaffAttendanceStatus.punchedOut,
      punchOut: '05:30 PM',
      workHours: '9h 00m',
    );
    return true;
  }
}

Future<void> _pumpApp(
  WidgetTester tester,
  Widget child, {
  List<dynamic> overrides = const [],
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: widget!,
        ),
        home: child,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
}

void main() {
  group('Staff Profile Screen', () {
    testWidgets('renders complete technician profile truthfully', (
      tester,
    ) async {
      final profile = ProfileData(
        name: 'Rashid Al Nuaimi',
        id: 'TECH-1042',
        role: 'Technician',
        branch: 'Al Quoz Central',
        shift: 'Morning Shift',
        email: 'rashid@orient.ae',
        phone: '+971 50 123 4567',
        avatarInitials: 'RN',
      );

      await _pumpApp(
        tester,
        StaffProfileScreen(data: profile),
        overrides: [
          authNotifierProvider.overrideWith(
            () => _FakeAuthNotifier(role: UserRole.technician),
          ),
        ],
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Rashid Al Nuaimi'), findsOneWidget);
      expect(find.text('TECH-1042'), findsOneWidget);
      expect(find.text('Al Quoz Central'), findsWidgets);
      expect(find.text('Morning Shift'), findsOneWidget);
      expect(find.text('rashid@orient.ae'), findsOneWidget);
      expect(find.text('+971 50 123 4567'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      // Verify unsupported claims are completely absent
      expect(find.text('Biometric Login'), findsNothing);
      expect(find.text('Account Credentials'), findsNothing);
      expect(find.text('Firebase push enabled after login'), findsNothing);
      expect(find.text('ACTIVE'), findsNothing);
      expect(find.text('STAFF ACCOUNT'), findsNothing);
    });

    testWidgets('renders advisor and supervisor profiles cleanly', (
      tester,
    ) async {
      final advisorProfile = ProfileData(
        name: 'Sarah Jenkins',
        id: 'ADV-201',
        role: 'Service Advisor',
        branch: 'Dubai Marina',
      );

      await _pumpApp(
        tester,
        StaffProfileScreen(data: advisorProfile),
        overrides: [
          authNotifierProvider.overrideWith(
            () => _FakeAuthNotifier(role: UserRole.advisor),
          ),
        ],
      );

      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Service Advisor'), findsWidgets);
      expect(find.text('ADV-201'), findsOneWidget);
      expect(find.text('Dubai Marina'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides empty optional fields without ugly placeholders', (
      tester,
    ) async {
      final minimalProfile = ProfileData(
        name: 'Tariq Aziz',
        id: '',
        role: 'Supervisor',
        branch: '',
        shift: '',
        email: '',
        phone: '',
      );

      await _pumpApp(
        tester,
        StaffProfileScreen(data: minimalProfile),
        overrides: [
          authNotifierProvider.overrideWith(
            () => _FakeAuthNotifier(role: UserRole.supervisor),
          ),
        ],
      );

      expect(find.text('Tariq Aziz'), findsOneWidget);
      expect(find.text('Not available'), findsNothing);
      expect(find.text('Not set'), findsNothing);
      expect(find.text('--'), findsNothing);
      expect(find.text('Contact Details'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('remains overflow-free at small phone width (320px)', (
      tester,
    ) async {
      final longProfile = ProfileData(
        name: 'Muhammad Abdurrahman bin Khalid Al-Qasimi',
        id: 'EMP-998877665544',
        role: 'Senior Diagnostic Specialist & Shop Floor Lead',
        branch: 'Abu Dhabi Industrial Zone Diagnostic Facility',
        shift: 'Rotational Overnight Maintenance Shift',
        email: 'muhammad.abdurrahman.specialist@orient-workshop.ae',
        phone: '+971 50 999 8888',
      );

      await _pumpApp(
        tester,
        StaffProfileScreen(data: longProfile),
        size: const Size(320, 700),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('supports wide desktop layout (1440px)', (tester) async {
      final profile = ProfileData(
        name: 'Omar Farooq',
        id: 'TECH-55',
        role: 'Technician',
        branch: 'Deira Branch',
        email: 'omar@orient.ae',
      );

      await _pumpApp(
        tester,
        StaffProfileScreen(data: profile),
        size: const Size(1440, 900),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Omar Farooq'), findsOneWidget);
      expect(find.text('TECH-55'), findsOneWidget);
    });

    testWidgets('survives 1.6x text scaling without layout breaks', (
      tester,
    ) async {
      final profile = ProfileData(
        name: 'Karim Mostafa',
        id: 'TECH-12',
        role: 'Senior Technician',
        branch: 'Sharjah Industrial 4',
      );

      await _pumpApp(
        tester,
        StaffProfileScreen(data: profile),
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Karim Mostafa'), findsOneWidget);
    });
  });

  group('Staff Attendance Screen', () {
    testWidgets('displays notPunchedIn state with primary Punch In action', (
      tester,
    ) async {
      const state = StaffAttendanceState(
        isLoading: false,
        status: StaffAttendanceStatus.notPunchedIn,
        punchIn: '',
        punchOut: '',
        workHours: '',
      );

      final notifier = _TestAttendanceNotifier(state);

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [staffAttendanceProvider.overrideWith(() => notifier)],
      );

      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Not punched in'), findsOneWidget);
      expect(find.text('NOT PUNCHED IN'), findsOneWidget);
      expect(find.text('Punch In'), findsOneWidget);
      expect(find.text('Punch Out'), findsNothing);
      expect(find.text('Start Break'), findsNothing);
      expect(find.text('End Break'), findsNothing);
    });

    testWidgets('displays working state with Punch Out action', (tester) async {
      const state = StaffAttendanceState(
        isLoading: false,
        status: StaffAttendanceStatus.working,
        punchIn: '08:15 AM',
        punchOut: '',
        workHours: '3h 15m',
      );

      final notifier = _TestAttendanceNotifier(state);

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [staffAttendanceProvider.overrideWith(() => notifier)],
      );

      expect(find.text('Working'), findsOneWidget);
      expect(find.text('WORKING'), findsOneWidget);
      expect(find.text('08:15 AM'), findsOneWidget);
      expect(find.text('3h 15m'), findsOneWidget);
      expect(find.text('Punch Out'), findsOneWidget);
      expect(find.text('Punch In'), findsNothing);
      expect(find.text('Start Break'), findsNothing);
    });

    testWidgets('displays onBreak state correctly with Punch Out preserved', (
      tester,
    ) async {
      const state = StaffAttendanceState(
        isLoading: false,
        status: StaffAttendanceStatus.onBreak,
        punchIn: '08:00 AM',
        breakTime: '30m',
        workHours: '4h 00m',
      );

      final notifier = _TestAttendanceNotifier(state);

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [staffAttendanceProvider.overrideWith(() => notifier)],
      );

      expect(find.text('On break'), findsOneWidget);
      expect(find.text('ON BREAK'), findsOneWidget);
      expect(find.text('Break time'), findsOneWidget);
      expect(find.text('30m'), findsOneWidget);
      expect(find.text('Punch Out'), findsOneWidget);
      expect(find.text('Punch In'), findsNothing);
      expect(find.text('End Break'), findsNothing);
    });

    testWidgets('displays punchedOut state as complete with no punch actions', (
      tester,
    ) async {
      const state = StaffAttendanceState(
        isLoading: false,
        status: StaffAttendanceStatus.punchedOut,
        punchIn: '08:00 AM',
        punchOut: '05:00 PM',
        workHours: '9h 00m',
      );

      final notifier = _TestAttendanceNotifier(state);

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [staffAttendanceProvider.overrideWith(() => notifier)],
      );

      expect(find.text('Shift complete'), findsOneWidget);
      expect(find.text('SHIFT COMPLETE'), findsOneWidget);
      expect(find.text('08:00 AM'), findsOneWidget);
      expect(find.text('05:00 PM'), findsOneWidget);
      expect(find.text('9h 00m'), findsOneWidget);
      expect(find.textContaining('Today’s shift is complete'), findsWidgets);
      expect(find.text('Punch In'), findsNothing);
      expect(find.text('Punch Out'), findsNothing);
    });

    testWidgets('shows skeleton while loading', (tester) async {
      const state = StaffAttendanceState(isLoading: true);

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [
          staffAttendanceProvider.overrideWith(
            () => _TestAttendanceNotifier(state),
          ),
        ],
        settle: false,
      );

      expect(find.byType(StaffAttendanceSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows error view and allows retry', (tester) async {
      const state = StaffAttendanceState(
        isLoading: false,
        error: 'Attendance is unavailable. Check your connection and retry.',
      );

      final notifier = _TestAttendanceNotifier(state);

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [staffAttendanceProvider.overrideWith(() => notifier)],
      );

      expect(find.textContaining('Attendance is unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(notifier.loadCalled, isTrue);
    });

    testWidgets('disables punch button and shows progress while saving', (
      tester,
    ) async {
      const state = StaffAttendanceState(
        isLoading: false,
        isSaving: true,
        status: StaffAttendanceStatus.notPunchedIn,
      );

      await _pumpApp(
        tester,
        const StaffAttendanceScreen(),
        overrides: [
          staffAttendanceProvider.overrideWith(
            () => _TestAttendanceNotifier(state),
          ),
        ],
        settle: false,
      );

      expect(find.text('Punching in…'), findsOneWidget);
      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Punching in…'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('Shift Details Page', () {
    testWidgets('renders shift and schedule accurately', (tester) async {
      final shiftData = {
        'shift': 'Morning Bay Shift A',
        'start': '08:00 AM',
        'end': '05:00 PM',
        'name': 'Ali Hassan',
        'id': 'EMP-77',
        'branch': 'Dubai South Workshop',
      };

      await _pumpApp(tester, ShiftDetailsPage(data: shiftData));

      expect(find.text('Shift Details'), findsOneWidget);
      expect(find.text('Morning Bay Shift A'), findsOneWidget);
      expect(find.text('08:00 AM'), findsOneWidget);
      expect(find.text('05:00 PM'), findsOneWidget);
      expect(find.text('Ali Hassan'), findsOneWidget);
      expect(find.text('EMP-77'), findsOneWidget);
      expect(find.text('Dubai South Workshop'), findsOneWidget);
    });

    testWidgets('gracefully hides omitted fields', (tester) async {
      final partialData = {
        'shift': 'Evening Quick Service',
        'start': '04:00 PM',
      };

      await _pumpApp(tester, ShiftDetailsPage(data: partialData));

      expect(find.text('Evening Quick Service'), findsOneWidget);
      expect(find.text('04:00 PM'), findsOneWidget);
      expect(find.text('Assignment Details'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles small and large screens cleanly', (tester) async {
      final shiftData = {
        'shift': 'Overnight Diagnostic Shift',
        'start': '10:00 PM',
        'end': '06:00 AM',
        'name': 'Sanjay Kumar',
      };

      await _pumpApp(
        tester,
        ShiftDetailsPage(data: shiftData),
        size: const Size(320, 600),
      );
      expect(tester.takeException(), isNull);

      await _pumpApp(
        tester,
        ShiftDetailsPage(data: shiftData),
        size: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Settings Page', () {
    testWidgets('displays truthful sync status and version when available', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        const SettingsPage(data: {'version': '2.4.1 (Build 88)'}),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Local Sync Status'), findsOneWidget);
      expect(find.text('2.4.1 (Build 88)'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);

      // Verify no fake toggles exist
      expect(find.text('Dark Mode'), findsNothing);
      expect(find.text('Notifications'), findsNothing);
      expect(find.text('Biometrics'), findsNothing);
      expect(find.text('Auto Sync'), findsNothing);
    });

    testWidgets('does not fabricate version if missing', (tester) async {
      await _pumpApp(tester, const SettingsPage(data: {}));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App Version'), findsNothing);
      expect(find.text('1.0.0'), findsNothing);
    });
  });
}
