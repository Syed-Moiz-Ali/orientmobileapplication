import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';

/// The single most important thing on Customer Home, as ONE [AppMediaCard]
/// plus ONE explicit verb-first CTA button — or, when nothing is due, as a
/// compact calm status row with no button at all (U6).
///
/// Hero priority is read from the existing presentation rules, in order:
/// 1. an approval waiting for a decision ([CustomerAttentionPanel] lists
///    approvals before invoices),
/// 2. a genuinely unpaid invoice (same panel, second row),
/// 3. a live workshop job (the previous summary led with it),
/// 4. the next upcoming booking (previous summary, second branch),
/// 5. idle — nothing active (calm status row, same as the advisor rebuild:
///    the quick-action tiles keep the one booking path, so the hero carries
///    no duplicate CTA per U7).
///
/// The card carries dot + label + one sentence; the CTA button below it is
/// the tappable target (the card stays tappable too). When more than one
/// attention item exists, a "+N more" row under the card opens the
/// approvals screen, where the full adjudication lives — Home never
/// reorders or hides that logic.
class CustomerHomeHero extends StatelessWidget {
  final List<CustomerApprovalSummaryResponse> approvals;
  final int unpaidInvoices;
  final String Function(double amount) formatAmount;
  final CustomerServiceEntity? activeService;
  final CustomerBookingEntity? activeBooking;
  final int vehicleCount;
  final void Function(String estimateId) onReviewEstimate;
  final VoidCallback onViewInvoices;
  final VoidCallback onViewAllAttention;
  final VoidCallback onTrackService;
  final VoidCallback onViewBooking;

