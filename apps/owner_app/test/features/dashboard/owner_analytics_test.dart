import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/pages/accounts_receivable_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/attendance_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/document_expiry_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/feedback_moderation_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/inventory_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/subscription_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/team_view.dart';
import 'package:owner_app/features/dashboard/presentation/providers/ar_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/attendance_provider.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/inventory_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/moderation_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/subscription_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  OwnerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

// ─── Fakes (frozen contracts, canned data) ─────────────────────────────────

class _FakeAr extends AccountsReceivableNotifier {
  @override
  AccountsReceivableState build() => const AccountsReceivableState(
        isLoading: false,
        summary: ARSummary(
          totalOutstanding: 15000,
          days0to30: 8000,
          days31to60: 4000,
          days61to90: 2000,
          days90plus: 1000,
        ),
        records: [
          ARRecord(
            arId: 'AR-101',
            customer: 'Ahmed Raza',
            invoiceDate: '2026-10-01',
            dueDate: '2026-10-31',
            amount: 8000,
            outstanding: 8000,
            aging: AgingBucket.days0to30,
            contactPerson: 'Ahmed',
            phone: '+971501234567',
          ),
          ARRecord(
            arId: 'AR-102',
            customer: 'Sara Nasser',
            invoiceDate: '2026-08-01',
            dueDate: '2026-08-31',
            amount: 4000,
            outstanding: 4000,
            aging: AgingBucket.days61to90,
            contactPerson: 'Sara',
            phone: '+971507654321',
          ),
        ],
      );

  @override
  Future<void> loadData() async {}
}

class _FakeInventory extends InventoryNotifier {
  final List<InvItem> seedItems;
  int adjusted = 0;
  Map<String, dynamic>? added;
  _FakeInventory([List<InvItem>? seed]) : seedItems = seed ?? _items;

  @override
  InventoryState build() => InventoryState(
        isLoading: false,
        items: seedItems,
        suppliers: const [
          InvSupplier(id: 's1', name: 'Gulf Parts', phone: '+9714222333'),
        ],
        purchaseOrders: const [
          PurchaseOrderEntity(poRef: 'PO-9001', status: 'Sent', total: '12500'),
        ],
      );

  @override
  Future<void> load() async {}

  @override
  Future<String?> adjustStock(String id, int delta) async {
    adjusted += delta;
    return null;
  }

  @override
  Future<String?> addItem(Map<String, dynamic> payload) async {
    added = payload;
    return null;
  }
}

const _items = [
  InvItem(
    id: 'p1',
    sku: 'BRK-001',
    name: 'Brake pad set',
    category: 'Brakes',
    costPrice: 120,
    sellingPrice: 180,
    qtyOnHand: 25,
    reorderLevel: 5,
  ),
  InvItem(
    id: 'p2',
    sku: 'OIL-010',
    name: 'Engine oil 5W-30',
    category: 'Fluids',
    costPrice: 40,
    sellingPrice: 65,
    qtyOnHand: 3,
    reorderLevel: 10,
  ),
  InvItem(
    id: 'p3',
    sku: 'FLT-100',
    name: 'Oil filter',
    category: 'Filters',
    costPrice: 15,
    sellingPrice: 30,
    qtyOnHand: 0,
    reorderLevel: 8,
  ),
];

class _FakeTeam extends TeamNotifier {
  bool toggled = false;
  Map<String, dynamic>? added;
  _FakeTeam();

  @override
  TeamState build() => const TeamState(
        isLoading: false,
        staff: [
          StaffMember(
            id: 'u1',
            empId: 'ADV-014',
            name: 'Zayn Malik',
            role: 'advisor',
            branch: 'Al Quoz',
            phone: '+971501111111',
            isActive: true,
          ),
          StaffMember(
            id: 'u2',
            empId: 'TEC-042',
            name: 'Ravi Menon',
            role: 'technician',
            branch: 'Al Quoz',
            phone: '+971502222222',
            isActive: false,
          ),
        ],
        branches: [BranchOption(id: '1', name: 'Al Quoz')],
      );

  @override
  Future<void> load() async {}

  @override
  Future<void> toggleActive(StaffMember member) async {
    toggled = true;
  }

  @override
  Future<String?> addMember(Map<String, dynamic> payload) async {
    added = payload;
    return null;
  }
}

