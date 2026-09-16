import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/presentation/customer_approvals_page.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';

/// Approvals is contextual: this page is reached from Home, a Bookings row,
/// Booking Details or a deep link, lists what needs a decision, and opens one
/// estimate's breakdown where the customer approves or rejects it.
void main() {
  setUpAll(_loadFonts);

  group('CustomerApprovalsPage overview', () {
    testWidgets('explains itself when nothing needs a decision', (
      tester,
    ) async {
      await _pumpApprovals(tester);

      expect(find.text('Approvals & billing'), findsOneWidget);
      expect(find.text('Needs your decision'), findsOneWidget);
      expect(find.text('Nothing waiting'), findsOneWidget);
      expect(
        find.textContaining('When the workshop sends an estimate'),
        findsOneWidget,
      );
      expect(find.textContaining('Invoices appear here'), findsOneWidget);
      // No invented counts or placeholder rows.
      expect(find.text('0'), findsNothing);
    });

    testWidgets('lists each pending estimate with its real amount', (
      tester,
    ) async {
      await _pumpApprovals(tester, approvals: const [_pending, _second]);

      expect(find.text('ACTION REQUIRED'), findsNWidgets(2));
      expect(find.text('AED 1,250'), findsOneWidget);
      expect(find.text('AED 480'), findsOneWidget);
      expect(find.text('EST-2048'), findsOneWidget);
      expect(find.text('EST-2049'), findsOneWidget);
      expect(find.text('Sent 15 Sep 2026'), findsOneWidget);
      expect(find.text('Review estimate'), findsNWidgets(2));
    });

    testWidgets('opens the tapped estimate', (tester) async {
      await _pumpApprovals(
        tester,
        approvals: const [_pending, _second],
        detail: _detail,
      );

      await tester.tap(find.text('EST-2048'));
      await tester.pumpAndSettle();

      expect(find.text('Estimate'), findsOneWidget);
      expect(find.text('Estimated total'), findsOneWidget);
    });

    testWidgets('keeps a failed load recoverable', (tester) async {
      await _pumpApprovals(tester, approvalsFail: true);

      expect(find.text("We couldn't load your estimates"), findsOneWidget);
      expect(find.text('Pull down to try again.'), findsOneWidget);
    });

    testWidgets('lists settled invoices and opens their receipt', (
      tester,
    ) async {
      await _pumpApprovals(tester, invoices: const [_paidInvoice]);

      expect(find.text('Settled invoices'), findsOneWidget);
      expect(find.text('INV-2048'), findsOneWidget);
      expect(find.text('AED 1,695'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget);

      await tester.tap(find.text('INV-2048'));
      await tester.pumpAndSettle();
      expect(find.text('INVOICE_DETAIL'), findsOneWidget);
    });

    testWidgets('shows a loading skeleton while estimates arrive', (
      tester,
    ) async {
      await _pumpApprovals(tester, approvalsPending: true, settle: false);
      await tester.pump();

      expect(find.byType(CustomerSkeleton), findsOneWidget);
    });
  });

  group('CustomerApprovalDetailView', () {
    testWidgets('shows what is being approved, in real detail', (tester) async {
      await _pumpApprovals(tester, detail: _detail, estimateId: 'EST-2048');

      expect(find.text('AWAITING APPROVAL'), findsOneWidget);
      expect(find.text('EST-2048'), findsOneWidget);
      expect(find.text('Estimated total'), findsOneWidget);
      expect(find.text('AED 1,250'), findsWidgets);
      expect(find.text('Toyota Land Cruiser'), findsOneWidget);
      expect(find.text('Sent 15 Sep 2026 \u2014 10:30 AM'), findsOneWidget);

      // Line items: services, parts, quantity, unit rate and discounts.
      expect(find.text('What this estimate covers'), findsOneWidget);
      expect(find.text('SERVICES'), findsOneWidget);
      expect(find.text('PARTS'), findsOneWidget);
      expect(find.text('Brake labour'), findsOneWidget);
      expect(find.text('Qty 2 \u00d7 AED 250'), findsOneWidget);
      expect(find.text('Brake pads'), findsOneWidget);
      expect(find.text('Brake fluid'), findsOneWidget);
      expect(
        find.text('Qty 2 \u00d7 AED 100 \u00b7 \u221210%'),
        findsOneWidget,
      );

      // Financial summary from the API totals.
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('AED 700'), findsOneWidget);
      expect(find.text('Parts'), findsOneWidget);
      expect(find.text('AED 550'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Decision actions.
      expect(find.text('Approve estimate'), findsOneWidget);
      expect(find.text('Reject estimate'), findsOneWidget);
    });

    testWidgets('confirms before approving and sends the decision', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource();
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        remote: remote,
        decidedDetail: _detail.approved(),
      );

      await tester.tap(find.text('Approve estimate'));
      await tester.pumpAndSettle();

      expect(find.text('Approve estimate?'), findsOneWidget);
      expect(
        find.text(
          'You are approving work totaling AED 1,250 for Toyota Land Cruiser.',
        ),
        findsOneWidget,
      );
      expect(find.text('Not now'), findsOneWidget);
      expect(
        remote.calls,
        isEmpty,
        reason: 'nothing is sent before confirming',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();

      expect(remote.calls, ['approve:EST-2048']);
      expect(find.textContaining('Estimate approved'), findsOneWidget);
      // The page now reflects the decision instead of stale pending state.
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('Approve estimate'), findsNothing);
      expect(find.text('Reject estimate'), findsNothing);
    });

    testWidgets('rejecting is available but never the loudest action', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource();
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        remote: remote,
        decidedDetail: _detail.rejected(),
      );

      await tester.tap(find.text('Reject estimate'));
      await tester.pumpAndSettle();

      expect(find.text('Reject estimate?'), findsOneWidget);
      expect(find.text('Keep reviewing'), findsOneWidget);
      expect(find.textContaining('ask them for a revised one'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Reject estimate'));
      await tester.pumpAndSettle();

      expect(remote.calls, ['reject:EST-2048']);
      expect(find.text('REJECTED'), findsOneWidget);
      expect(find.textContaining('You rejected this estimate'), findsOneWidget);
    });

    testWidgets('cannot send the same decision twice', (tester) async {
      final remote = _FakeRemoteDataSource(pending: true);
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        remote: remote,
      );

      await tester.tap(find.text('Approve estimate'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pump();

      expect(find.text('Sending\u2026'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(
                of: find.text('Sending\u2026'),
                matching: find.byWidgetPredicate(
                  (widget) => widget is FilledButton,
                ),
              ),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Sending\u2026'), warnIfMissed: false);
      await tester.pump();
      expect(remote.calls, ['approve:EST-2048']);

      remote.complete(true);
      await tester.pumpAndSettle();
      expect(remote.calls, ['approve:EST-2048']);
    });

    testWidgets('keeps the estimate visible when the decision fails', (
      tester,
    ) async {
      final remote = _FakeRemoteDataSource(succeeds: false);
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        remote: remote,
      );

      await tester.tap(find.text('Approve estimate'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't send your decision. Please try again."),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      // Still pending, still reviewable.
      expect(find.text('Brake pads'), findsOneWidget);
      expect(find.text('Approve estimate'), findsOneWidget);
    });

    testWidgets('an already approved estimate is read-only', (tester) async {
      await _pumpApprovals(
        tester,
        detail: _detail.approved(),
        estimateId: 'EST-2048',
      );

      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('Approve estimate'), findsNothing);
      expect(find.text('Reject estimate'), findsNothing);
      expect(find.textContaining('You approved this estimate'), findsOneWidget);
      // The breakdown stays reviewable.
      expect(find.text('Brake pads'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('a missing or replaced estimate never dead-ends', (
      tester,
    ) async {
      await _pumpApprovals(tester, detailFails: true, estimateId: 'EST-9999');

      expect(find.text("We couldn't load this estimate"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('View all approvals'), findsOneWidget);

      await tester.tap(find.text('View all approvals'));
      await tester.pumpAndSettle();
      expect(find.text('Needs your decision'), findsOneWidget);
    });

    testWidgets('stays usable on the smallest phone and at high text scale', (
      tester,
    ) async {
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);

      await _pumpApprovals(
        tester,
        detail: _detailLong,
        estimateId: 'EST-2048',
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('separates the breakdown from the summary on a wide layout', (
      tester,
    ) async {
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        size: const Size(1440, 900),
      );

      final breakdown = tester.getRect(find.text('What this estimate covers'));
      final summary = tester.getRect(find.text('Summary'));
      expect(summary.left, greaterThan(breakdown.left));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme without exceptions', (tester) async {
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Estimated total'), findsOneWidget);
    });
  });

  group('Approvals visual references', () {
    testWidgets('overview with a pending decision', (tester) async {
      await _pumpApprovals(
        tester,
        approvals: const [_pending],
        invoices: const [_paidInvoice],
      );

      await expectLater(
        find.byType(CustomerApprovalsPage),
        matchesGoldenFile('goldens/customer_approvals_overview_mobile.png'),
      );
    });

    testWidgets('estimate detail mobile', (tester) async {
      await _pumpApprovals(tester, detail: _detail, estimateId: 'EST-2048');

      await expectLater(
        find.byType(CustomerApprovalsPage),
        matchesGoldenFile('goldens/customer_approval_detail_mobile.png'),
      );
    });

    testWidgets('tablet composition', (tester) async {
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        size: const Size(1024, 900),
      );

      await expectLater(
        find.byType(CustomerApprovalsPage),
        matchesGoldenFile('goldens/customer_approval_detail_tablet.png'),
      );
    });

    testWidgets('dark mode mobile', (tester) async {
      await _pumpApprovals(
        tester,
        detail: _detail,
        estimateId: 'EST-2048',
        theme: AppTheme.dark(BrandConfig.orient),
      );

      await expectLater(
        find.byType(CustomerApprovalsPage),
        matchesGoldenFile('goldens/customer_approval_detail_dark_mobile.png'),
      );
    });
  });
}

// ─── Fixtures (real entity shapes only) ───────────────────────────────────────

const _pending = CustomerApprovalSummaryResponse(
  estimateId: 'EST-2048',
  customerName: 'Ahmed Al Mansoori',
  amount: 1250,
  status: 'pending',
  createdAt: '15 Sep 2026 \u2014 10:30 AM',
);

const _second = CustomerApprovalSummaryResponse(
  estimateId: 'EST-2049',
  customerName: 'Ahmed Al Mansoori',
  amount: 480,
  status: 'pending',
  createdAt: '16 Sep 2026 \u2014 09:00 AM',
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
  createdAt: '15 Sep 2026 \u2014 10:30 AM',
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

/// Long names and large amounts must not break the layout.
const _detailLong = CustomerApprovalDetailResponse(
  estimateId: 'EST-2048-EXTENDED-REFERENCE',
  customerName: 'Ahmed Al Mansoori',
  vehicleInfo: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
  servicesTotal: 12450,
  partsTotal: 8000,
  grandTotal: 20450,
  status: 'pending',
  createdAt: '15 September 2026 \u2014 10:30 AM',
  services: [
    ApprovalLineItem(
      name:
          'Comprehensive suspension overhaul including control arms and bushings',
      qty: 12,
      rate: 350,
      discountPercent: 15,
      discountAmount: 630,
    ),
  ],
  parts: [
    ApprovalLineItem(
      name: 'Original equipment brake caliper assembly, rear',
      qty: 2,
      rate: 1250,
    ),
  ],
);

class _FakeRemoteDataSource implements CustomerRemoteDataSource {
  _FakeRemoteDataSource({this.succeeds = true, this.pending = false});

  final List<String> calls = [];
  final bool succeeds;
  final bool pending;
  Completer<bool>? _completer;

  @override
  Future<bool> processApproval(String estimateId, String action) {
    calls.add('$action:$estimateId');
    if (pending) {
      _completer ??= Completer<bool>();
      return _completer!.future;
    }
    return Future<bool>.value(succeeds);
  }

  void complete(bool value) => _completer!.complete(value);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  @override
  CustomerDashboardState build() => const CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: [],
    notifications: [],
  );

  /// A decision asks the workspace to refresh; tests keep that a no-op so no
  /// real repository or storage is touched.
  @override
  Future<void> refresh() async {}
}

class _CustomerAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 'test-token');
}

Future<void> _pumpApprovals(
  WidgetTester tester, {
  List<CustomerApprovalSummaryResponse> approvals = const [],
  List<InvoiceResponse> invoices = const [],
  CustomerApprovalDetailResponse? detail,
  CustomerApprovalDetailResponse? decidedDetail,
  bool approvalsFail = false,
  bool detailFails = false,
  bool approvalsPending = false,
  String estimateId = '',
  _FakeRemoteDataSource? remote,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final dataSource = remote ?? _FakeRemoteDataSource();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => CustomerApprovalsPage(estimateId: estimateId),
      ),
      GoRoute(
        path: AppRoutes.customerApprovals,
        builder: (context, state) => CustomerApprovalsPage(
          estimateId: state.uri.queryParameters['estimateId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.customerInvoiceDetail,
        builder: (_, __) => const Scaffold(body: Text('INVOICE_DETAIL')),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (_, __) => const Scaffold(body: Text('DASHBOARD')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(_CustomerAuth.new),
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(ConnectivityResult.wifi),
        ),
        customerRemoteDataSourceProvider.overrideWithValue(dataSource),
        customerDashboardProvider.overrideWith(_FakeDashboardNotifier.new),
        customerBookingsProvider.overrideWith((ref) async => const []),
        customerApprovalsProvider.overrideWith((ref) async {
          if (approvalsPending) {
            await Completer<List<CustomerApprovalSummaryResponse>>().future;
          }
          if (approvalsFail) throw Exception('unavailable');
          return approvals;
        }),
        customerInvoicesProvider.overrideWith((ref) async => invoices),
        customerApprovalDetailProvider.overrideWith((ref, id) async {
          if (detailFails) throw Exception('not found');
          if (decidedDetail != null && dataSource.calls.isNotEmpty) {
            return decidedDetail;
          }
          return detail ?? const CustomerApprovalDetailResponse();
        }),
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
}

extension on CustomerApprovalDetailResponse {
  CustomerApprovalDetailResponse approved() => CustomerApprovalDetailResponse(
    estimateId: estimateId,
    customerName: customerName,
    vehicleInfo: vehicleInfo,
    servicesTotal: servicesTotal,
    partsTotal: partsTotal,
    grandTotal: grandTotal,
    status: 'approved',
    createdAt: createdAt,
    services: services,
    parts: parts,
  );

  CustomerApprovalDetailResponse rejected() => CustomerApprovalDetailResponse(
    estimateId: estimateId,
    customerName: customerName,
    vehicleInfo: vehicleInfo,
    servicesTotal: servicesTotal,
    partsTotal: partsTotal,
    grandTotal: grandTotal,
    status: 'rejected',
    createdAt: createdAt,
    services: services,
    parts: parts,
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