  const CustomerHomeHero({
    super.key,
    required this.approvals,
    required this.unpaidInvoices,
    required this.formatAmount,
    required this.activeService,
    required this.activeBooking,
    required this.vehicleCount,
    required this.onReviewEstimate,
    required this.onViewInvoices,
    required this.onViewAllAttention,
    required this.onTrackService,
    required this.onViewBooking,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;

    if (approvals.isNotEmpty) {
      final single = approvals.length == 1;
      final first = approvals.first;
      final title = single
          ? (first.amount > 0
                ? t.stAttentionEst(formatAmount(first.amount))
                : t.stAttentionGeneric)
          : t.stAttentionEstMany(approvals.length);
      return _HeroWithMore(
        attentionCount: approvals.length + (unpaidInvoices > 0 ? 1 : 0),
        onViewAllAttention: onViewAllAttention,
        child: _HeroCardWithCta(
          card: AppMediaCard(
            icon: Icons.fact_check_rounded,
            title: title,
            meta: t.bkApprovalMsg,
            status: AppStatusChip(
              label: t.stAttentionTitle,
              kind: AppStatusKind.error,
            ),
            onTap: () => onReviewEstimate(first.estimateId),
            semanticLabel: '$title. ${t.bkdReviewEstimate}',
          ),
          ctaLabel: t.bkdReviewEstimate,
          onCta: () => onReviewEstimate(first.estimateId),
        ),
      );
    }

    if (unpaidInvoices > 0) {
      final due = unpaidInvoices == 1
          ? t.stUnpaidOne
          : t.stUnpaidMany(unpaidInvoices);
      return _HeroWithMore(
        attentionCount: 1,
        onViewAllAttention: onViewAllAttention,
        child: _HeroCardWithCta(
          card: AppMediaCard(
            icon: Icons.receipt_long_rounded,
            title: due,
            meta: t.garUnpaidBody,
            // C16: no numbers duplicated in label and badge — the chip says
            // "Unpaid" while the title keeps the count.
            status: AppStatusChip(label: t.garUnpaidChip, kind: AppStatusKind.warning),
            onTap: onViewInvoices,
            semanticLabel: '$due. ${t.garUnpaidCta}',
          ),
          ctaLabel: t.garUnpaidCta,
          onCta: onViewInvoices,
        ),
      );
    }

    final service = activeService;
    if (CustomerServiceTracking.isLiveService(service)) {
      final svc = service!;
      final title = svc.service.trim().isEmpty
          ? t.jsInProgress
          : svc.service.trim();
      final stage = svc.currentStage.trim();
      final eta = svc.estCompletion.trim();
      final vehicleLine = CustomerServiceTracking.vehicleLine(
        svc.vehicleName,
        svc.plateNumber,
      );
      final meta = stage.isNotEmpty
          ? t.jsStage(stage)
          : (eta.isNotEmpty ? t.jsEta(eta) : vehicleLine);
      return _HeroCardWithCta(
        card: AppMediaCard(
          icon: Icons.build_circle_rounded,
          title: title,
          meta: meta.isEmpty ? null : meta,
          status: AppStatusChip(
            label: t.bkInService,
            kind: AppStatusKind.accent,
          ),
          onTap: onTrackService,
          semanticLabel: '$title. ${t.garJourneyTrack}',
        ),
        ctaLabel: t.garJourneyTrack,
        onCta: onTrackService,
      );
    }

    final booking = activeBooking;
    if (booking != null) {
      final title = booking.service.trim().isEmpty
          ? t.jsWorkshopBooking
          : booking.service.trim();
      final schedule = [
        if (booking.date.trim().isNotEmpty) booking.date.trim(),
        if (booking.time.trim().isNotEmpty) booking.time.trim(),
      ].join(' \u00b7 ');
      final meta = schedule.isEmpty
          ? t.stBookedNote
          : '$schedule. ${t.stBookedNote}';
      final statusLabel = AppStatusLabels.of(context).booking(booking.status.name);
      return _HeroCardWithCta(
        card: AppMediaCard(
          icon: Icons.event_rounded,
          title: title,
          meta: meta,
          status: AppStatusChip(
            label: statusLabel,
            kind: AppStatusKind.info,
          ),
          onTap: onViewBooking,
          semanticLabel: '$title. ${t.garJourneyView}',
        ),
        ctaLabel: t.garJourneyView,
        onCta: onViewBooking,
      );
    }

    // U6/U7: nothing is due, so the hero collapses to the same compact calm
    // status row the advisor rebuild uses — no full card, no button to
    // nothing. The Book-service tile below keeps the one booking path.
    return CustomerHomeStatusRow(
      message: vehicleCount == 1 ? t.jsIdleOne : t.jsIdleMany,
      icon: Icons.check_circle_rounded,
    );
  }
}

/// Compact calm status row for "nothing is due" (U6, advisor parity).
///
/// An [AppSurfaceCard] with a calm icon + one sentence — never a filled CTA
/// to nothing. The optional [actionLabel]/[onAction] is a quiet text action
/// (used once: the new-customer row keeps "Add your vehicle" one tap away
/// because booking requires a vehicle). The sentence reads as plain text
/// and the text action keeps its own button semantics.
class CustomerHomeStatusRow extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CustomerHomeStatusRow({
    super.key,
    required this.message,
    required this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final hasAction = actionLabel != null && onAction != null;
    return AppSurfaceCard(
      radius: AppRadius.xl,
      outlined: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: iconColor ?? semantic.success.base),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          if (hasAction) ...[
            const SizedBox(width: AppSpacing.sm),
            AppTextButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// One hero card with its explicit verb-first CTA button underneath.
///
/// The card stays tappable (same destination); the button makes the action
/// visible without opening the card first. Single primary CTA per C8.
class _HeroCardWithCta extends StatelessWidget {
  final Widget card;
  final String ctaLabel;
  final VoidCallback onCta;

  const _HeroCardWithCta({
    required this.card,
    required this.ctaLabel,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        const SizedBox(height: AppSpacing.sm),
        AppPillButton.secondary(label: ctaLabel, onPressed: onCta),
      ],
    );
  }
}

/// The "+N more" row under an attention hero. Rendered only when more than
/// one attention item exists; the hero shows the first and this row carries
/// the rest to the approvals screen.
class _HeroWithMore extends StatelessWidget {
  final int attentionCount;
  final VoidCallback onViewAllAttention;
  final Widget child;

  const _HeroWithMore({
    required this.attentionCount,
    required this.onViewAllAttention,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (attentionCount <= 1) return child;
    final t = context.cx;
    final remaining = attentionCount - 1;
    final label = remaining == 1
        ? t.garAttentionMoreOne
        : t.garAttentionMoreMany(remaining);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppTextButton(
            label: label,
            onPressed: onViewAllAttention,
          ),
        ),
      ],
    );
  }
}
