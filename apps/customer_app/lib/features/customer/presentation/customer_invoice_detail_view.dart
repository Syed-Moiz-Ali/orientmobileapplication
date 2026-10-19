import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// One workshop invoice as an itemized receipt: who it bills, when it was
/// issued, the subtotal, the server-computed VAT line and the total.
///
/// Display-only by honesty law: the invoice record carries no line items, no
/// discounts and no payment method, and no payment route exists — so there
/// are no pay actions, only the receipt. Amounts render exactly as the API
/// sends them through the shared formatter.
class CustomerInvoiceDetailView extends ConsumerWidget {
  final InvoiceResponse invoice;

  const CustomerInvoiceDetailView({super.key, required this.invoice});

  (Color, Color) _getStatusColors(ColorScheme colors) {
    switch (invoice.status.toLowerCase()) {
      case 'paid':
        return (
          colors.tertiary,
          colors.tertiary.withValues(alpha: 0.12),
        );
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
    final t = context.cx;
    final (statusColor, statusBg) = _getStatusColors(colorScheme);
    final total = invoice.grandTotal > 0 ? invoice.grandTotal : invoice.amount;
    final formatAmount = ref.watch(customerDashboardProvider).formatAmount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar
      // (same title + back behavior; divider now drawn by the bar itself).
      appBar: WorkspaceAppBar(title: t.invTitle, showBack: true),
      body: SafeArea(
        bottom: false,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          maxContentWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.s12),
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
              const SizedBox(height: AppDimensions.s12),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  invoice.id,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s8),
              Align(
                child: StatusPill(
                  label: AppStatusLabels.invoice(invoice.status),
                  bg: statusBg,
                  fg: statusColor,
                ),
              ),
              const SizedBox(height: AppDimensions.s20),
              _InfoCard(label: t.invBilledTo, value: invoice.customerName),
              const SizedBox(height: AppDimensions.s8),
              _InfoCard(label: t.invIssued, value: invoice.date),
              const SizedBox(height: AppDimensions.s16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCard,
                  ),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AmountRow(
                        label: t.invSubtotal,
                        amount: formatAmount(invoice.amount),
                      ),
                      if (invoice.taxAmount > 0) ...[
                        const SizedBox(height: AppDimensions.s10),
                        _AmountRow(
                          label: t.invVat(
                            (invoice.taxRate * 100).toStringAsFixed(0),
                          ),
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
                            t.invTotal,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                formatAmount(total),
                                textAlign: TextAlign.end,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                  fontFamily: AppFontFamilies.mono,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              Text(
                t.invReceiptNote,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
            ],
          ),
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
    final colors = theme.colorScheme;
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Flexible(
            child: Text(
              value.trim(),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
    final colors = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Flexible(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              amount,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFontFamilies.mono,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