class _FakeAttendance extends OwnerAttendanceNotifier {
  @override
  OwnerAttendanceState build() => OwnerAttendanceState(
        isLoading: false,
        selectedDate: DateTime(2026, 10, 19),
        records: const [
          OwnerAttendanceRecord(
            staffId: 'u1',
            empId: 'ADV-014',
            name: 'Zayn Malik',
            role: 'advisor',
            branch: 'Al Quoz',
            date: '2026-10-19',
            status: 'working',
            punchIn: '08:00 AM',
            punchOut: '',
            breakTime: '',
            workHours: '4h 00m',
          ),
          OwnerAttendanceRecord(
            staffId: 'u2',
            empId: 'TEC-042',
            name: 'Ravi Menon',
            role: 'technician',
            branch: 'Al Quoz',
            date: '2026-10-19',
            status: 'notPunchedIn',
            punchIn: '',
            punchOut: '',
            breakTime: '',
            workHours: '',
          ),
        ],
      );

  @override
  Future<void> load() async {}
}

class _FakeDocs extends DocumentExpiryNotifier {
  @override
  DocumentExpiryState build() => const DocumentExpiryState(
        isLoading: false,
        items: [
          DocumentExpiry(
            empId: 'EMP-1',
            employeeName: 'Omar Farooq',
            designation: 'Technician',
            documentType: 'Visa',
            expiryDate: '2026-10-25',
            daysLeft: 6,
            urgency: ExpiryUrgency.critical,
          ),
          DocumentExpiry(
            empId: 'EMP-2',
            employeeName: 'Sara Iqbal',
            designation: 'Advisor',
            documentType: 'Trade license',
            expiryDate: '2027-03-01',
            daysLeft: 133,
            urgency: ExpiryUrgency.warning,
          ),
        ],
      );
}

class _FakeModeration extends ModerationNotifier {
  _FakeModeration();

  @override
  ModerationState build() => const ModerationState(
        isLoading: false,
        pending: [
          FeedbackReview(
            id: 'f1',
            rating: '5',
            comment: 'Excellent service, car returned washed.',
            customerName: 'Khalid Mansour',
            date: '2026-10-18',
          ),
          FeedbackReview(
            id: 'f2',
            rating: '2',
            comment: '',
            customerName: '',
            date: '2026-10-17',
          ),
        ],
      );

  @override
  Future<void> load() async {}

  @override
  Future<void> moderate(String id, bool isPublic) async {
    state = state.copyWith(
      pending: state.pending.where((f) => f.id != id).toList(),
    );
  }
}

class _FakeSubscription extends SubscriptionNotifier {
  String? selected;
  _FakeSubscription();

  @override
  SubscriptionState build() => const SubscriptionState(
        isLoading: false,
        plan: 'pro',
        status: 'active',
        renewsAt: '2026-11-01',
      );

  @override
  Future<void> load() async {}

  @override
  Future<String?> setPlan(String plan) async {
    selected = plan;
    state = state.copyWith(plan: plan);
    return null;
  }
}

