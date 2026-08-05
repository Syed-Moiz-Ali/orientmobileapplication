import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:owner_app/features/dashboard/presentation/providers/ar_providers.dart';

class AccountsReceivableView extends ConsumerStatefulWidget {
  const AccountsReceivableView({super.key});

  @override
  ConsumerState<AccountsReceivableView> createState() =>
      _AccountsReceivableViewState();
}

class _AccountsReceivableViewState
    extends ConsumerState<AccountsReceivableView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountsReceivableProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accounts Receivable',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Total Outstanding: AED ${_formatAmount(state.summary.totalOutstanding)}',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppDimensions.r8),
                    ),
                    child: TextField(
                      onChanged: (q) => ref
                          .read(accountsReceivableProvider.notifier)
                          .onSearch(q),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search by customer or AR ID...',
                        hintStyle: TextStyle(
                            color: AppColors.gray400, fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.gray400, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    children: [
                      _AgingCard(
                        label: '0-30 Days',
                        amount: state.summary.days0to30,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _AgingCard(
                        label: '31-60 Days',
                        amount: state.summary.days31to60,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _AgingCard(
                        label: '61-90 Days',
                        amount: state.summary.days61to90,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 8),
                      _AgingCard(
                        label: '90+ Days',
                        amount: state.summary.days90plus,
                        color: AppColors.gray700,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.gray50,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 360;
                      return Row(
                        children: [
                          const _TableHeader(text: 'AR ID', flex: 2),
                          const _TableHeader(text: 'Customer', flex: 3),
                          const _TableHeader(text: 'Inv. Date', flex: 2),
                          if (!narrow)
                            const _TableHeader(text: 'Due Date', flex: 2),
                          const _TableHeader(text: 'Aging', flex: 2),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.gray200),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.filteredRecords.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.gray200),
                    itemBuilder: (_, i) =>
                        _ARTableRow(record: state.filteredRecords[i]),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

class _AgingCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _AgingCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.r10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.gray500)),
            const SizedBox(height: 4),
            Text(
              'AED ${_fmt(amount)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v == 0
      ? '0'
      : v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeader({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500)),
    );
  }
}

class _ARTableRow extends StatelessWidget {
  final ARRecord record;
  const _ARTableRow({required this.record});

  @override
  Widget build(BuildContext context) {
    Color agingColor;
    String agingLabel;

    switch (record.aging) {
      case AgingBucket.days0to30:
        agingColor = AppColors.success;
        agingLabel = '0-30 days';
        break;
      case AgingBucket.days31to60:
        agingColor = AppColors.warning;
        agingLabel = '31-60 days';
        break;
      case AgingBucket.days61to90:
        agingColor = AppColors.danger;
        agingLabel = '61-90 days';
        break;
      case AgingBucket.days90plus:
        agingColor = AppColors.gray700;
        agingLabel = '90+ days';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On narrow screens (< 360dp) hide the aging badge to avoid
          // overflowing the row; text cells always truncate with ellipsis.
          final narrow = constraints.maxWidth < 360;
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(record.arId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gray900)),
              ),
              Expanded(
                flex: 3,
                child: Text(record.customer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gray900)),
              ),
              Expanded(
                flex: 2,
                child: Text(record.invoiceDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.gray500)),
              ),
              if (!narrow)
                Expanded(
                  flex: 2,
                  child: Text(record.dueDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.gray500)),
                ),
              Expanded(
                flex: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: agingColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.r4),
                  ),
                  child: Text(
                    agingLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: agingColor),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
