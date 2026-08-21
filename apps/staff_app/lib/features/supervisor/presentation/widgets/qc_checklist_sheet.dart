import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class QcChecklistSheet extends ConsumerStatefulWidget {
  final int jobCardId;
  final String jobCardRef;
  final String customerName;
  final String vehicleInfo;
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

  Future<void> _approve() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final qcMsg = await notifier.qcReview(
      widget.jobCardRef,
      'approve',
      checklistPassed: _allChecked,
      notes: _notesCtrl.text.trim(),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$qcMsg · $msg')));
    }
  }

  Future<void> _reject() async {
    final reason = _notesCtrl.text.trim();
    if (reason.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enter a reason to send the job back')));
      }
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    final msg = await ref
        .read(supervisorDashboardProvider.notifier)
        .qcReview(widget.jobCardRef, 'reject', checklistPassed: false, notes: reason, rejectReason: reason);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quality Control Review',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_checkedCount/${_items.length} items',
                        style: textTheme.labelSmall?.copyWith(
                          color: _allChecked ? colorScheme.secondary : colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.jobCardRef} · ${widget.customerName} · ${widget.vehicleInfo}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _items.isEmpty ? 0 : _checkedCount / _items.length,
                    minHeight: 5,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(_allChecked ? colorScheme.secondary : colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final isChecked = _checked[i];
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _checked[i] = !isChecked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isChecked ? colorScheme.surfaceContainerLow : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isChecked ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isChecked ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _items[i],
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'QC Inspector Notes (Optional)',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _reject,
                        child: const Text('Send Back', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: (_isLoading || !_allChecked) ? null : _approve,
                        child: const Text('Approve & Close', style: TextStyle(fontWeight: FontWeight.w800)),
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
