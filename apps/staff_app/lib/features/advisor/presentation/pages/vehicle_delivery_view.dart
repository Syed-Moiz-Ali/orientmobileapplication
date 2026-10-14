import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_signature_pad.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Formal vehicle delivery handover sheet: protocol checklist, final mileage
/// capture, customer satisfaction rating, delivery notes and an optional
/// customer sign-off signature.
///
/// Request contract is unchanged: `deliverVehicle(jobCardRef, {'notes': ...})`.
/// The captured handover facts (final mileage, rating, sign-off) travel inside
/// the same `notes` string the backend already stores — the payload shape is
/// preserved, only the record is complete.
class VehicleDeliveryView extends ConsumerStatefulWidget {
  final String jobCardRef;

  const VehicleDeliveryView({super.key, required this.jobCardRef});

  @override
  ConsumerState<VehicleDeliveryView> createState() =>
      _VehicleDeliveryViewState();
}

class _VehicleDeliveryViewState extends ConsumerState<VehicleDeliveryView> {
  final _mileageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _checklist = List<bool>.filled(5, false);
  int _rating = 0;
  String? _mileageError;
  String _signaturePath = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _mileageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _checkedCount => _checklist.where((c) => c).length;
  bool get _mileageValid =>
      _mileageCtrl.text.trim().isNotEmpty &&
      int.tryParse(_mileageCtrl.text.trim()) != null &&
      int.parse(_mileageCtrl.text.trim()) > 0;
  bool get _canComplete =>
      !_isLoading &&
      _checklist.every((c) => c) &&
      _mileageValid &&
      _rating > 0;

  List<String> _checkLabels(StaffLocalizations t) => [
    t.advisorDeliveryCheckInvoice,
    t.advisorDeliveryCheckKeys,
    t.advisorDeliveryCheckDocs,
    t.advisorDeliveryCheckService,
    t.advisorDeliveryCheckWarranty,
  ];

  /// The handover record. Shape-preserving: the endpoint receives the same
  /// `{'notes': String}` map as before; the string now carries the complete
  /// protocol facts after the advisor's free text.
  String _composedNotes(StaffLocalizations t) {
    final buffer = StringBuffer(_notesCtrl.text.trim());
    final facts = <String>[
      // LTR numerals: mileage and ratings never mirror in RTL.
      'Final mileage: ${_mileageCtrl.text.trim()} km',
      'Satisfaction: $_rating/5',
      if (_signaturePath.isNotEmpty) 'Customer sign-off: captured',
    ];
    if (facts.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(facts.join(' · '));
    }
    return buffer.toString();
  }

