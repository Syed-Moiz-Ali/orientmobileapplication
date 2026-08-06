import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/customer/presentation/customer_invoice_detail_view.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('invoice detail renders only server data — no fabricated VAT/line items',
      (tester) async {
    await tester.pumpWidget(wrap(CustomerInvoiceDetailView(
      invoice: const InvoiceResponse(
        id: 'INV-001',
        customerName: 'Test Customer',
        date: '10 Aug 2026',
        amount: 355.00,
        status: 'unpaid',
      ),
    )));

    // Real server data must appear.
    expect(find.text('INV-001'), findsOneWidget);
    expect(find.text('Test Customer'), findsOneWidget);
    expect(find.text('AED 355.00'), findsOneWidget);

    // Fabricated breakdown must NOT appear (audit P0 regression guard).
    expect(find.textContaining('VAT'), findsNothing);
    expect(find.textContaining('Subtotal'), findsNothing);
    expect(find.textContaining('\u00a3'), findsNothing);
    expect(find.textContaining('Mocked'), findsNothing);
    expect(find.textContaining('Service Labour'), findsNothing);
    expect(find.textContaining('Parts'), findsNothing);
  });

  testWidgets('paid invoices hide the Pay Now action', (tester) async {
    await tester.pumpWidget(wrap(CustomerInvoiceDetailView(
      invoice: const InvoiceResponse(
        id: 'INV-002',
        customerName: 'X',
        date: '1 Aug 2026',
        amount: 100.00,
        status: 'paid',
      ),
    )));

    expect(find.text('Pay Now'), findsNothing);
  });
}
