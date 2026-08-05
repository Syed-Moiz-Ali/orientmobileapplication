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
    
    // Mocking some data that is not in InvoiceResponse
    final subtotal = invoice.amount * 0.8;
    final vat = invoice.amount * 0.2;
    
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
                            'Customer Vehicle (Mocked)',
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
                          _buildLineItem('Service Labour', 1, subtotal * 0.6),
                          const Divider(height: 24, color: AppColors.border),
                          _buildLineItem('Parts', 2, subtotal * 0.4 / 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    
                    AppCard(
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', subtotal),
                          const SizedBox(height: AppDimensions.s8),
                          _buildSummaryRow('VAT (20%)', vat),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: AppColors.border),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '\u00a3${invoice.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
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
  
  Widget _buildLineItem(String description, int qty, double rate) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$qty x \u00a3${rate.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.text3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '\u00a3${(qty * rate).toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.text2,
          ),
        ),
        const Spacer(),
        Text(
          '\u00a3${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