  Future<void> _deliver() async {
    final t = StaffLocalizations.of(context)!;
    if (!_mileageValid) {
      setState(() => _mileageError = t.advisorDeliveryMileageError);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final ok = await remote.deliverVehicle(widget.jobCardRef, {
        'notes': _composedNotes(t),
      });
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.advisorDeliverySuccess)),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.advisorDeliveryFailed)),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.advisorDeliveryError('$e'))));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _captureSignature() async {
    final t = StaffLocalizations.of(context)!;
    final bytes = await showModalBottomSheet<Uint8List>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      builder: (_) => AdvisorSignaturePad(title: t.advisorDeliverySignature),
    );
    if (bytes == null || bytes.isEmpty || !mounted) return;
    final path = await saveSignatureFile(
      bytes,
      'delivery_signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    if (!mounted || path.isEmpty) return;
    setState(() => _signaturePath = path);
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorDeliveryTitle,
        subtitle: t.advisorDeliverySubtitle,
        showBack: true,
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;
            final protocol = _protocolCard(t);
            final record = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _mileageCard(t),
                const SizedBox(height: AppDimensions.s16),
                _ratingCard(t),
                const SizedBox(height: AppDimensions.s16),
                _notesCard(t),
                const SizedBox(height: AppDimensions.s16),
                _signatureCard(t),
              ],
            );
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      context.pagePadding.left,
                      AppDimensions.s16,
                      context.pagePadding.right,
                      AppDimensions.s24,
                    ),
                    children: [
                      AppPageHeader(
                        breadcrumbs: [
                          AppBreadcrumbItem(
                            label: t.advisorNavJobs,
                            onTap: () => Navigator.maybePop(context),
                          ),
                          AppBreadcrumbItem.current(t.advisorDeliveryTitle),
                        ],
                        title: t.advisorDeliveryTitle,
                        subtitle: t.advisorDeliverySubtitle,
                        trailing: _refChip(t),
                      ),
                      const SizedBox(height: AppDimensions.s16),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: protocol),
                            const SizedBox(width: AppDimensions.s24),
                            Expanded(flex: 2, child: record),
                          ],
                        )
                      else ...[
                        protocol,
                        const SizedBox(height: AppDimensions.s16),
                        record,
                      ],
                    ],
                  ),
                ),
                _handoverBar(t),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Job reference chip: identifiers render LTR in both locales.
  Widget _refChip(StaffLocalizations t) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s6,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      ),
      child: Text(
        widget.jobCardRef,
        textDirection: TextDirection.ltr,
        style: AppTextStyles.mono(color: colors.primary).copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _protocolCard(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final labels = _checkLabels(t);
    final progress = _checkedCount / labels.length;
    final done = _checkedCount == labels.length;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.s8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCard,
                  ),
                ),
                child: Icon(
                  Icons.key_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  t.advisorDeliveryChecklistTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              StatusPill(
                label: t.advisorDeliveryProgress(
                  _checkedCount,
                  labels.length,
                ),
                bg: done
                    ? semantic.success.subtle
                    : semantic.info.subtle,
                fg: done
                    ? semantic.success.base
                    : semantic.info.base,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                done ? semantic.success.base : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          for (var i = 0; i < labels.length; i++) ...[
            CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s8,
                vertical: 2,
              ),
              title: Text(
                labels[i],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      _checklist[i] ? FontWeight.w700 : FontWeight.w500,
                  color: _checklist[i]
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                ),
              ),
              value: _checklist[i],
              activeColor: semantic.success.base,
              checkColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusXs,
                ),
              ),
              onChanged: (v) => setState(() => _checklist[i] = v ?? false),
            ),
            if (i < labels.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }

  Widget _mileageCard(StaffLocalizations t) {
    return AppFormPanel(
      title: t.advisorDeliveryMileage,
      child: AppFormField(
        label: t.advisorDeliveryMileage,
        isRequired: true,
        errorText: _mileageError,
        child: AppTextField(
          controller: _mileageCtrl,
          hint: t.advisorDeliveryMileageHint,
          keyboardType: TextInputType.number,
          isIdentifier: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: Icons.speed_rounded,
          onChanged: (_) {
            // Rebuild on every keystroke: the handover bar's enabled state
            // derives from this controller, and controllers never rebuild
            // their listeners by themselves.
            setState(() {
              if (_mileageError != null) _mileageError = null;
            });
          },
        ),
      ),
    );
  }

  Widget _ratingCard(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.advisorDeliveryRating,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                _rating == 0 ? '—' : t.advisorDeliveryRatingValue(_rating),
                textDirection: TextDirection.ltr,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _rating == 0
                      ? colors.onSurfaceVariant
                      : colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          // Star order is directional-neutral: always LTR so 5 stars always
          // means five stars in both locales.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Semantics(
              container: true,
              label: t.advisorDeliveryRating,
              value: _rating == 0
                  ? '—'
                  : t.advisorDeliveryRatingValue(_rating),
              increasedValue: t.advisorDeliveryRatingValue(
                (_rating + 1).clamp(1, 5),
              ),
              decreasedValue: t.advisorDeliveryRatingValue(
                (_rating - 1).clamp(1, 5),
              ),
              onIncrease: _rating < 5
                  ? () => setState(() => _rating = _rating + 1)
                  : null,
              onDecrease: _rating > 0
                  ? () => setState(() => _rating = _rating - 1)
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var star = 1; star <= 5; star++)
                    Semantics(
                      button: true,
                      selected: star <= _rating,
                      label: t.advisorDeliveryRatingValue(star),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _rating = star);
                        },
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: AppDimensions.touchTarget,
                            minHeight: AppDimensions.touchTarget,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            star <= _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 34,
                            color: star <= _rating
                                ? colors.primary
                                : colors.outline,
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
    );
  }

  Widget _notesCard(StaffLocalizations t) {
    return AppFormPanel(
      title: t.advisorDeliveryNotes,
      child: AppTextField(
        controller: _notesCtrl,
        hint: t.advisorDeliveryNotesHint,
        maxLines: 3,
        minLines: 3,
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  Widget _signatureCard(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final captured = _signaturePath.isNotEmpty;
    // Stacked sign-off block: the action sits below the text at full width so
    // long localized labels can never squeeze the description to zero.
    return AppCard.subtle(
      padding: const EdgeInsets.all(AppDimensions.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: captured
                      ? semantic.success.subtle
                      : colors.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  captured ? Icons.check_rounded : Icons.draw_outlined,
                  color: captured
                      ? semantic.success.base
                      : colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.advisorDeliverySignature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      captured
                          ? t.advisorDeliverySigned
                          : t.advisorDeliverySignatureHint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: captured
                            ? semantic.success.base
                            : colors.onSurfaceVariant,
                        fontWeight:
                            captured ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          AppButton.secondary(
            label: captured
                ? t.advisorDeliverySigned
                : t.advisorDeliverySignAction,
            leadingIcon: captured
                ? Icons.refresh_rounded
                : Icons.draw_outlined,
            onPressed: _captureSignature,
          ),
        ],
      ),
    );
  }

  Widget _handoverBar(StaffLocalizations t) {
    final remaining = _checklist.length - _checkedCount;
    String label;
    if (_isLoading) {
      label = t.advisorDeliveryComplete;
    } else if (!_checklist.every((c) => c)) {
      label = t.advisorDeliveryRemaining(remaining);
    } else {
      label = t.advisorDeliveryComplete;
    }
    return AppActionBar(
      sticky: true,
      primary: AppButton.primary(
        label: label,
        icon: _checklist.every((c) => c)
            ? Icons.verified_outlined
            : Icons.pending_actions_outlined,
        isLoading: _isLoading,
        isExpanded: context.adaptive.isCompact,
        onPressed: _canComplete ? _deliver : null,
      ),
    );
  }
}
