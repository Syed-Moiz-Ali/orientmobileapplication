import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class CustomerInvoiceDetailView extends StatelessWidget {
  final InvoiceResponse invoice;

  const CustomerInvoiceDetailView({super.key, required this.invoice});

  (Color, Color) _getStatusColors() {
    switch (invoice.status.toLowerCase()) {
      case 'paid':
        return (const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.12));
      case 'overdue':
        return (const Color(0xFFEF4444), const Color(0xFFEF4444).withValues(alpha: 0.12));
      default:
        return (const Color(0xFFD97706), const Color(0xFFD97706).withValues(alpha: 0.12));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final (statusColor, statusBg) = _getStatusColors();
    final total = invoice.grandTotal > 0 ? invoice.grandTotal : invoice.amount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Invoice Detail'),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      borderRadius: AppDimensions.r24,
                      color: colorScheme.surface,
                      borderColor: colorScheme.outlineVariant,
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: 30,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          Text(
                            invoice.id,
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s10),
                          StatusPill(
                            label: invoice.status.toUpperCase(),
                            bg: statusBg,
                            fg: statusColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    AppAdaptiveGrid(
                      minChildWidth: 300,
                      childAspectRatio: 2.6,
                      children: [
                        _InfoCard(
                          label: 'Bill To',
                          value: invoice.customerName,
                        ),
                        const _InfoCard(label: 'Vehicle Info', value: '-'),
                        _InfoCard(label: 'Date', value: invoice.date),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    AppCard(
                      borderRadius: AppDimensions.r20,
                      color: colorScheme.surface,
                      borderColor: colorScheme.outlineVariant,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Line Items',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s10),
                          Text(
                            'Itemised breakdown is not available yet.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    AppCard(
                      borderRadius: AppDimensions.r20,
                      color: colorScheme.surface,
                      borderColor: colorScheme.outlineVariant,
                      child: Column(
                        children: [
                          _AmountRow(label: 'Subtotal', amount: invoice.amount),
                          if (invoice.taxAmount > 0) ...[
                            const SizedBox(height: AppDimensions.s10),
                            _AmountRow(
                              label:
                                  'VAT (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                              amount: invoice.taxAmount,
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.s14,
                            ),
                            child: Divider(height: 1, color: colorScheme.outlineVariant),
                          ),
                          Row(
                            children: [
                              Text(
                                'Total',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'AED ${total.toStringAsFixed(2)}',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _InvoiceActions(invoice: invoice),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;

  const _AmountRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          'AED ${amount.toStringAsFixed(2)}',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _InvoiceActions extends StatelessWidget {
  final InvoiceResponse invoice;

  const _InvoiceActions({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unpaid = invoice.status.toLowerCase() != 'paid';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unpaid) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment coming soon')),
                    );
                  },
                  child: const Text('Pay Now'),
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF download coming soon')),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
