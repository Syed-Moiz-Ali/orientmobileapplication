import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

class CustomerApprovalsTab extends ConsumerWidget {
  const CustomerApprovalsTab({super.key});

  Future<void> _openDetail(BuildContext context, WidgetRef ref, String estimateId) async {
    final detail = await ref.read(customerRemoteDataSourceProvider).getApprovalDetail(estimateId);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ApprovalDetailSheet(
        detail: detail,
        onAction: (action) async {
          final ok = await customerProcessApproval(ref, estimateId, action);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? action == 'approve'
                          ? 'Estimate approved — work will start shortly'
                          : 'Estimate rejected'
                      : 'Could not submit. Try again.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(customerApprovalsProvider);
    final invoicesAsync = ref.watch(customerInvoicesProvider);
    final approvals = approvalsAsync.value ?? const <CustomerApprovalSummaryResponse>[];
    final invoices = invoicesAsync.value ?? const <InvoiceResponse>[];

    return RefreshIndicator(
      onRefresh: () async => ref.read(customerApprovalsRefreshProvider.notifier).state++,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.s16),
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Estimates',
                style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref.read(customerApprovalsRefreshProvider.notifier).state++,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.text3, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Approve the workshop estimate to start the work',
            style: TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: 12),
          if (approvals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.fact_check_outlined,
                message: 'No estimates waiting for approval',
              ),
            )
          else
            ...approvals.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.estimateId,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${a.customerName} · ${a.createdAt}',
                              style: const TextStyle(color: AppColors.text3, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\u00a3${a.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.r10),
                          ),
                        ),
                        onPressed: () => _openDetail(context, ref, a.estimateId),
                        child: const Text(
                          'Review',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF238636),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Invoices',
                style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your invoices from completed jobs',
            style: TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: 12),
          if (invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(icon: Icons.receipt_outlined, message: 'No invoices yet'),
            )
          else
            ...invoices.map(
              (inv) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(AppDimensions.s14),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_outlined, color: AppColors.text3, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.id,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              inv.date,
                              style: const TextStyle(color: AppColors.text3, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\u00a3${inv.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusPill(
                        label: inv.status == 'paid' ? 'Paid' : 'Unpaid',
                        bg: inv.status == 'paid' ? AppColors.successBg : AppColors.warningBg,
                        fg: inv.status == 'paid' ? AppColors.success : AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ApprovalDetailSheet extends StatelessWidget {
  final CustomerApprovalDetailResponse detail;
  final void Function(String action) onAction;

  const _ApprovalDetailSheet({required this.detail, required this.onAction});

  Widget _lineItems(String title, List<ApprovalLineItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.name} × ${item.qty}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Text(
                  '\u00a3${(item.qty * item.rate).toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.text2, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r28)),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    detail.estimateId,
                    style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  StatusPill(label: 'Pending approval', bg: AppColors.warningBg, fg: AppColors.warning),
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
                      style: const TextStyle(color: AppColors.text3, fontSize: 13),
                    ),
                  _lineItems('Services', detail.services),
                  _lineItems('Parts', detail.parts),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\u00a3${detail.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
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
                            borderRadius: BorderRadius.circular(AppDimensions.r12),
                          ),
                        ),
                        onPressed: () => onAction('reject'),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.r12),
                          ),
                        ),
                        onPressed: () => onAction('approve'),
                        child: const Text(
                          'Approve',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
