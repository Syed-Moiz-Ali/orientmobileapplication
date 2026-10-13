import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/support/failed_vehicle_delete.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// TEMPORARY Phase 01 evidence capture harness (customer shell).
/// Run from `apps/customer_app`; PNGs land in `phases/reports/PHASE_01/screens/`.
void main() {
  setUpAll(_loadFonts);

  final cases = <String, _Case>{
    'customer_shell_390_light': _Case(const Size(390, 844), 1.0),
    'customer_shell_768_light': _Case(const Size(768, 1024), 1.0),
    'customer_shell_1280_light': _Case(const Size(1280, 800), 1.0),
    'customer_shell_320_light': _Case(const Size(320, 640), 1.0),
    'customer_shell_390_scale13': _Case(const Size(390, 844), 1.3),
    'customer_shell_390_dark': _Case(const Size(390, 844), 1.0, dark: true),
  };

  cases.forEach((name, c) {
    testWidgets('capture $name', (tester) async {
      tester.view.physicalSize = c.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final dashboard = _FakeDashboardNotifier(_initialState());
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const CustomerScaffold()),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerDashboardProvider.overrideWith(() => dashboard),
            customerBookingsProvider.overrideWith((ref) async => const []),
            customerApprovalsProvider.overrideWith((ref) async => const []),
            customerFailedBookingsProvider.overrideWithValue(const []),
            customerFailedVehicleDeletesProvider.overrideWithValue(const []),
            authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
            connectivityStatusProvider.overrideWith(
              (ref) =>
                  Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: c.dark
                ? AppTheme.dark(BrandConfig.orient)
                : AppTheme.light(BrandConfig.orient),
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(c.scale)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomerScaffold),
        matchesGoldenFile(
          '../../../phases/reports/PHASE_01/screens/$name.png',
        ),
      );
    });
  });
}

class _Case {
  final Size size;
  final double scale;
  final bool dark;
  const _Case(this.size, this.scale, {this.dark = false});
}

CustomerDashboardState _initialState() {
  return const CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    loadError: '',
    vehicles: [
      CustomerVehicleEntity(
        id: 'v1',
        brand: 'Toyota',
        model: 'Land Cruiser',
        plateNumber: 'A 12345',
        vin: '',
        color: 'White',
        year: 2021,
        mileage: '48,200 km',
        lastService: '2026-01-12',
        nextDue: '2026-07-12',
        healthScore: 82,
      ),
    ],
    notifications: [],
    activeService: CustomerServiceEntity(
      hasActiveJob: true,
      jobCardId: 'JC-2026-1042',
      plateNumber: 'A 12345',
      vehicleName: 'Toyota Land Cruiser',
      service: 'Full Service',
      started: '2026-09-14',
      estCompletion: '2026-09-16 17:00',
      progressPercent: 45,
      currentStage: 'Quality Check',
      technicianName: 'Ravi',
      stages: [],
    ),
    profile: CustomerEntity(
      name: 'Ahmed Al Mansoori',
      firstName: 'Ahmed',
      avatarInitials: 'AM',
      memberId: 'CUS-1042',
    ),
  );
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;

  @override
  CustomerDashboardState build() => _initial;

  @override
  void selectTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  @override
  void selectDestination(CustomerDestination destination) {
    state = state.copyWith(selectedIndex: destination.index);
  }

  @override
  Future<void> refresh() async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    role: UserRole.customer,
    token: 'test-token',
    profile: null,
  );
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
