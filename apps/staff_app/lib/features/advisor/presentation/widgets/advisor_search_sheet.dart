import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';

class AdvisorSearchSheet extends ConsumerStatefulWidget {
  final VoidCallback onScan;
  const AdvisorSearchSheet({super.key, required this.onScan});

  @override
  ConsumerState<AdvisorSearchSheet> createState() => _AdvisorSearchSheetState();
}

class _AdvisorSearchSheetState extends ConsumerState<AdvisorSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<JobCardEntity> _searchJobCards(List<JobCardEntity> cards) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return cards
        .where(
          (c) =>
              c.customerName.toLowerCase().contains(q) ||
              c.vehicleInfo.toLowerCase().contains(q) ||
              c.id.toLowerCase().contains(q),
        )
        .toList();
  }

  List<PendingApprovalEntity> _searchApprovals(
    List<PendingApprovalEntity> approvals,
  ) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return approvals
        .where(
          (a) =>
              a.customerName.toLowerCase().contains(q) ||
              a.estimateId.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Map<String, dynamic>> _searchCustomers() {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    try {
      final box = Hive.box<dynamic>('inspections');
      return box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where(
            (m) =>
                (m['customerName'] as String? ?? '').toLowerCase().contains(
                  q,
                ) ||
                (m['make'] as String? ?? '').toLowerCase().contains(q) ||
                (m['model'] as String? ?? '').toLowerCase().contains(q) ||
                (m['plateNumber'] as String? ?? '').toLowerCase().contains(q) ||
                (m['regNo'] as String? ?? '').toLowerCase().contains(q),
          )
          .take(5)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobCardsAsync = ref.watch(advisorRecentJobCardsProvider);
    final approvalsAsync = ref.watch(advisorPendingApprovalsProvider);
    final jobCards = jobCardsAsync.value ?? const <JobCardEntity>[];
    final approvals = approvalsAsync.value ?? const <PendingApprovalEntity>[];
    final cardResults = _searchJobCards(jobCards);
    final approvalResults = _searchApprovals(approvals);
    final customerResults = _searchCustomers();
    final hasResults =
        cardResults.isNotEmpty ||
        approvalResults.isNotEmpty ||
        customerResults.isNotEmpty;

    return AdvisorSheet(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AdvisorHandle(),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Search',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search customers, vehicles, job cards, approvals...',
                hintStyle: const TextStyle(
                  color: AppColors.text3,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.text3,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: widget.onScan,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.navy, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.r8),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                filled: true,
                fillColor: AppColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
            if (_query.isNotEmpty) ...[
              const SizedBox(height: 16),
              if (!hasResults)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No results found',
                    style: TextStyle(color: AppColors.text3, fontSize: 13),
                  ),
                )
              else ...[
                if (cardResults.isNotEmpty) ...[
                  _sectionHeader('Job Cards', cardResults.length),
                  const SizedBox(height: 6),
                  ...cardResults.map(
                    (j) => _resultItem(
                      Icons.assignment_rounded,
                      AppColors.accent,
                      j.customerName,
                      '${j.vehicleInfo}  \u00b7  ${j.id}',
                      () {
                        Navigator.pop(context);
                        context.push(AppRoutes.advisorDashboard);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (customerResults.isNotEmpty) ...[
                  _sectionHeader(
                    'Customers / Vehicles',
                    customerResults.length,
                  ),
                  const SizedBox(height: 6),
                  ...customerResults.map(
                    (c) => _resultItem(
                      Icons.person_rounded,
                      AppColors.success,
                      c['customerName'] as String? ?? '',
                      '${c['make'] ?? ''} ${c['model'] ?? ''}  \u00b7  ${c['plateNumber'] ?? ''}',
                      () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (approvalResults.isNotEmpty) ...[
                  _sectionHeader('Approvals', approvalResults.length),
                  const SizedBox(height: 6),
                  ...approvalResults.map(
                    (a) => _resultItem(
                      Icons.thumb_up_rounded,
                      AppColors.warning,
                      a.customerName,
                      '${a.estimateId}  \u00b7  AED ${a.amount.toStringAsFixed(0)}',
                      () => Navigator.pop(context),
                    ),
                  ),
                ],
              ],
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, int count) => Row(
    children: [
      Text(
        '$label ($count)',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.text2,
          letterSpacing: 0.3,
        ),
      ),
    ],
  );

  Widget _resultItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
