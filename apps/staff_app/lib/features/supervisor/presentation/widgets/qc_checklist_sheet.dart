import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class QcChecklistSheet extends ConsumerStatefulWidget {
  final int jobCardId;
  final String jobCardRef;
  final String customerName;
  final String vehicleInfo;

  // FE-FLOW (seamless-flow integration): the checklist now reflects the
  // ACTUAL completed work items instead of a hardcoded generic template.
  final List<String> workItems;

  const QcChecklistSheet({
    super.key,
    required this.jobCardId,
    required this.jobCardRef,
    required this.customerName,
    required this.vehicleInfo,
    this.workItems = const [],
  });

  @override
  ConsumerState<QcChecklistSheet> createState() => _QcChecklistSheetState();
}

class _QcChecklistSheetState extends ConsumerState<QcChecklistSheet> {
  static const _fallbackItems = [
    'Oil/fluid levels verified',
    'Tyre pressures set correctly',
    'Warning lights cleared',
    'Test drive completed',
    'Vehicle interior cleaned',
    'All tools removed from vehicle',
    'Completed work checked against estimate',
  ];

  late final List<String> _items;

  late final List<bool> _checked;
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _items = widget.workItems.isNotEmpty ? widget.workItems : _fallbackItems;
    _checked = List.filled(_items.length, false);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _checkedCount => _checked.where((c) => c).length;
  bool get _allChecked => _checkedCount == _items.length;

  // FE-FLOW: two-step approval — QC review gate FIRST (qualityCheckPassed),
  // then completion approval (completed + invoice).
  Future<void> _approve() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final qcMsg = await notifier.qcReview(widget.jobCardRef, 'approve',
        checklistPassed: _allChecked, notes: _notesCtrl.text.trim());
    if (qcMsg.startsWith('Could not')) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(qcMsg)));
      }
      return;
    }
    final msg = await notifier.approveCompletion(widget.jobCardId);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$qcMsg · $msg')));
    }
  }

  Future<void> _reject() async {
    final reason = _notesCtrl.text.trim();
    if (reason.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a reason to send the job back')),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    final msg = await ref
        .read(supervisorDashboardProvider.notifier)
        .qcReview(widget.jobCardRef, 'reject',
            checklistPassed: false, notes: reason, rejectReason: reason);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.r24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quality Control Review',
                  style: AppTextStyles.rajdhaniTitle(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.jobCardRef} · ${widget.customerName} · ${widget.vehicleInfo}',
                  style: const TextStyle(color: AppColors.text3, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Checklist',
                      style: AppTextStyles.rajdhaniTitle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    StatusPill(
                      label: '$_checkedCount/${_items.length} items checked',
                      bg: AppColors.primaryBg,
                      fg: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _checkedCount / _items.length,
                    minHeight: 6,
                    backgroundColor: AppColors.primaryBg,
                    color: _allChecked ? AppColors.success : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                return CheckboxListTile(
                  title: Text(
                    _items[i],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  value: _checked[i],
                  activeColor: AppColors.success,
                  checkColor: Colors.white,
                  dense: true,
                  onChanged: (v) {
                    if (v != null) setState(() => _checked[i] = v);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'QC Notes (Optional)',
                    filled: true,
                    fillColor: AppColors.primaryBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
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
                        onPressed: _isLoading ? null : _reject,
                        child: const Text(
                          'Send Back for Revision',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                          ),
                        ),
                        onPressed: (_isLoading || !_allChecked)
                            ? null
                            : _approve,
                        child: const Text(
                          'Approve & Close Job',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
