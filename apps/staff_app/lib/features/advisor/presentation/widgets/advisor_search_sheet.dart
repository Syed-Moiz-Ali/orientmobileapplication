import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_sheet.dart';

/// Global find sheet: search across job cards, customers/vehicles and
/// approvals, with a scan shortcut. Hive search behavior is unchanged.
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
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final jobCards =
        ref.watch(advisorRecentJobCardsProvider).value ??
        const <JobCardEntity>[];
    final approvals =
        ref.watch(advisorPendingApprovalsProvider).value ??
        const <PendingApprovalEntity>[];
    final cardResults = _searchJobCards(jobCards);
    final approvalResults = _searchApprovals(approvals);
    final customerResults = _searchCustomers();
    final hasResults =
        cardResults.isNotEmpty ||
        approvalResults.isNotEmpty ||
        customerResults.isNotEmpty;

    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.advisorSearchTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  controller: _ctrl,
                  autofocus: true,
                  hintText: t.advisorSearchHint,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              IconButton.filledTonal(
                onPressed: widget.onScan,
                tooltip: t.advisorActionScanTitle,
                icon: const Icon(Icons.qr_code_scanner_rounded),
              ),
            ],
          ),
          if (_query.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s16),
            if (!hasResults)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.s24,
                ),
                child: EmptyState.noMatch(
                  icon: Icons.search_off_rounded,
                  message: t.advisorNoResults,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (cardResults.isNotEmpty) ...[
                        _groupHeader(
                          context,
                          t.advisorSearchGroupJobCards,
                          cardResults.length,
                        ),
                        ...cardResults.map(
                          (j) => _result(
                            context,
                            icon: Icons.assignment_rounded,
                            title: j.customerName,
                            subtitle: '${j.vehicleInfo} · ${j.id}',
                            onTap: () {
                              final router = GoRouter.of(context);
                              Navigator.pop(context);
                              router.push(AppRoutes.advisorJobDetail, extra: j);
                            },
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s8),
                      ],
                      if (customerResults.isNotEmpty) ...[
                        _groupHeader(
                          context,
                          t.advisorSearchGroupCustomers,
                          customerResults.length,
                        ),
                        ...customerResults.map(
                          (c) => _result(
                            context,
                            icon: Icons.person_rounded,
                            title: c['customerName'] as String? ?? '',
                            subtitle:
                                '${c['make'] ?? ''} ${c['model'] ?? ''} · ${c['plateNumber'] ?? ''}',
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s8),
                      ],
                      if (approvalResults.isNotEmpty) ...[
                        _groupHeader(
                          context,
                          t.advisorSearchGroupApprovals,
                          approvalResults.length,
                        ),
                        ...approvalResults.map(
                          (a) => _result(
                            context,
                            icon: Icons.thumb_up_rounded,
                            title: a.customerName,
                            subtitle:
                                '${a.estimateId} · ${AppFormatters.of(context).moneyAED(a.amount)}',
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _groupHeader(BuildContext context, String label, int count) => Padding(
    padding: const EdgeInsets.only(
      top: AppDimensions.s4,
      bottom: AppDimensions.s6,
    ),
    child: Text(
      '$label ($count)',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );

  Widget _result(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppRecordRow(
      leading: Icon(icon, size: AppDimensions.iconMd),
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
