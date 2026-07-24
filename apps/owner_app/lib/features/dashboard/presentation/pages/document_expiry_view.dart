import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';

class DocumentExpiryView extends ConsumerStatefulWidget {
  const DocumentExpiryView({super.key});
  @override
  ConsumerState<DocumentExpiryView> createState() => _DocumentExpiryViewState();
}

class _DocumentExpiryViewState extends ConsumerState<DocumentExpiryView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentExpiryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Document Expiry',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.gray700,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '8',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
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
                      onChanged: (q) =>
                          ref.read(documentExpiryProvider.notifier).onSearch(q),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search employees...',
                        hintStyle: TextStyle(
                          color: AppColors.gray400,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.gray400,
                          size: 20,
                        ),
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
                      _SummaryCard(
                        label: 'Critical',
                        count: state.criticalCount,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 8),
                      _SummaryCard(
                        label: 'Urgent',
                        count: state.urgentCount,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _SummaryCard(
                        label: 'Warning',
                        count: state.warningCount,
                        color: AppColors.gray500,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.gray200),
                    itemBuilder: (_, i) =>
                        _DocumentItem(doc: state.filtered[i]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.r10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DocumentItem extends StatelessWidget {
  final DocumentExpiry doc;
  const _DocumentItem({required this.doc});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.employeeName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${doc.designation} • ${doc.documentType}',
                style: const TextStyle(fontSize: 11, color: AppColors.gray500),
              ),
              const SizedBox(height: 6),
              _DetailRow(label: 'Expires:', value: doc.expiryDate),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _urgencyColor(doc.urgency).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.r4),
              ),
              child: Text(
                doc.daysLeft >= 0
                    ? '${doc.daysLeft}d'
                    : '${-doc.daysLeft}d overdue',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _urgencyColor(doc.urgency),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  Color _urgencyColor(ExpiryUrgency u) => switch (u) {
    ExpiryUrgency.critical => AppColors.danger,
    ExpiryUrgency.urgent => AppColors.warning,
    ExpiryUrgency.warning => AppColors.gray500,
  };
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '$label ',
        style: const TextStyle(fontSize: 11, color: AppColors.gray400),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 11, color: AppColors.gray500),
      ),
    ],
  );
}
