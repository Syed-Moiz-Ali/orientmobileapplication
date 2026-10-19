import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_approval_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

/// One estimate decision in full.
///
/// This is the screen that has to answer "what exactly am I being asked to
/// approve?": the real line items for services and parts, the real services /
/// parts / grand totals, the vehicle it is for, and — while the decision is
/// still open — the approve and reject actions. Everything shown comes from the
/// approval detail endpoint; nothing is calculated that the API does not send.
/// The decision is whole-estimate because that is the only endpoint the
/// backend exposes — per-line approve buttons would be fake, so line rows
/// stay read-only with a note saying so nowhere needed: they simply have no
/// actions. Safety flags do not exist on the record, so none are shown.
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
      loading: () => const AppResponsivePage(
        maxContentWidth: 1040,
        // Phase 07.1: bespoke _DetailSkeleton migrated to AppSkeleton.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSkeleton.card(height: 148),
            SizedBox(height: AppDimensions.s16),
            AppSkeleton.card(height: 200),
          ],
        ),
      ),
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
    final t = context.cx;
    final pending = CustomerApprovalPresentation.isPending(detail.status);
    final isEstimate = detail.approvalType == 'estimate';
    final subject = _subject(t, detail.approvalType);

    return Column(
      children: [
        Expanded(
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            maxContentWidth: 1040,
            child: Column(
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
                if (isEstimate) ...[
                  const SizedBox(height: AppDimensions.s16),
                  _FinancialSummary(
                    detail: detail,
                    formatAmount: formatAmount,
                    // While the decision is open the sticky dock owns the
                    // authorized total; the summary keeps services/parts so
                    // no amount renders twice.
                    showTotal: !pending,
                  ),
                ],
                if (!pending) ...[
                  const SizedBox(height: AppDimensions.s16),
                  _DecidedNote(
                    status: detail.status,
                    approvalType: detail.approvalType,
                  ),
                ],
                // Room for the quiet reject action under the dock.
                if (pending) const SizedBox(height: AppDimensions.s16),
              ],
            ),
          ),
        ),
        if (pending) ...[
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: _deciding
                  ? null
                  : () => _confirm(
                      detail: detail,
                      action: 'reject',
                      formatAmount: formatAmount,
                    ),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(t.apRejectSubject(subject)),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                disabledForegroundColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (_deciding)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.s4),
              child: Text(
                t.apSendingNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          // The dock carries the authorized total and the decision; the
          // itemized services/parts live once in the summary above, so the
          // dock stays total-only instead of repeating them.
          PriceBreakdownDock(
            totalLabel: t.apTotal,
            totalAmount: formatAmount(detail.grandTotal),
            ctaLabel: t.apApproveSubject(subject),
            busyLabel: t.apSending,
            busy: _deciding,
            ctaEnabled: true,
            onCta: () => _confirm(
              detail: detail,
              action: 'approve',
              formatAmount: formatAmount,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirm({
    required CustomerApprovalDetailResponse detail,
    required String action,
    required String Function(double amount) formatAmount,
  }) async {
    if (_deciding) return;
    final t = context.cx;
    final approving = action == 'approve';
    final amount = detail.grandTotal;
    final subject = _subject(t, detail.approvalType);
    final isEstimate = detail.approvalType == 'estimate';
    final vehicle = detail.vehicleInfo.trim();

    final confirmed = await showAppConfirmationDialog(
      context,
      title: approving
          ? t.apConfirmApproveTitle(subject)
          : t.apConfirmRejectTitle(subject),
      message: approving
          ? isEstimate
                ? vehicle.isEmpty
                      ? t.apConfirmApproveEst(formatAmount(amount))
                      : t.apConfirmApproveEstVehicle(
                          formatAmount(amount),
                          vehicle,
                        )
                : vehicle.isEmpty
                ? t.apConfirmApproveSubject(subject)
                : t.apConfirmApproveSubjectVehicle(subject, vehicle)
          : isEstimate
          ? t.apConfirmRejectEst
          : t.apConfirmRejectSubject(subject),
      confirmLabel: approving ? t.apConfirm : t.apConfirmReject(subject),
      cancelLabel: approving ? t.apNotNow : t.apKeepReviewing,
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

    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? approving
                    ? t.apApprovedToast(_toastLabel(detail.approvalType))
                    : t.apRejectedToast(_toastLabel(detail.approvalType))
              : t.apDecisionFail,
        ),
        action: ok
            ? null
            : SnackBarAction(
                label: t.apRetry,
                onPressed: () => _confirm(
                  detail: detail,
                  action: action,
                  formatAmount: formatAmount,
                ),
              ),
      ),
    );
  }

  String _subject(CustomerLocalizations t, String type) => switch (type) {
    'job_card' => t.apSubjectJobCard,
    'inspection' => t.apSubjectInspection,
    _ => t.apSubjectEstimate,
  };

  String _toastLabel(String type) {
    final t = context.cx;
    return switch (type) {
      'job_card' => t.apLabelJobCard,
      'inspection' => t.apLabelInspection,
      _ => t.apLabelEstimate,
    };
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
    final t = context.cx;
    final tone = CustomerApprovalPresentation.statusTone(colors, detail.status);
    final pending = CustomerApprovalPresentation.isPending(detail.status);
    final vehicle = detail.vehicleInfo.trim();
    final requested = detail.createdAt.trim();
    final isEstimate = detail.approvalType == 'estimate';
    final recordLabel = switch (detail.approvalType) {
      'job_card' => t.apRecordJobCard,
      'inspection' => t.apRecordInspection,
      _ => t.apRecordEstimate,
    };

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
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    detail.estimateId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontFamily: AppFontFamilies.mono,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            recordLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          if (isEstimate)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                formatAmount(detail.grandTotal),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            )
          else if (detail.description.trim().isNotEmpty)
            AppMarkdownText(
              detail.description.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                height: 1.45,
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
                text: t.apSentAt(requested),
                colour: colors.onSurfaceVariant,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Real line items, grouped into services and parts. Rows are read-only: the
/// only decision endpoint is whole-estimate, so per-line buttons would lie.
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
    final t = context.cx;

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
              t.apCovers,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          if (services.isNotEmpty) ...[
            _LineItemGroup(
              title: t.apServices,
              items: services,
              formatAmount: formatAmount,
            ),
          ],
          if (services.isNotEmpty && parts.isNotEmpty)
            Divider(height: 1, color: colors.outlineVariant),
          if (parts.isNotEmpty)
            _LineItemGroup(
              title: t.apParts,
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
    final t = context.cx;

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
                        item.name.trim().isEmpty
                            ? t.apItemFallback
                            : item.name.trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.r2),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _metaFor(t, item),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
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
                      fontFamily: AppFontFamilies.mono,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _metaFor(CustomerLocalizations t, ApprovalLineItem item) {
    final quantity = item.qty <= 0 ? 1 : item.qty;
    final parts = <String>[
      t.apQtyRate(quantity, formatAmount(item.rate)),
      if (item.discountPercent > 0)
        t.apDiscount(item.discountPercent.toStringAsFixed(0)),
    ];
    return parts.join(' \u00b7 ');
  }
}

/// Services, parts and the grand total — using the amounts the API sends.
class _FinancialSummary extends StatelessWidget {
  final CustomerApprovalDetailResponse detail;
  final String Function(double amount) formatAmount;

  /// False while the decision is open: the sticky dock owns the total then.
  final bool showTotal;

  const _FinancialSummary({
    required this.detail,
    required this.formatAmount,
    this.showTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;

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
              t.apSummary,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            if (detail.servicesTotal > 0)
              _SummaryRow(
                label: t.apServices,
                value: formatAmount(detail.servicesTotal),
              ),
            if (detail.partsTotal > 0) ...[
              if (detail.servicesTotal > 0)
                const SizedBox(height: AppDimensions.s8),
              _SummaryRow(
                label: t.apParts,
                value: formatAmount(detail.partsTotal),
              ),
            ],
            const SizedBox(height: AppDimensions.s12),
            Divider(height: 1, color: colors.outlineVariant),
            if (showTotal) ...[
              const SizedBox(height: AppDimensions.s12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.apTotal,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      formatAmount(detail.grandTotal),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        fontFamily: AppFontFamilies.mono,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontFamily: AppFontFamilies.mono,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Read-only state for an estimate the customer already decided.
class _DecidedNote extends StatelessWidget {
  final String status;
  final String approvalType;

  const _DecidedNote({required this.status, required this.approvalType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final tone = CustomerApprovalPresentation.statusTone(colors, status);
    final approved =
        CustomerApprovalPresentation.normalize(status) ==
        CustomerApprovalPresentation.approved;
    final subject = switch (approvalType) {
      'job_card' => t.apSubjectJobCard,
      'inspection' => t.apSubjectInspection,
      _ => t.apSubjectEstimate,
    };
    final message = approvalType == 'estimate'
        ? (approved ? t.apDecidedApprovedEst : t.apDecidedRejectedEst)
        : (approved
              ? t.apDecidedApprovedSubject(subject)
              : t.apDecidedRejectedSubject(subject));

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
              message,
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

/// A stale, missing or unreadable estimate must never dead-end the customer.
class _DetailError extends StatelessWidget {
  final String estimateId;
  final VoidCallback onRetry;

  const _DetailError({required this.estimateId, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;

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
                  t.apDetailLoadFail,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  t.apDetailReplaced,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimensions.s16),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(t.apTryAgain),
                ),
                const SizedBox(height: AppDimensions.s8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.approvalsLocation()),
                  child: Text(t.apViewAll),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
