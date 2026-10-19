import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_approvals_page.dart';
import 'package:customer_app/features/customer/presentation/customer_feedback_view.dart';
import 'package:customer_app/features/customer/presentation/customer_invoice_detail_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

/// Phase 18 rendered-review goldens: status (live + upcoming), approvals
/// overview + estimate detail, invoice receipt and feedback at 390 EN/AR +
/// 834 EN + dark spots, with real fonts (including the Arabic face).
/// Deterministic fixtures; no live endpoints.
const _delegates = <LocalizationsDelegate<dynamic>>[
  CustomerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Land Cruiser',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  currentStage: 'quality_check',
  technicianName: 'Ravi',
  stages: [
    ServiceStageEntity(name: 'Check-In', time: '09:10', status: StageStatus.done),
    ServiceStageEntity(name: 'Inspection', time: '09:40', status: StageStatus.done),
    ServiceStageEntity(name: 'Repair', status: StageStatus.inProgress),
    ServiceStageEntity(name: 'Quality Check', status: StageStatus.pending),
  ],
);

const _upcoming = CustomerBookingEntity(
  id: 'b1',
  service: 'Full Service',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '2026-09-22',
  time: '09:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

const _pending = CustomerApprovalSummaryResponse(
  estimateId: 'EST-2048',
  customerName: 'Ahmed Al Mansoori',
  amount: 1250,
  status: 'pending',
  createdAt: '15 Sep 2026 — 10:30 AM',
);

const _paidInvoice = InvoiceResponse(
  id: 'INV-2048',
  customerName: 'Ahmed Al Mansoori',
  date: '2 Jun 2026',
  amount: 1695,
  taxRate: 5,
  taxAmount: 85,
  grandTotal: 1780,
  status: 'paid',
);

const _detail = CustomerApprovalDetailResponse(
  estimateId: 'EST-2048',
  customerName: 'Ahmed Al Mansoori',
  vehicleInfo: 'Toyota Land Cruiser',
  servicesTotal: 700,
  partsTotal: 550,
  grandTotal: 1250,
  status: 'pending',
  createdAt: '15 Sep 2026 — 10:30 AM',
  services: [
    ApprovalLineItem(name: 'Brake labour', qty: 2, rate: 250),
    ApprovalLineItem(name: 'Inspection', qty: 1, rate: 200),
  ],
  parts: [
    ApprovalLineItem(name: 'Brake pads', qty: 1, rate: 350),
    ApprovalLineItem(
      name: 'Brake fluid',
      qty: 2,
      rate: 100,
      discountPercent: 10,
      discountAmount: 20,
    ),
  ],
);

class _FakeDash extends CustomerDashboardNotifier {
  _FakeDash(this._state);
  final CustomerDashboardState _state;

  @override
  CustomerDashboardState build() => _state;

  @override
  Future<void> refresh() async {}
}

CustomerDashboardState _dashState({CustomerServiceEntity? activeService}) =>
    CustomerDashboardState(
      selectedIndex: 0,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: const [],
      notifications: const [],
      profile: const CustomerEntity(
        name: 'Ahmed Al Mansoori',
        firstName: 'Ahmed',
        avatarInitials: 'AM',
        memberId: 'CUST-042',
      ),
      activeService: activeService,
    );

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        role: UserRole.customer,
        token: 'test_token',
        profile: null,
      );
}

class _FakeRemote implements CustomerRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Override> _overrides({
  CustomerServiceEntity? activeService,
  List<CustomerBookingEntity> bookings = const [_upcoming],
  List<CustomerApprovalSummaryResponse> approvals = const [_pending],
  List<InvoiceResponse> invoices = const [_paidInvoice],
  CustomerApprovalDetailResponse? detail,
}) =>
    [
      customerDashboardProvider.overrideWith(
        () => _FakeDash(_dashState(activeService: activeService)),
      ),
      customerRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      customerBookingsProvider.overrideWith((ref) async => bookings),
      customerApprovalsProvider.overrideWith((ref) async => approvals),
      customerInvoicesProvider.overrideWith((ref) async => invoices),
      if (detail != null)
        customerApprovalDetailProvider.overrideWith(
          (ref, id) async => detail,
        ),
      authNotifierProvider.overrideWith(_FakeAuth.new),
    ];

Future<void> _pumpSurface(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required Locale locale,
  bool dark = false,
  CustomerServiceEntity? activeService,
  List<CustomerBookingEntity> bookings = const [_upcoming],
  List<CustomerApprovalSummaryResponse> approvals = const [_pending],
  List<InvoiceResponse> invoices = const [_paidInvoice],
  CustomerApprovalDetailResponse? detail,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(
        activeService: activeService,
        bookings: bookings,
        approvals: approvals,
        invoices: invoices,
        detail: detail,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  // Bounded pumps: the status tab owns a 60s refresh timer, so pumpAndSettle
  // would never settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('status live 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerServiceStatusTab(),
        size: const Size(390, 844),
        locale: locale,
        activeService: _liveService,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerServiceStatusTab),
        matchesGoldenFile('goldens/status_live_390_$label.png'),
      );
    });

    testWidgets('status upcoming 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerServiceStatusTab(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerServiceStatusTab),
        matchesGoldenFile('goldens/status_upcoming_390_$label.png'),
      );
    });

    testWidgets('approvals overview 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerApprovalsPage(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerApprovalsPage),
        matchesGoldenFile('goldens/approve_overview_390_$label.png'),
      );
    });

    testWidgets('approval detail 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerApprovalsPage(estimateId: 'EST-2048'),
        size: const Size(390, 844),
        locale: locale,
        detail: _detail,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerApprovalsPage),
        matchesGoldenFile('goldens/approve_detail_390_$label.png'),
      );
    });

    testWidgets('invoice 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerInvoiceDetailView(invoice: _paidInvoice),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerInvoiceDetailView),
        matchesGoldenFile('goldens/invoice_390_$label.png'),
      );
    });

    testWidgets('feedback 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerFeedbackView(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerFeedbackView),
        matchesGoldenFile('goldens/feedback_390_$label.png'),
      );
    });
  }

  testWidgets('status live 834 en', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerServiceStatusTab(),
      size: const Size(834, 1112),
      locale: const Locale('en'),
      activeService: _liveService,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerServiceStatusTab),
      matchesGoldenFile('goldens/status_live_834_en.png'),
    );
  });

  testWidgets('approval detail 834 en', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerApprovalsPage(estimateId: 'EST-2048'),
      size: const Size(834, 1112),
      locale: const Locale('en'),
      detail: _detail,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerApprovalsPage),
      matchesGoldenFile('goldens/approve_detail_834_en.png'),
    );
  });

  testWidgets('feedback 834 en', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerFeedbackView(),
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerFeedbackView),
      matchesGoldenFile('goldens/feedback_834_en.png'),
    );
  });

  testWidgets('status live 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerServiceStatusTab(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
      activeService: _liveService,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerServiceStatusTab),
      matchesGoldenFile('goldens/status_live_390_dark.png'),
    );
  });

  testWidgets('approvals overview 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerApprovalsPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerApprovalsPage),
      matchesGoldenFile('goldens/approve_overview_390_dark.png'),
    );
  });

  testWidgets('feedback 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerFeedbackView(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerFeedbackView),
      matchesGoldenFile('goldens/feedback_390_dark.png'),
    );
  });
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String relative) async {
    final bytes = await File(relative).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  final sep = Platform.pathSeparator;
  await load(
    AppFontFamilies.app,
    '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
    '${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
      '${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$weight.ttf',
    );
  }
  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
