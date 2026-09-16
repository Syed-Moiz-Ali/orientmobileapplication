import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Real, action-required states only — a pending estimate approval or a
/// genuinely unpaid invoice.
///
/// Shared by Customer Home (summary) and Status (detail). Both screens route
/// into the existing Approvals destination; neither invents a payment flow.
class CustomerAttentionPanel extends StatelessWidget {
  final String title;
  final List<CustomerApprovalSummaryResponse> approvals;
  final int unpaidInvoices;
  final String Function(double amount) formatAmount;
  final void Function(String estimateId) onReviewEstimate;
  final VoidCallback onViewInvoices;

  const CustomerAttentionPanel({
    super.key,
    required this.approvals,
    required this.unpaidInvoices,
    required this.formatAmount,
    required this.onReviewEstimate,
    required this.onViewInvoices,
    this.title = 'Needs your attention',
  });

  bool get _hasContent => approvals.isNotEmpty || unpaidInvoices > 0;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rows = <Widget>[];

    if (approvals.isNotEmpty) {
      final single = approvals.length == 1;
      final amount = approvals.first.amount;
      rows.add(
        _AttentionRow(
          icon: Icons.fact_check_rounded,
          message: single
              ? (amount > 0
                    ? 'Estimate ${formatAmount(amount)} awaiting your approval'
                    : 'An estimate is awaiting your approval')
              : '${approvals.length} estimates awaiting your approval',
          onTap: () => onReviewEstimate(approvals.first.estimateId),
        ),
      );
    }

    if (unpaidInvoices > 0) {
      rows.add(
        _AttentionRow(
          icon: Icons.receipt_long_rounded,
          message: unpaidInvoices == 1
              ? '1 unpaid invoice'
              : '$unpaidInvoices unpaid invoices',
          onTap: onViewInvoices,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.error.withValues(alpha: 0.06),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.error.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
              const SizedBox(width: AppDimensions.s6),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s6),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const SizedBox(height: AppDimensions.s4),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onTap;

  const _AttentionRow({
    required this.icon,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: message,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s4,
            vertical: AppDimensions.s10,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppDimensions.iconMd, color: colors.error),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact inline feedback for a failed refresh when usable data is already on
/// screen — the information itself is never replaced by an error page.
class CustomerRefreshNotice extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const CustomerRefreshNotice({
    super.key,
    required this.onRetry,
    this.message = "We couldn't refresh your information.",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s12,
        AppDimensions.s8,
        AppDimensions.s8,
        AppDimensions.s8,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.error.withValues(alpha: 0.06),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colors.error),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
