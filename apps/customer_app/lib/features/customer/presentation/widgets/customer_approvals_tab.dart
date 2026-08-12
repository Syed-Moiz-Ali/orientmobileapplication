import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_empty_fallbacks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerApprovalsTab extends ConsumerWidget {
  const CustomerApprovalsTab({super.key});

  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    String estimateId,
  ) async {
    final detail = await ref
        .read(customerRemoteDataSourceProvider)
        .getApprovalDetail(estimateId);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ApprovalDetailSheet(
        detail: detail,
        onAction: (action) async {
          final ok = await customerProcessApproval(ref, estimateId, action);
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? action == 'approve'
                          ? 'Estimate approved - work will start shortly'
                          : 'Estimate rejected'
                    : 'Could not submit. Try again.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final approvalsAsync = ref.watch(customerApprovalsProvider);
    final invoicesAsync = ref.watch(customerInvoicesProvider);
    final approvals =
        approvalsAsync.value ?? const <CustomerApprovalSummaryResponse>[];
    final invoices = invoicesAsync.value ?? const <InvoiceResponse>[];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(customerApprovalsRefreshProvider.notifier).state++;
        },
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Approvals',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s6),
                            Text(
                              '${approvals.length} ${approvals.length == 1 ? "estimate waiting" : "estimates waiting"}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.text3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(customerApprovalsRefreshProvider.notifier)
                          .state++;
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Refresh estimates',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s20),
              if (approvals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.s24),
                  child: EmptyState(
                    icon: Icons.fact_check_outlined,
                    message: 'No estimates waiting for approval',
                  ),
                )
              else
                AppAdaptiveGrid(
                  minChildWidth: 360,
                  childAspectRatio: 2.75,
                  children: [
                    for (final approval in approvals)
                      _ApprovalCard(
                        approval: approval,
                        onReview: () =>
                            _openDetail(context, ref, approval.estimateId),
                      ),
                  ],
                ),
              const SizedBox(height: AppDimensions.s32),
              const _SectionHeading(
                title: 'Invoices',
                subtitle: 'Your invoices from completed jobs.',
                accent: Color(0xFF238636),
              ),
              const SizedBox(height: AppDimensions.s16),
              if (invoices.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.s12),
                  child: EmptyInvoicesCard(),
                )
              else
                AppAdaptiveGrid(
                  minChildWidth: 360,
                  childAspectRatio: 3.2,
                  children: [
                    for (final invoice in invoices)
                      _InvoiceCard(
                        invoice: invoice,
                        onTap: () => context.push(
                          AppRoutes.customerInvoiceDetail,
                          extra: invoice,
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: AppDimensions.s24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.text3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final CustomerApprovalSummaryResponse approval;
  final VoidCallback onReview;

  const _ApprovalCard({required this.approval, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approval.estimateId,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  '${approval.customerName} - ${approval.createdAt}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.text3),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  '\u00a3${approval.amount.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          FilledButton(onPressed: onReview, child: const Text('Review')),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceResponse invoice;
  final VoidCallback onTap;

  const _InvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paid = invoice.status == 'paid';

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Row(
          children: [
            const Icon(
              Icons.receipt_outlined,
              color: AppColors.text3,
              size: 22,
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.id,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    invoice.date,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\u00a3${invoice.amount.toStringAsFixed(2)}',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
            StatusPill(
              label: paid ? 'Paid' : 'Unpaid',
              bg: paid ? AppColors.successBg : AppColors.warningBg,
              fg: paid ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalDetailSheet extends StatelessWidget {
  final CustomerApprovalDetailResponse detail;
  final void Function(String action) onAction;

  const _ApprovalDetailSheet({required this.detail, required this.onAction});

  Widget _lineItems(
    BuildContext context,
    String title,
    List<ApprovalLineItem> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.s16),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.name} x ${item.qty}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '\u00a3${(item.qty * item.rate).toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.text2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r28),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppDimensions.r2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      detail.estimateId,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: 'Pending approval',
                    bg: AppColors.warningBg,
                    fg: AppColors.warning,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  if (detail.vehicleInfo.isNotEmpty)
                    Text(
                      detail.vehicleInfo,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  _lineItems(context, 'Services', detail.services),
                  _lineItems(context, 'Parts', detail.parts),
                  const SizedBox(height: AppDimensions.s16),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.s14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\u00a3${detail.grandTotal.toStringAsFixed(2)}',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                          ),
                        ),
                        onPressed: () => onAction('reject'),
                        child: Text(
                          'Reject',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                          ),
                        ),
                        onPressed: () => onAction('approve'),
                        child: Text(
                          'Approve',
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
