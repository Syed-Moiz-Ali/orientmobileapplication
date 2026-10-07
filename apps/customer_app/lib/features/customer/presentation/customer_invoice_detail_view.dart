import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

/// What an invoice actually is, from the fields the workshop really returns.
///
/// The backend offers no customer payment, receipt, PDF or by-ref fetch, so
/// this screen presents no actions at all: it reports the invoice and stops.
class CustomerInvoiceDetailView extends ConsumerWidget {
  final InvoiceResponse invoice;

  const CustomerInvoiceDetailView({super.key, required this.invoice});

  (Color, Color) _getStatusColors(ColorScheme colors) {
    switch (invoice.status.toLowerCase()) {
      case 'paid':
        return (colors.tertiary, colors.tertiary.withValues(alpha: 0.12));
      case 'overdue':
        return (colors.error, colors.error.withValues(alpha: 0.12));
      default:
        return (colors.primary, colors.primary.withValues(alpha: 0.12));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final (statusColor, statusBg) = _getStatusColors(colorScheme);
    final total = invoice.grandTotal > 0 ? invoice.grandTotal : invoice.amount;
    final formatAmount = ref.watch(customerDashboardProvider).formatAmount;

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
                                color: colorScheme.primary.withValues(
                                  alpha: 0.22,
                                ),
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
                            label: AppStatusLabels.invoice(invoice.status),
                            bg: statusBg,
                            fg: statusColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    AppAdaptiveGrid(
                      minChildWidth: 300,
                      children: [
                        _InfoCard(
                          label: 'Billed to',
                          value: invoice.customerName,
                        ),
                        _InfoCard(label: 'Issued', value: invoice.date),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    AppCard(
                      borderRadius: AppDimensions.r20,
                      color: colorScheme.surface,
                      borderColor: colorScheme.outlineVariant,
                      child: Column(
                        children: [
                          _AmountRow(
                            label: 'Subtotal',
                            amount: formatAmount(invoice.amount),
                          ),
                          if (invoice.taxAmount > 0) ...[
                            const SizedBox(height: AppDimensions.s10),
                            _AmountRow(
                              label:
                                  'VAT (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                              amount: formatAmount(invoice.taxAmount),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.s14,
                            ),
                            child: Divider(
                              height: 1,
                              color: colorScheme.outlineVariant,
                            ),
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
                              Flexible(
                                child: Text(
                                  formatAmount(total),
                                  textAlign: TextAlign.right,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.primary,
                                  ),
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
  final String amount;

  const _AmountRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Flexible(
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
