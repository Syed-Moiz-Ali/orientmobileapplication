import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_estimate_math.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_price_breakdown_dock.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 09 — frozen estimate math plus the new studio dock / qty / tier
/// projections.
///
/// The provider/model getters (`ServiceLineItem.amount`,
/// `PartLineItem.amount`) are byte-identical contracts: amount equals
/// rate × qty minus the discount amount. The dock never recomputes a line —
/// it projects the provider-owned parts/labor totals into the statutory 5%
/// VAT breakdown. Tier, stock and technician decorations are deterministic
/// display-only helpers.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _dockHarness({
  required double partsTotal,
  required double laborTotal,
  required int lineCount,
}) =>
    MaterialApp(
      localizationsDelegates: _delegates,
      supportedLocales: StaffLocalizations.supportedLocales,
      home: Scaffold(
        body: RepairPriceBreakdownDock(
          partsTotal: partsTotal,
          laborTotal: laborTotal,
          lineCount: lineCount,
          onConfirm: () {},
        ),
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('frozen line math (providers byte-identical)', () {
    test('service amount is rate × qty minus discount amount', () {
      const line = ServiceLineItem(
        name: 'Brake pads',
        qty: 2,
        rate: 120,
        discountAmount: 20,
      );
      expect(line.amount, 220);
    });

    test('part amount is rate × qty minus discount amount', () {
      const line = PartLineItem(
        name: 'Oil filter',
        qty: 3,
        rate: 45.5,
        discountAmount: 6.5,
      );
      expect(line.amount, closeTo(130.0, 0.0001));
    });

    test('zero-qty and zero-rate lines price to zero', () {
      expect(const ServiceLineItem(name: 'x', qty: 0, rate: 99).amount, 0);
      expect(const PartLineItem(name: 'y', qty: 2, rate: 0).amount, 0);
    });

    test('qty recalc is live: bumping qty bumps the line total', () {
      const one = ServiceLineItem(name: 'Wheel alignment', qty: 1, rate: 150);
      const two = ServiceLineItem(name: 'Wheel alignment', qty: 2, rate: 150);
      expect(one.amount, 150);
      expect(two.amount, 300);
      const partOne = PartLineItem(name: 'Spark plug', qty: 1, rate: 35);
      const partFour = PartLineItem(name: 'Spark plug', qty: 4, rate: 35);
      expect(partFour.amount - partOne.amount, closeTo(105.0, 0.0001));
    });
  });

  group('VAT projection (statutory 5% display only)', () {
    test('subtotal is parts + labor', () {
      const totals = RepairEstimateTotals(parts: 200, labor: 350, vat: 27.5);
      expect(totals.subtotal, 550);
      expect(totals.total, 577.5);
    });

    test('factory applies exactly 5% over the provider base', () {
      final totals = RepairEstimateTotals.from(
        partsTotal: 200,
        laborTotal: 350,
      );
      expect(totals.parts, 200);
      expect(totals.labor, 350);
      expect(totals.subtotal, 550);
      expect(totals.vat, closeTo(27.5, 0.0001));
      expect(totals.total, closeTo(577.5, 0.0001));
    });

    test('empty estimate projects zero money (no invented totals)', () {
      final totals = RepairEstimateTotals.from(partsTotal: 0, laborTotal: 0);
      expect(totals.subtotal, 0);
      expect(totals.vat, 0);
      expect(totals.total, 0);
    });

    test('VAT rate constant is the UAE statutory 5%', () {
      expect(kUaeVatRate, 0.05);
    });
  });

  group('tier classifier (deterministic safety split)', () {
    test('safety keywords are mandatory', () {
      for (final name in [
        'Brake pads',
        'Front brake discs',
        'Battery voltage inspection',
        'Timing belt replacement',
        'Steering rack',
        'Radiator flush',
        'ABS sensor',
      ]) {
        expect(
          classifyRepairTier(name),
          RepairTier.mandatory,
          reason: name,
        );
      }
    });

    test('anything else is an optional enhancement', () {
      for (final name in [
        'Engine oil change',
        'Wheel alignment',
        'Air filter replacement',
        'A/c Overhauling',
        'Spark plug replacement',
      ]) {
        expect(
          classifyRepairTier(name),
          RepairTier.optional,
          reason: name,
        );
      }
    });

    test('classification is case-insensitive', () {
      expect(classifyRepairTier('BRAKE FLUID FLUSH'), RepairTier.mandatory);
      expect(classifyRepairTier('brake fluid flush'), RepairTier.mandatory);
    });
  });

  group('display decorations (deterministic, never persisted)', () {
    test('stock bay stays inside the 8-bay workshop', () {
      for (final name in ['Brake pad set', 'Oil filter', 'Radiator cap']) {
        final bay = stockBayFor(name);
        expect(bay, inInclusiveRange(1, 8), reason: name);
        expect(stockBayFor(name), bay, reason: 'stable for $name');
      }
    });

    test('order ETA is one of the known supplier windows', () {
      for (final name in ['Alloy wheel', 'Clutch cable', 'Drive belt']) {
        expect(
          orderEtaFor(name),
          isIn(['2h', '4h', '6h', '24h']),
          reason: name,
        );
      }
    });

    test('technician load stays inside the 0–5 job window', () {
      for (final emp in ['EMP001', 'EMP002', 'TECH-7']) {
        final load = loadForTechnician(emp);
        expect(load, inInclusiveRange(0, 5), reason: emp);
        expect(loadForTechnician(emp), load);
        expect(isFree(emp), load == 0);
      }
    });

    test('technician skills are never empty', () {
      for (final emp in ['EMP001', 'EMP002', 'TECH-7']) {
        final skills = skillsForTechnician(emp);
        expect(skills, isNotEmpty, reason: emp);
        expect(skills.length, inInclusiveRange(1, 2));
      }
    });
  });

  group('money dock widget (provider totals in, MoneyAed out)', () {
    testWidgets('shows parts, labor, 5% VAT and total via MoneyAed',
        (tester) async {
      await tester.pumpWidget(
        _dockHarness(partsTotal: 200, laborTotal: 350, lineCount: 3),
      );
      await _settle(tester);

      expect(find.text(MoneyAed(200).format()), findsOneWidget);
      expect(find.text(MoneyAed(350).format()), findsOneWidget);
      expect(find.text(MoneyAed(27.5).format()), findsOneWidget);
      expect(find.text(MoneyAed(577.5).format()), findsOneWidget);
      expect(
        find.text(StaffLocalizations.of(
          tester.element(find.byType(RepairPriceBreakdownDock)),
        )!.advisorStudioConfirm),
        findsOneWidget,
      );
    });

    testWidgets('empty estimate asks for items instead of confirming',
        (tester) async {
      await tester.pumpWidget(
        _dockHarness(partsTotal: 0, laborTotal: 0, lineCount: 0),
      );
      await _settle(tester);

      final context = tester.element(find.byType(RepairPriceBreakdownDock));
      expect(
        find.text(StaffLocalizations.of(context)!.advisorStudioAddItems),
        findsOneWidget,
      );
      expect(find.text(MoneyAed(0).format()), findsWidgets);
    });

    testWidgets('live recalc follows incoming totals on rebuild',
        (tester) async {
      await tester.pumpWidget(
        _dockHarness(partsTotal: 100, laborTotal: 100, lineCount: 2),
      );
      await _settle(tester);
      expect(find.text(MoneyAed(210).format()), findsOneWidget);

      await tester.pumpWidget(
        _dockHarness(partsTotal: 200, laborTotal: 100, lineCount: 2),
      );
      await _settle(tester);
      expect(find.text(MoneyAed(315).format()), findsOneWidget);
    });
  });
}
