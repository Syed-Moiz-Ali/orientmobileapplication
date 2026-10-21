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
///
/// Recents are presentation state owned by the opener (the home keeps one
/// session list across sheet opens, capped here): the sheet seeds its
/// recents row from [recents] and reports every remembered query through
/// [onRemember]. Standalone use (no recents passed) behaves exactly as
/// before — recents live only while the sheet is open.
class AdvisorSearchSheet extends ConsumerStatefulWidget {
  final VoidCallback onScan;
  final List<String> recents;
  final ValueChanged<String>? onRemember;
  const AdvisorSearchSheet({
    super.key,
    required this.onScan,
    this.recents = const [],
    this.onRemember,
  });

  @override
  ConsumerState<AdvisorSearchSheet> createState() => _AdvisorSearchSheetState();
}

class _AdvisorSearchSheetState extends ConsumerState<AdvisorSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  /// Session-only recent searches (presentation state; cleared on dismiss
  /// unless the opener persists them via [AdvisorSearchSheet.onRemember]).
  late final List<String> _recent = [...widget.recents.take(5)];

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

  void _remember(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    widget.onRemember?.call(q);
    setState(() {
      _recent.remove(q);
      _recent.insert(0, q);
      if (_recent.length > 5) _recent.removeRange(5, _recent.length);
    });
  }

  void _runQuery(String query) => setState(() => _query = query);

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

    // Keyboard path: Enter in the field opens the top hit (Tab reaches every
    // row natively). Taps also feed the session recents.
    VoidCallback? firstHit;
    if (cardResults.isNotEmpty) {
      final j = cardResults.first;
      firstHit = () {
        _remember(_query);
        final router = GoRouter.of(context);
        Navigator.pop(context);
        router.push(AppRoutes.advisorJobDetail, extra: j);
      };
    } else if (customerResults.isNotEmpty) {
      firstHit = () {
        _remember(_query);
        Navigator.pop(context);
      };
    } else if (approvalResults.isNotEmpty) {
      firstHit = () {
        _remember(_query);
        Navigator.pop(context);
      };
    }

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
                  onClear: () => setState(() => _query = ''),
                  onSubmitted: (_) => firstHit?.call(),
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
          if (_query.isEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Text(
              t.advisorSearchPillSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_recent.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.advisorSearchRecent,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(_recent.clear),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppDimensions.touchTarget),
                    ),
                    child: Text(SharedCoreL10n.of(context).filterBarClear),
                  ),
                ],
              ),
              ..._recent.map(
                (q) => _result(
                  context,
                  icon: Icons.history_rounded,
                  title: q,
                  subtitle: '',
                  onTap: () {
                    _ctrl.text = q;
                    _runQuery(q);
                  },
                ),
              ),
            ],
          ],
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
                              _remember(_query);
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
