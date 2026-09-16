import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_approval_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_approval_detail_view.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Contextual Approvals page.
///
/// Approvals is not a permanent destination: the backend only exposes *pending*
/// estimate decisions, so this page exists while a decision is genuinely
/// outstanding and is opened from Home, a Bookings row, Booking Details or a
/// deep link. It lists what needs a decision — and the settled invoices, which
/// have no other entry point — while `?estimateId=` opens one estimate's
/// decision directly.
class CustomerApprovalsPage extends ConsumerWidget {
  /// Empty opens the overview; an estimate id opens that decision.
  final String estimateId;

  const CustomerApprovalsPage({super.key, this.estimateId = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final id = estimateId.trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: id.isEmpty ? 'Approvals & billing' : 'Estimate',
              onBack: () => _back(context),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: id.isEmpty
                  ? const _ApprovalsOverview()
                  : CustomerApprovalDetailView(estimateId: id),
            ),
          ],
        ),
      ),
    );
  }

  /// Deep links can open this page with nothing beneath it, so back falls back
  /// to the workspace instead of leaving the customer stuck.
  void _back(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.customerDashboard);
  }
}

/// What needs a decision right now, plus the settled invoices.
class _ApprovalsOverview extends ConsumerWidget {
  const _ApprovalsOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dash = ref.watch(customerDashboardProvider);
    final approvalsAsync = ref.watch(customerApprovalsProvider);
    final approvals =
        approvalsAsync.valueOrNull ?? const <CustomerApprovalSummaryResponse>[];
    final invoices =
        ref.watch(customerInvoicesProvider).valueOrNull ??
        const <InvoiceResponse>[];

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(customerApprovalsRefreshProvider.notifier).state++;
        ref.invalidate(customerInvoicesProvider);
      },
      color: colors.primary,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NeedsDecision(
              approvals: approvals,
              loading: approvalsAsync.isLoading && approvals.isEmpty,
              failed: approvalsAsync.hasError && approvals.isEmpty,
              formatAmount: dash.formatAmount,
              onReview: (estimateId) => context.push(
                AppRoutes.approvalsLocation(estimateId: estimateId),
              ),
            ),
            const SizedBox(height: AppDimensions.s28),
            _SettledInvoices(
              invoices: invoices,
              formatAmount: dash.formatAmount,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pending estimate decisions — the reason this page exists.
class _NeedsDecision extends StatelessWidget {
  final List<CustomerApprovalSummaryResponse> approvals;
  final bool loading;
  final bool failed;
  final String Function(double amount) formatAmount;
  final ValueChanged<String> onReview;

  const _NeedsDecision({
    required this.approvals,
    required this.loading,
    required this.failed,
    required this.formatAmount,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (loading) {
      return CustomerSkeleton(
        builder: (context, block) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerSkeletonBox(
                height: 96,
                color: block,
                radius: AppDimensions.radiusCard,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Needs your decision',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (approvals.isNotEmpty) _CountChip(count: approvals.length),
          ],
        ),
        const SizedBox(height: AppDimensions.s10),
        if (failed)
          CustomerSurfacePanel(
            accent: colors.onSurfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "We couldn't load your estimates",
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  'Pull down to try again.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else if (approvals.isEmpty)
          CustomerSurfacePanel(
            accent: colors.onSurfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nothing waiting',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  'When the workshop sends an estimate for your approval, it '
                  'appears here and on your booking.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                for (var index = 0; index < approvals.length; index++) ...[
                  _PendingApprovalRow(
                    approval: approvals[index],
                    formatAmount: formatAmount,
                    onReview: () => onReview(approvals[index].estimateId),
                  ),
                  if (index < approvals.length - 1)
                    Divider(height: 1, color: colors.outlineVariant),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// The list only identifies *which* estimate needs a decision; the breakdown and
/// the decision itself live in the detail.
class _PendingApprovalRow extends StatelessWidget {
  final CustomerApprovalSummaryResponse approval;
  final String Function(double amount) formatAmount;
  final VoidCallback onReview;

  const _PendingApprovalRow({
    required this.approval,
    required this.formatAmount,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = CustomerApprovalPresentation.statusTone(
      colors,
      approval.status,
    );
    // The list shows the day the workshop sent the estimate; the full
    // timestamp belongs in the detail.
    final requested = CustomerBookingsPresentation.compactDateLabel(
      approval.createdAt,
    );

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: [
        'Action required',
        if (approval.amount > 0) formatAmount(approval.amount),
        if (approval.estimateId.isNotEmpty) 'Estimate ${approval.estimateId}',
        if (requested.isNotEmpty) 'Sent $requested',
      ].join(', '),
      child: InkWell(
        onTap: onReview,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(Icons.fact_check_outlined, size: 20, color: tone),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTION REQUIRED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tone,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    if (approval.amount > 0)
                      Text(
                        formatAmount(approval.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (approval.estimateId.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        approval.estimateId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontFamily: AppFontFamilies.mono,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (requested.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        'Sent $requested',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              SizedBox(
                height: AppDimensions.touchTarget,
                child: TextButton(
                  onPressed: onReview,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Review estimate'),
                      SizedBox(width: AppDimensions.s4),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settled invoices keep their existing home here: this page is their only
/// entry point, so removing the old Approvals tab must not lose them.
class _SettledInvoices extends StatelessWidget {
  final List<InvoiceResponse> invoices;
  final String Function(double amount) formatAmount;

  const _SettledInvoices({required this.invoices, required this.formatAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Settled invoices',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (invoices.isNotEmpty) _CountChip(count: invoices.length),
          ],
        ),
        const SizedBox(height: AppDimensions.s10),
        if (invoices.isEmpty)
          CustomerSurfacePanel(
            accent: colors.onSurfaceVariant,
            child: Text(
              'Invoices appear here once your work has been billed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                for (var index = 0; index < invoices.length; index++) ...[
                  _InvoiceRow(
                    invoice: invoices[index],
                    formatAmount: formatAmount,
                    onOpen: () => context.push(
                      AppRoutes.customerInvoiceDetail,
                      extra: invoices[index],
                    ),
                  ),
                  if (index < invoices.length - 1)
                    Divider(height: 1, color: colors.outlineVariant),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final InvoiceResponse invoice;
  final String Function(double amount) formatAmount;
  final VoidCallback onOpen;

  const _InvoiceRow({
    required this.invoice,
    required this.formatAmount,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final paid = invoice.status.toLowerCase() == 'paid';
    final tone = paid ? colors.tertiary : colors.error;

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurface,
                      fontFamily: AppFontFamilies.mono,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (invoice.date.trim().isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      invoice.date.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Text(
              formatAmount(invoice.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
            StatusPill(
              label: AppStatusLabels.invoice(invoice.status).toUpperCase(),
              bg: tone.withValues(alpha: 0.12),
              fg: tone,
            ),
            const SizedBox(width: AppDimensions.s4),
            Icon(
              Icons.chevron_right_rounded,
              size: AppDimensions.iconMd,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;

  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s8,
        vertical: AppDimensions.r2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
