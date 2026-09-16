import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_approval_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// One estimate decision in full.
///
/// This is the screen that has to answer "what exactly am I being asked to
/// approve?": the real line items for services and parts, the real services /
/// parts / grand totals, the vehicle it is for, and — while the decision is
/// still open — the approve and reject actions. Everything shown comes from the
/// approval detail endpoint; nothing is calculated that the API does not send.
class CustomerApprovalDetailView extends ConsumerStatefulWidget {
  final String estimateId;

  const CustomerApprovalDetailView({super.key, required this.estimateId});

  @override
  ConsumerState<CustomerApprovalDetailView> createState() =>
      _CustomerApprovalDetailViewState();
}

class _CustomerApprovalDetailViewState
    extends ConsumerState<CustomerApprovalDetailView> {
  bool _deciding = false;

  @override
  Widget build(BuildContext context) {
    final dash = ref.watch(customerDashboardProvider);
    final detailAsync = ref.watch(
      customerApprovalDetailProvider(widget.estimateId),
    );

    return detailAsync.when(
      loading: () => const _DetailSkeleton(),
      error: (error, _) => _DetailError(
        estimateId: widget.estimateId,
        onRetry: () =>
            ref.invalidate(customerApprovalDetailProvider(widget.estimateId)),
      ),
      data: (detail) => _content(context, detail, dash.formatAmount),
    );
  }

  Widget _content(
    BuildContext context,
    CustomerApprovalDetailResponse detail,
    String Function(double amount) formatAmount,
  ) {
    final pending = CustomerApprovalPresentation.isPending(detail.status);

    return Column(
      children: [
        Expanded(
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            maxContentWidth: 1040,
            child: AppSplitView(
              primaryFlex: 3,
              secondaryFlex: 2,
              spacing: AppDimensions.s20,
              primary: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EstimateRecord(detail: detail, formatAmount: formatAmount),
                  if (detail.services.isNotEmpty ||
                      detail.parts.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s16),
                    _WorkBreakdown(
                      services: detail.services,
                      parts: detail.parts,
                      formatAmount: formatAmount,
                    ),
                  ],
                ],
              ),
              secondary: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FinancialSummary(detail: detail, formatAmount: formatAmount),
                  if (!pending) ...[
                    const SizedBox(height: AppDimensions.s16),
                    _DecidedNote(status: detail.status),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (pending)
          _DecisionBar(
            deciding: _deciding,
            onApprove: () => _confirm(
              detail: detail,
              action: 'approve',
              formatAmount: formatAmount,
            ),
            onReject: () => _confirm(
              detail: detail,
              action: 'reject',
              formatAmount: formatAmount,
            ),
          ),
      ],
    );
  }

  Future<void> _confirm({
    required CustomerApprovalDetailResponse detail,
    required String action,
    required String Function(double amount) formatAmount,
  }) async {
    if (_deciding) return;
    final approving = action == 'approve';
    final amount = detail.grandTotal;

    final confirmed = await showAppConfirmationDialog(
      context,
      title: approving ? 'Approve estimate?' : 'Reject estimate?',
      message: approving
          ? 'You are approving work totaling ${formatAmount(amount)}'
                '${detail.vehicleInfo.trim().isEmpty ? '' : ' for ${detail.vehicleInfo.trim()}'}.'
          : 'The workshop will be told you do not accept this estimate. '
                'You can ask them for a revised one.',
      confirmLabel: approving ? 'Approve' : 'Reject estimate',
      cancelLabel: approving ? 'Not now' : 'Keep reviewing',
      icon: approving ? Icons.verified_outlined : Icons.cancel_outlined,
      destructive: !approving,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deciding = true);
    var ok = false;
    try {
      ok = await customerProcessApproval(ref, detail.estimateId, action);
    } catch (_) {
      // Never leave the customer stuck in an in-flight state.
      ok = false;
    }
    if (!mounted) return;
    setState(() => _deciding = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? approving
                    ? 'Estimate approved — the workshop has been told.'
                    : 'Estimate rejected — the workshop has been told.'
              : "We couldn't send your decision. Please try again.",
        ),
        action: ok
            ? null
            : SnackBarAction(
                label: 'Retry',
                onPressed: () => _confirm(
                  detail: detail,
                  action: action,
                  formatAmount: formatAmount,
                ),
              ),
      ),
    );
  }
}

/// The estimate itself: decision state, amount, vehicle, reference and when the
/// workshop sent it.
class _EstimateRecord extends StatelessWidget {
  final CustomerApprovalDetailResponse detail;
  final String Function(double amount) formatAmount;

