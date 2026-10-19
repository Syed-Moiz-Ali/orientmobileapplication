import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_approval_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_approval_detail_view.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

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
    final t = context.cx;
    final id = estimateId.trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar
      // (same title + deep-link-safe back behavior).
      appBar: WorkspaceAppBar(
        title: id.isEmpty ? t.apTitle : t.apDetailTitle,
        showBack: true,
        onBack: () => _back(context),
      ),
      body: id.isEmpty
          ? const _ApprovalsOverview()
          : CustomerApprovalDetailView(estimateId: id),
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
    final colors = Theme.of(context).colorScheme;
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

/// Pending estimate decisions — the reason this page exists — as one
/// resolution card per request: what it is, what it costs, when it arrived,
/// and the single way to review it.
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
    final t = context.cx;

    if (loading) {
      // Phase 07.1: bespoke CustomerSkeleton engine migrated to AppSkeleton.
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.s32),
        child: AppSkeleton.card(height: 96),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.apNeedsDecision,
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
                  t.apLoadFail,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  t.apPullRetry,
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
                  t.apEmptyTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  t.apEmptyBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
        else
          for (var index = 0; index < approvals.length; index++) ...[
            _PendingApprovalCard(
              approval: approvals[index],
              formatAmount: formatAmount,
              t: t,
              onReview: () => onReview(approvals[index].estimateId),
            ),
            if (index < approvals.length - 1)
              const SizedBox(height: AppDimensions.s12),
          ],
      ],
    );
  }
}

/// One card per pending request: the list only identifies *which* estimate
/// needs a decision; the breakdown and the decision itself live in the detail.
class _PendingApprovalCard extends StatelessWidget {
  final CustomerApprovalSummaryResponse approval;
  final String Function(double amount) formatAmount;
  final CustomerLocalizations t;
  final VoidCallback onReview;

  const _PendingApprovalCard({
    required this.approval,
    required this.formatAmount,
    required this.t,
    required this.onReview,
  });

  String _approvalLabel(String type) => switch (type) {
    'job_card' => t.apTypeJobCard,
    'inspection' => t.apTypeInspection,
    _ => t.apTypeEstimate,
  };

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
    final label = _approvalLabel(approval.approvalType);

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: [
        t.apActionRequired,
        if (approval.amount > 0) formatAmount(approval.amount),
        if (approval.estimateId.isNotEmpty)
          '$label ${approval.estimateId}',
        if (requested.isNotEmpty) t.apSentAt(requested),
      ].join(', '),
      child: InkWell(
        onTap: onReview,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: tone.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    child: Icon(
                      Icons.fact_check_outlined,
                      size: 20,
                      color: tone,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.apActionRequired,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tone,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s4),
                        Text(
                          label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (approval.amount > 0)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        formatAmount(approval.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              if (approval.estimateId.isNotEmpty ||
                  requested.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s8),
                Row(
                  children: [
                    if (approval.estimateId.isNotEmpty)
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            approval.estimateId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontFamily: AppFontFamilies.mono,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (requested.isNotEmpty)
                      Text(
                        t.apSentAt(requested),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimensions.s8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onReview,
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text('${t.apReviewPrefix} ${label.toLowerCase()}'),
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
    final t = context.cx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.apInvoices,
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
              t.apInvoicesEmpty,
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
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      invoice.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AppFontFamilies.mono,
                        fontWeight: FontWeight.w700,
                      ),
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
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                formatAmount(
                  invoice.grandTotal > 0 ? invoice.grandTotal : invoice.amount,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
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
