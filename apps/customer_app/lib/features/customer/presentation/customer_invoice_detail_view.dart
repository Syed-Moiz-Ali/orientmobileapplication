import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class CustomerInvoiceDetailView extends StatelessWidget {
  final InvoiceResponse invoice;
  const CustomerInvoiceDetailView({super.key, required this.invoice});

  (Color, Color) _getStatusColors() {
    switch (invoice.status.toLowerCase()) {
      case 'paid':
        return (AppColors.success, AppColors.successBg);
      case 'overdue':
        return (AppColors.danger, AppColors.dangerBg);
      default:
        return (AppColors.warning, AppColors.warningBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = _getStatusColors();

    // FIX (audit P0): subtotal/VAT/line items were FABRICATED from the total
    // (80% subtotal, 20% VAT — UAE VAT is 5%) with a literal "Mocked" label.
    // Only the server-provided amount is shown; the breakdown appears once the
    // backend exposes line items.
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(
              title: 'Invoice Detail',
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.garage_rounded, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    Text(
                      invoice.id,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(AppDimensions.rPill),
                      ),
                      child: Text(
                        invoice.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s32),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bill To',
                            style: TextStyle(fontSize: 12, color: AppColors.text3),
                          ),
                          const SizedBox(height: AppDimensions.s4),
                          Text(
                            invoice.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          const Text(
                            'Vehicle Info',
                            style: TextStyle(fontSize: 12, color: AppColors.text3),
                          ),
                          const SizedBox(height: AppDimensions.s4),
                          const Text(
                            '—',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          const Text(
                            'Date',
                            style: TextStyle(fontSize: 12, color: AppColors.text3),
                          ),
                          const SizedBox(height: AppDimensions.s4),
                          Text(
                            invoice.date,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Line Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          const Text(
                            'Itemised breakdown is not available yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),

                    AppCard(
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.text2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'AED ${invoice.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.s32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimensions.s20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (invoice.status.toLowerCase() != 'paid') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.r12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment coming soon')),
                            );
                          },
                          child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.r12),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PDF download coming soon')),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text('Download Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
