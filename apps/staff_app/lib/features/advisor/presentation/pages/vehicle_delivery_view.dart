import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';

class VehicleDeliveryView extends ConsumerStatefulWidget {
  final String jobCardRef;

  const VehicleDeliveryView({super.key, required this.jobCardRef});

  @override
  ConsumerState<VehicleDeliveryView> createState() =>
      _VehicleDeliveryViewState();
}

class _VehicleDeliveryViewState extends ConsumerState<VehicleDeliveryView> {
  final _notesCtrl = TextEditingController();
  final List<bool> _checked = List.filled(5, false);
  bool _isLoading = false;

  final List<String> _checklist = [
    'Invoice copy provided to customer',
    'Vehicle keys handed over',
    'Vehicle documents returned',
    'Next service reminder given',
    'Warranty information explained',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _allChecked => _checked.every((c) => c);

  Future<void> _deliver() async {
    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final ok = await remote.deliverVehicle(widget.jobCardRef, {
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle delivered successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to complete delivery')),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final checkedCount = _checked.where((c) => c).length;
    final progressPercent = (checkedCount / _checklist.length);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Handover Protocol',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              widget.jobCardRef,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: AppFontFamilies.mono,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                disabledForegroundColor: colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r16),
                ),
              ),
              onPressed: (_isLoading || !_allChecked) ? null : _deliver,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _allChecked ? 'Complete & Finalize Handover' : 'Complete All ${ _checklist.length - checkedCount } Remaining Checks',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── PROTOCOL PROGRESS BANNER ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppDimensions.r24),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppDimensions.r12),
                              ),
                              child: Icon(
                                Icons.key_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Handover Checklist',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        StatusPill(
                          label: '$checkedCount / ${_checklist.length} DONE',
                          bg: _allChecked
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : colorScheme.primary.withValues(alpha: 0.12),
                          fg: _allChecked ? const Color(0xFF10B981) : colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          _allChecked ? const Color(0xFF10B981) : colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Verification Points',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // ── CHECKLIST ITEMS ───────────────────────────────────────────
              AppCard(
                padding: EdgeInsets.zero,
                borderRadius: AppDimensions.r24,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                child: Column(
                  children: [
                    for (int i = 0; i < _checklist.length; i++) ...[
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          _checklist[i],
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: _checked[i] ? FontWeight.w800 : FontWeight.w500,
                            color: _checked[i] ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _checked[i],
                        activeColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (v) => setState(() => _checked[i] = v ?? false),
                      ),
                      if (i < _checklist.length - 1)
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Advisor Delivery Notes (Optional)',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: EdgeInsets.zero,
                borderRadius: AppDimensions.r20,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Customer feedback, return requests, warranty notes…',
                    hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppDimensions.s16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
