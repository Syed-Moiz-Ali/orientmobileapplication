import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Phase 15 — financials & compliance visual references (EN/AR, 390 + 768 +
/// 1280, light + dark spots, real fonts), reviewed against the Phase 13/14
/// siblings. Deterministic workshop fixtures; no live endpoints.
/// Regenerate with `--update-goldens` only after visual review.
const _delegates = <LocalizationsDelegate<dynamic>>[
  OwnerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Bounded settle: fixed 30x100ms pumps instead of pumpAndSettle, so golden
/// renders can never stick on indeterminate progress animations.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _SeededAr extends AccountsReceivableNotifier {
  @override
  AccountsReceivableState build() => const AccountsReceivableState(
        isLoading: false,
        summary: ARSummary(
          totalOutstanding: 42850,
          days0to30: 21400,
          days31to60: 12800,
          days61to90: 5650,
          days90plus: 3000,
        ),
        records: [
          ARRecord(
            arId: 'AR-2041',
            customer: 'Ahmed Raza',
            invoiceDate: '2026-10-02',
            dueDate: '2026-11-01',
            amount: 12480,
            outstanding: 12480,
            aging: AgingBucket.days0to30,
            contactPerson: 'Ahmed Raza',
            phone: '+971501234567',
          ),
          ARRecord(
            arId: 'AR-1987',
            customer: 'Sara Nasser',
            invoiceDate: '2026-08-14',
            dueDate: '2026-09-13',
            amount: 8920.5,
            outstanding: 8920.5,
            aging: AgingBucket.days61to90,
            contactPerson: 'Sara Nasser',
            phone: '+971507654321',
          ),
          ARRecord(
            arId: 'AR-1902',
            customer: 'Omar Farooq',
            invoiceDate: '2026-06-30',
            dueDate: '2026-07-30',
            amount: 15230.75,
            outstanding: 15230.75,
            aging: AgingBucket.days90plus,
            contactPerson: 'Omar Farooq',
            phone: '+971503334444',
          ),
        ],
      );

  @override
  Future<void> loadData() async {}
}

class _SeededInventory extends InventoryNotifier {
  @override
  InventoryState build() => const InventoryState(
        isLoading: false,
        items: [
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
        ],
        suppliers: [
          InvSupplier(id: 's1', name: 'Gulf Parts', phone: '+9714222333'),
        ],
        purchaseOrders: [
          PurchaseOrderEntity(poRef: 'PO-9001', status: 'Sent', total: '12500'),
        ],
      );

  @override
  Future<void> load() async {}
}

class _SeededTeam extends TeamNotifier {
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
            isActive: true,
          ),
          StaffMember(
            id: 'u3',
            empId: 'SUP-007',
            name: 'Sara Iqbal',
            role: 'supervisor',
            branch: 'Deira',
            phone: '+971503333333',
            isActive: false,
          ),
        ],
        branches: [BranchOption(id: '1', name: 'Al Quoz')],
      );

  @override
  Future<void> load() async {}
}

class _SeededAttendance extends OwnerAttendanceNotifier {
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
            status: 'punchedOut',
            punchIn: '08:00 AM',
            punchOut: '05:00 PM',
            breakTime: '1h 00m',
            workHours: '8h 00m',
          ),
        ],
      );

  @override
  Future<void> load() async {}
}

class _SeededDocs extends DocumentExpiryNotifier {
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
            expiryDate: '2026-12-20',
            daysLeft: 62,
            urgency: ExpiryUrgency.urgent,
          ),
          DocumentExpiry(
            empId: 'EMP-3',
            employeeName: 'Ravi Menon',
            designation: 'Technician',
            documentType: 'Emirates ID',
            expiryDate: '2027-06-01',
            daysLeft: 225,
            urgency: ExpiryUrgency.warning,
          ),
        ],
      );
}

class _SeededFeedback extends ModerationNotifier {
  @override
  ModerationState build() => const ModerationState(
        isLoading: false,
        pending: [
          FeedbackReview(
            id: 'f1',
            rating: '5',
            comment: 'Excellent service, car returned washed and on time.',
            customerName: 'Khalid Mansour',
            date: '2026-10-18',
          ),
          FeedbackReview(
            id: 'f2',
            rating: '2',
            comment:
                'Waited three hours past the promised handover and nobody updated me until I called the workshop twice to ask what was happening with my car.',
            customerName: '',
            date: '2026-10-17',
          ),
        ],
      );

  @override
  Future<void> load() async {}
}

class _SeededSubscription extends SubscriptionNotifier {
  @override
  SubscriptionState build() => const SubscriptionState(
        isLoading: false,
        plan: 'pro',
        status: 'active',
        renewsAt: '2026-11-01',
      );

  @override
  Future<void> load() async {}
}

List<Override> _overrides() => [
      accountsReceivableProvider.overrideWith(_SeededAr.new),
      inventoryProvider.overrideWith(_SeededInventory.new),
      teamProvider.overrideWith(_SeededTeam.new),
      ownerAttendanceProvider.overrideWith(_SeededAttendance.new),
      documentExpiryProvider.overrideWith(_SeededDocs.new),
      moderationProvider.overrideWith(_SeededFeedback.new),
      subscriptionProvider.overrideWith(_SeededSubscription.new),
    ];

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale, {
  required bool dark,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(),
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
  await _settle(tester);
}

void main() {
  setUpAll(_loadFonts);

  const views = <String, Widget>{
    'receivables': AccountsReceivableView(),
    'inventory': InventoryView(),
    'team': TeamView(),
    'attendance': AttendanceView(),
    'expiry': DocumentExpiryView(),
    'feedback': FeedbackModerationView(),
    'subscription': SubscriptionView(),
  };

  for (final entry in views.entries) {
    final name = entry.key;
    final view = entry.value;
    for (final (label, locale) in <(String, Locale)>[
      ('en', const Locale('en')),
      ('ar', const Locale('ar')),
    ]) {
      testWidgets('$name 390 $label', (tester) async {
        await _pump(tester, view, const Size(390, 844), locale, dark: false);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byWidget(view),
          matchesGoldenFile('goldens/owner15_${name}_390_$label.png'),
        );
      });
    }

    testWidgets('$name 768 en tablet', (tester) async {
      await _pump(
        tester,
        view,
        const Size(768, 1024),
        const Locale('en'),
        dark: false,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byWidget(view),
        matchesGoldenFile('goldens/owner15_${name}_768_en.png'),
      );
    });

    testWidgets('$name 1280 en desktop', (tester) async {
      await _pump(
        tester,
        view,
        const Size(1280, 800),
        const Locale('en'),
        dark: false,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byWidget(view),
        matchesGoldenFile('goldens/owner15_${name}_1280_en.png'),
      );
    });

    testWidgets('$name 390 en dark spot', (tester) async {
      await _pump(
        tester,
        view,
        const Size(390, 844),
        const Locale('en'),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byWidget(view),
        matchesGoldenFile('goldens/owner15_${name}_390_dark.png'),
      );
    });
  }

  testWidgets('inventory filter sheet 390 en', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: _delegates,
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(body: InventoryView()),
        ),
      ),
    );
    await _settle(tester);
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await _settle(tester);
    expect(find.text('Filter stock'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/owner15_inventory_sheet_390_en.png'),
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
