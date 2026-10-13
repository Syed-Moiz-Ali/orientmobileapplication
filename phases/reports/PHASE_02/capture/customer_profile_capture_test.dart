import 'dart:io';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 02 evidence capture harness (customer Profile feature screen, AR).
/// Copy into `apps/customer_app/test/`, run
/// `flutter test --update-goldens test/phase02_capture_test.dart`, then delete.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  testWidgets('capture customer_profile_390_ar', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    final dashboard = _FakeDashboardNotifier(
      const CustomerDashboardState(
        selectedIndex: 3,
        isLoading: false,
        selectedVehicle: '',
        selectedServiceType: '',
        bookingNotes: '',
        loadError: '',
        vehicles: [_camry, _patrol],
        notifications: [],
        activeService: null,
        profile: _ahmed,
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerDashboardProvider.overrideWith(() => dashboard),
          authNotifierProvider.overrideWith(() => _FakeAuthNotifier(_session)),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: const Locale('ar')),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CustomerProfileTab),
      matchesGoldenFile(
        '../../../phases/reports/PHASE_02/screens/customer_profile_390_ar.png',
      ),
    );
  });
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);
  final CustomerDashboardState _initial;

  @override
  CustomerDashboardState build() => _initial;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._session);
  final MeResponse? _session;

  @override
  AuthState build() => AuthAuthenticated(
        role: UserRole.customer,
        token: 'test-token',
        profile: _session,
      );
}

const _session = MeResponse(
  name: 'أحمد المنصوري',
  email: 'ahmed@example.com',
  phone: '+971 50 123 4567',
);

const _ahmed = CustomerEntity(
  name: 'أحمد المنصوري',
  firstName: 'أحمد',
  avatarInitials: 'AM',
  memberId: 'CUST-042',
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

Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    await (FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(bytes))))
        .load();
  }

  final sep = Platform.pathSeparator;
  final base = '..${sep}..${sep}packages${sep}shared_core${sep}assets'
      '${sep}fonts';
  await load(
    AppFontFamilies.app,
    '$base${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final w in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '$base${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$w.ttf',
    );
  }

  final flutterBin =
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(iconBytes))))
      .load();
}
