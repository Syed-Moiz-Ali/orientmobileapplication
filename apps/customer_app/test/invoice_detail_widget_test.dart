import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/customer/presentation/customer_invoice_detail_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:shared_core/shared_core.dart';

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
}

void main() {
  Widget wrap(Widget child) => ProviderScope(
    overrides: [
      customerDashboardProvider.overrideWith(_FakeDashboardNotifier.new),
    ],
    child: MaterialApp(home: child),
  );

  testWidgets('renders only the fields the workshop really returns', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CustomerInvoiceDetailView(
          invoice: const InvoiceResponse(
            id: 'INV-001',
            customerName: 'Test Customer',
            date: '10 Aug 2026',
            amount: 355.00,
            status: 'unpaid',
          ),
        ),
      ),
    );

    // Real server data appears, formatted canonically.
    expect(find.text('INV-001'), findsOneWidget);
    expect(find.text('Test Customer'), findsOneWidget);
    expect(find.text('AED 355'), findsWidgets);
    expect(find.text('Unpaid'), findsOneWidget);

    // Fabricated or unavailable content must not appear.
    expect(find.textContaining('VAT ('), findsNothing);
    expect(find.textContaining('\u00a3'), findsNothing);
    expect(find.textContaining('Service Labour'), findsNothing);
    expect(find.textContaining('Parts'), findsNothing);
    expect(find.textContaining('Vehicle Info'), findsNothing);
    expect(find.textContaining('Line Items'), findsNothing);
  });

  testWidgets('shows the server VAT line and treats the grand total as due', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CustomerInvoiceDetailView(
          invoice: const InvoiceResponse(
            id: 'INV-003',
            customerName: 'VAT Customer',
            date: '5 Aug 2026',
            amount: 100.00,
            taxRate: 0.05,
            taxAmount: 5.00,
            grandTotal: 105.00,
            status: 'unpaid',
          ),
        ),
      ),
    );

    expect(find.text('VAT (5%)'), findsOneWidget);
    expect(find.text('AED 5'), findsOneWidget);
    // The headline amount is the grand total, not the subtotal.
    expect(find.text('AED 105'), findsWidgets);
    expect(find.text('AED 100'), findsOneWidget);
  });

  testWidgets('offers no action the workshop cannot perform', (tester) async {
    for (final status in const ['unpaid', 'paid', 'overdue']) {
      await tester.pumpWidget(
        wrap(
          CustomerInvoiceDetailView(
            invoice: InvoiceResponse(
              id: 'INV-002',
              customerName: 'X',
              date: '1 Aug 2026',
              amount: 100.00,
              status: status,
            ),
          ),
        ),
      );

      // No payment, receipt or PDF capability exists, so no control offers one —
      // not even a permanently disabled one.
      expect(find.textContaining('Pay Now'), findsNothing);
      expect(find.textContaining('unavailable'), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('survives a long reference and a large total at 320px @1.6x', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: CustomerInvoiceDetailView(
            invoice: const InvoiceResponse(
              id: 'INV-2026-VERY-LONG-REFERENCE-000123456789',
              customerName: 'Abdulrahman Mohammed Al-Mansoori Al-Falasi',
              date: '10 August 2026',
              amount: 1234567.89,
              taxRate: 0.05,
              taxAmount: 61728.39,
              grandTotal: 1296296.28,
              status: 'overdue',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('AED 1,296,296'), findsWidgets);
  });
}