  const _EstimateRecord({required this.detail, required this.formatAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = CustomerApprovalPresentation.statusTone(colors, detail.status);
    final pending = CustomerApprovalPresentation.isPending(detail.status);
    final vehicle = detail.vehicleInfo.trim();
    final requested = detail.createdAt.trim();

    return CustomerSurfacePanel(
      accent: tone,
      emphasised: pending,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The status and the reference share a line while they fit; a long
          // status or reference wraps instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                label: CustomerApprovalPresentation.statusLabel(
                  detail.status,
                ).toUpperCase(),
                showDot: true,
                bg: tone.withValues(alpha: 0.12),
                fg: tone,
              ),
              if (detail.estimateId.isNotEmpty)
                Text(
                  detail.estimateId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontFamily: AppFontFamilies.mono,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            'Estimated total',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            formatAmount(detail.grandTotal),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          if (vehicle.isNotEmpty || requested.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s14),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppDimensions.s12),
            if (vehicle.isNotEmpty)
              _IconLine(
                icon: Icons.directions_car_rounded,
                text: vehicle,
                colour: colors.onSurface,
              ),
            if (requested.isNotEmpty) ...[
              if (vehicle.isNotEmpty) const SizedBox(height: AppDimensions.s6),
              _IconLine(
                icon: Icons.schedule_rounded,
                text: 'Sent $requested',
                colour: colors.onSurfaceVariant,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Real line items, grouped into services and parts.
class _WorkBreakdown extends StatelessWidget {
  final List<ApprovalLineItem> services;
  final List<ApprovalLineItem> parts;
  final String Function(double amount) formatAmount;

  const _WorkBreakdown({
    required this.services,
    required this.parts,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s14,
              AppDimensions.s14,
              AppDimensions.s14,
              AppDimensions.s10,
            ),
            child: Text(
              'What this estimate covers',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          if (services.isNotEmpty) ...[
            _LineItemGroup(
              title: 'Services',
              items: services,
              formatAmount: formatAmount,
            ),
          ],
          if (services.isNotEmpty && parts.isNotEmpty)
            Divider(height: 1, color: colors.outlineVariant),
          if (parts.isNotEmpty)
            _LineItemGroup(
              title: 'Parts',
              items: parts,
              formatAmount: formatAmount,
            ),
        ],
      ),
    );
  }
}

class _LineItemGroup extends StatelessWidget {
  final String title;
  final List<ApprovalLineItem> items;
  final String Function(double amount) formatAmount;

  const _LineItemGroup({
    required this.title,
    required this.items,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s14,
            AppDimensions.s12,
            AppDimensions.s14,
            AppDimensions.s4,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s14,
              AppDimensions.s8,
              AppDimensions.s14,
              AppDimensions.s8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.trim().isEmpty ? 'Item' : item.name.trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.r2),
                      Text(
                        _metaFor(item),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Text(
                  formatAmount(
                    CustomerApprovalPresentation.lineAmount(
                          item.rate,
                          item.qty,
                          item.discountAmount,
                        ) ??
                        0,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _metaFor(ApprovalLineItem item) {
    final quantity = item.qty <= 0 ? 1 : item.qty;
    final parts = <String>[
      'Qty $quantity \u00d7 ${formatAmount(item.rate)}',
      if (item.discountPercent > 0)
        '\u2212${item.discountPercent.toStringAsFixed(0)}%',
    ];
    return parts.join(' \u00b7 ');
  }
}

/// Services, parts and the grand total — using the amounts the API sends.
class _FinancialSummary extends StatelessWidget {
  final CustomerApprovalDetailResponse detail;
  final String Function(double amount) formatAmount;

  const _FinancialSummary({required this.detail, required this.formatAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            if (detail.servicesTotal > 0)
              _SummaryRow(
                label: 'Services',
                value: formatAmount(detail.servicesTotal),
              ),
            if (detail.partsTotal > 0) ...[
              if (detail.servicesTotal > 0)
                const SizedBox(height: AppDimensions.s8),
              _SummaryRow(
                label: 'Parts',
                value: formatAmount(detail.partsTotal),
              ),
            ],
            const SizedBox(height: AppDimensions.s12),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppDimensions.s12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  formatAmount(detail.grandTotal),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

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
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Read-only state for an estimate the customer already decided.
class _DecidedNote extends StatelessWidget {
  final String status;

  const _DecidedNote({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = CustomerApprovalPresentation.statusTone(colors, status);
    final approved =
        CustomerApprovalPresentation.normalize(status) ==
        CustomerApprovalPresentation.approved;

    return CustomerSurfacePanel(
      accent: tone,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            approved ? Icons.verified_outlined : Icons.info_outline_rounded,
            size: AppDimensions.iconMd,
            color: tone,
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              approved
                  ? 'You approved this estimate. The workshop will carry out '
                        'the work listed above.'
                  : 'You rejected this estimate. The workshop has been told and '
                        'can send a revised one.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The decision itself: one clear primary action, one clearly available but
/// less prominent rejection.
class _DecisionBar extends StatelessWidget {
  final bool deciding;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DecisionBar({
    required this.deciding,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: deciding ? null : onApprove,
                icon: deciding
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.verified_outlined, size: 18),
                label: Text(deciding ? 'Sending\u2026' : 'Approve estimate'),
              ),
              const SizedBox(height: AppDimensions.s8),
              TextButton.icon(
                onPressed: deciding ? null : onReject,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Reject estimate'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.error,
                  disabledForegroundColor: colors.onSurfaceVariant,
                ),
              ),
              if (deciding)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.s4),
                  child: Text(
                    'Sending your decision to the workshop\u2026',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
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

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color colour;

  const _IconLine({
    required this.icon,
    required this.text,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: colour),
        const SizedBox(width: AppDimensions.s6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colour,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) => AppResponsivePage(
        maxContentWidth: 1040,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerSkeletonBox(
              height: 148,
              color: block,
              radius: AppDimensions.radiusCard,
            ),
            const SizedBox(height: AppDimensions.s16),
            CustomerSkeletonBox(
              height: 200,
              color: block,
              radius: AppDimensions.radiusCard,
            ),
          ],
        ),
      ),
    );
  }
}

/// A stale, missing or unreadable estimate must never dead-end the customer.
class _DetailError extends StatelessWidget {
  final String estimateId;
  final VoidCallback onRetry;

  const _DetailError({required this.estimateId, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppResponsivePage(
      maxContentWidth: 640,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.s32),
          CustomerSurfacePanel(
            accent: colors.onSurfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "We couldn't load this estimate",
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  'The workshop may have replaced it. You can try again or '
                  'review your other estimates.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimensions.s16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                const SizedBox(height: AppDimensions.s8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.approvalsLocation()),
                  child: const Text('View all approvals'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
