import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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

/// TEMPORARY Phase 01 evidence capture harness — idle state (customer).
void main() {
  setUpAll(_loadFonts);

  testWidgets('capture customer_shell_390_idle', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final dashboard = _FakeDashboardNotifier(
      const CustomerDashboardState(
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
        profile: CustomerEntity(
          name: 'Ahmed Al Mansoori',
          firstName: 'Ahmed',
          avatarInitials: 'AM',
          memberId: 'CUS-1042',
        ),
      ),
    );

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
            (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CustomerScaffold),
      matchesGoldenFile(
        '../../../phases/reports/PHASE_01/screens/customer_shell_390_idle.png',
      ),
    );
  });
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