List<Override> _base() => [
      accountsReceivableProvider.overrideWith(_FakeAr.new),
      inventoryProvider.overrideWith(_FakeInventory.new),
      teamProvider.overrideWith(_FakeTeam.new),
      ownerAttendanceProvider.overrideWith(_FakeAttendance.new),
      documentExpiryProvider.overrideWith(_FakeDocs.new),
      moderationProvider.overrideWith(_FakeModeration.new),
      subscriptionProvider.overrideWith(_FakeSubscription.new),
    ];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [..._base(), ...extra],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Receivables (buckets + ledger, no collection actions)', () {
    testWidgets('buckets sum the frozen summary honestly', (tester) async {
      await _pump(tester, const AccountsReceivableView());
      // Bucket cards repeat the ledger row figures (same frozen data).
      expect(find.text('AED 8,000.00'), findsWidgets);
      expect(find.text('AED 4,000.00'), findsWidgets);
      // Critical = 61–90 + 90+ buckets combined.
      expect(find.text('AED 3,000.00'), findsOneWidget);
      expect(find.textContaining('AED 15,000.00'), findsOneWidget);
    });

    testWidgets('search narrows, rows open the contact sheet', (tester) async {
      await _pump(tester, const AccountsReceivableView());
      await tester.enterText(find.byType(AppSearchField), 'sara');
      await tester.pumpAndSettle();
      expect(find.text('Sara Nasser'), findsOneWidget);
      expect(find.text('Ahmed Raza'), findsNothing);
      await tester.tap(find.text('Sara Nasser'));
      await tester.pumpAndSettle();
      expect(find.text('Billing contact'), findsOneWidget);
      expect(find.text('+971507654321'), findsOneWidget);
    });

    testWidgets('no-match renders the no-match state', (tester) async {
      await _pump(tester, const AccountsReceivableView());
      await tester.enterText(find.byType(AppSearchField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No debtors match this search.'), findsOneWidget);
    });

    testWidgets('no invented collection actions exist', (tester) async {
      await _pump(tester, const AccountsReceivableView());
      expect(find.text('Collect'), findsNothing);
      expect(find.text('Remind'), findsNothing);
      expect(find.text('Write off'), findsNothing);
    });
  });

  group('Inventory (valuation + thresholds + real flows)', () {
    testWidgets('hero values stock at cost', (tester) async {
      await _pump(tester, const InventoryView());
      // 25×120 + 3×40 + 0×15 = 3,120 at cost (never selling price).
      expect(find.text('AED 3,120.00'), findsOneWidget);
    });

    testWidgets('alert strip separates zero from low stock', (tester) async {
      await _pump(tester, const InventoryView());
      expect(find.text('1 out of stock'), findsOneWidget);
    });

    testWidgets('filter sheet narrows by category', (tester) async {
      await _pump(tester, const InventoryView());
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Brakes'), findsOneWidget);
      await tester.tap(find.text('Brakes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Brake pad set'), findsOneWidget);
      expect(find.text('Engine oil 5W-30'), findsNothing);
    });

    testWidgets('stock sheet adjusts through the notifier', (tester) async {
      final fake = _FakeInventory();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._base(),
            inventoryProvider.overrideWith(() => fake),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: InventoryView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Brake pad set'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('+1'));
      await tester.pumpAndSettle();
      expect(fake.adjusted, 1);
    });

    testWidgets('suppliers and orders tabs render', (tester) async {
      await _pump(tester, const InventoryView());
      await tester.tap(find.text('Suppliers'));
      await tester.pumpAndSettle();
      expect(find.text('Gulf Parts'), findsOneWidget);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('PO-9001'), findsOneWidget);
    });
  });

  group('Team roster (directory + real admin flows)', () {
    testWidgets('counts, search and role filter work', (tester) async {
      await _pump(tester, const TeamView());
      expect(find.text('Zayn Malik'), findsOneWidget);
      expect(find.text('Ravi Menon'), findsOneWidget);
      await tester.enterText(find.byType(AppSearchField), 'ravi');
      await tester.pumpAndSettle();
      expect(find.text('Ravi Menon'), findsOneWidget);
      expect(find.text('Zayn Malik'), findsNothing);
    });

    testWidgets('clock pill joins the day register by staff id', (tester) async {
      await _pump(tester, const TeamView());
      expect(find.text('On shift'), findsOneWidget);
    });

    testWidgets('toggle calls the notifier', (tester) async {
      final fake = _FakeTeam();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [..._base(), teamProvider.overrideWith(() => fake)],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: TeamView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(fake.toggled, isTrue);
    });
  });

  group('Attendance day register', () {
    testWidgets('strip counts and rows render', (tester) async {
      await _pump(tester, const AttendanceView());
      expect(find.text('Zayn Malik'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
      expect(find.text('08:00 AM'), findsOneWidget);
    });

    testWidgets('role filter narrows the register', (tester) async {
      await _pump(tester, const AttendanceView());
      final chip = find.descendant(
        of: find.byType(AppFilterBar),
        matching: find.text('Technicians'),
      );
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Ravi Menon'), findsOneWidget);
      expect(find.text('Zayn Malik'), findsNothing);
    });
  });

  group('Expiry ledger (real countdowns, no renew route)', () {
    testWidgets('bands and countdown pills render', (tester) async {
      await _pump(tester, const DocumentExpiryView());
      expect(find.text('Omar Farooq'), findsOneWidget);
      expect(find.text('6d left'), findsOneWidget);
      expect(find.text('133d left'), findsOneWidget);
    });

    testWidgets('no renew action exists without a route', (tester) async {
      await _pump(tester, const DocumentExpiryView());
      expect(find.text('Renew'), findsNothing);
      expect(find.text('Extend'), findsNothing);
    });
  });

  group('Feedback inbox (real moderate flow, no reply composer)', () {
    testWidgets('approve removes the row with a toast', (tester) async {
      await _pump(tester, const FeedbackModerationView());
      expect(find.text('Khalid Mansour'), findsOneWidget);
      await tester.tap(find.text('Approve').first);
      await tester.pumpAndSettle();
      expect(find.text('Khalid Mansour'), findsNothing);
      expect(find.text('Review moderated.'), findsOneWidget);
    });

    testWidgets('no reply composer exists', (tester) async {
      await _pump(tester, const FeedbackModerationView());
      expect(find.text('Reply'), findsNothing);
      expect(
        find.text('Replies are not available in this version.'),
        findsOneWidget,
      );
    });
  });

  group('Subscription (frozen plan contract)', () {
    testWidgets('hero and catalog render, switch updates', (tester) async {
      await _pump(tester, const SubscriptionView());
      expect(find.text('PROFESSIONAL'), findsOneWidget);
      await tester.tap(find.text('Select').first);
      await tester.pumpAndSettle();
      expect(find.text('Plan updated.'), findsOneWidget);
    });
  });
}
