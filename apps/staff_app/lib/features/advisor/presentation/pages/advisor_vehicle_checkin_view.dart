import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Advisor vehicle check-in: a digital telemetry cluster that records the
/// fuel level, odometer, notes and any existing damage before the job card is
/// handed to inspection.
///
/// Submit contract is unchanged (`checkInVehicleResult` + pushReplacement to
/// the advisor job detail with the same `JobCardEntity`). Fuel values stay the
/// five domain detents (`Empty`, `1/4`, `1/2`, `3/4`, `Full`); the dial only
/// changes how they are captured.
class AdvisorVehicleCheckinView extends ConsumerStatefulWidget {
  final String bookingId;
  final String customerName;
  final String vehicleInfo;

  const AdvisorVehicleCheckinView({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.vehicleInfo,
  });

  @override
  ConsumerState<AdvisorVehicleCheckinView> createState() =>
      _AdvisorVehicleCheckinViewState();
}

/// Domain fuel detents in gauge order. Never reordered or renamed: the raw
/// value is submitted to the check-in endpoint verbatim.
const _fuelDetents = <String>['Empty', '1/4', '1/2', '3/4', 'Full'];

class _AdvisorVehicleCheckinViewState
    extends ConsumerState<AdvisorVehicleCheckinView> {
  int _odometer = 0;
  final _notesCtrl = TextEditingController();
  String _fuelLevel = '1/4';
  final List<String> _damages = [];
  bool _isLoading = false;
  bool _confirming = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fuelLabel(StaffLocalizations t, String value) {
    switch (value) {
      case 'Empty':
        return t.advisorCheckInFuelEmpty;
      case '1/2':
        return t.advisorCheckInFuelHalf;
      case '3/4':
        return t.advisorCheckInFuelThreeQuarter;
      case 'Full':
        return t.advisorCheckInFuelFull;
      default:
        return t.advisorCheckInFuelQuarter;
    }
  }

  void _addDamage(String area) {
    final t = StaffLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: Text(t.advisorCheckInDamageTitle(area)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(hintText: t.advisorCheckInDamageHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(SharedCoreL10n.of(context).commonCancel),
            ),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _damages.add('$area: ${ctrl.text.trim()}'));
                }
                Navigator.pop(context);
              },
              child: Text(t.advisorCheckInAdd),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final t = StaffLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final result = await remote.checkInVehicleResult(widget.bookingId, {
        'odometer': _odometer,
        'fuelLevel': _fuelLevel,
        'existingDamages': _damages.join(', '),
        'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.advisorCheckInSuccess)),
        );
        context.pushReplacement(
          AppRoutes.advisorJobDetail,
          extra: JobCardEntity(
            id: '${result.jobCardId}',
            dbId: result.jobCardId,
            customerName: widget.customerName,
            vehicleInfo: widget.vehicleInfo,
            time: '',
            createdDate: '',
            lastUpdated: '',
            status: JobCardStatus.vehicleReceived,
            odometer: _odometer,
            fuelLevel: _fuelLevel,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.advisorCheckInFailed)),
        );
        setState(() {
          _isLoading = false;
          _confirming = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.advisorCheckInError('$e'))),
      );
      setState(() {
        _isLoading = false;
        _confirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).value ?? 0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorCheckInTitle,
        subtitle: widget.vehicleInfo.isEmpty ? null : widget.vehicleInfo,
        showBack: true,
        onBack: _confirming
            ? () => setState(() => _confirming = false)
            : () => Navigator.maybePop(context),
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;
            final content = _confirming
                ? _confirmationPanel(t)
                : _clusterPanels(t, wide);
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
                          AppBreadcrumbItem.current(t.advisorCheckInTitle),
                        ],
                        title: widget.customerName.isEmpty
                            ? widget.vehicleInfo
                            : widget.customerName,
                        subtitle: widget.customerName.isEmpty
                            ? t.advisorCheckInClusterSub
                            : widget.vehicleInfo,
                      ),
                      const SizedBox(height: AppDimensions.s16),
                      if (wide && !_confirming)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _telemetryCard(t)),
                            const SizedBox(width: AppDimensions.s24),
                            Expanded(flex: 2, child: _conditionCard(t)),
                          ],
                        )
                      else
                        content,
                    ],
                  ),
                ),
                _actionBar(t),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _clusterPanels(StaffLocalizations t, bool wide) {
    if (wide) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _telemetryCard(t),
        const SizedBox(height: AppDimensions.s16),
        _conditionCard(t),
      ],
    );
  }

  /// Fuel dial + odometer drums: the telemetry instrument of this screen.
  Widget _telemetryCard(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusInput,
                  ),
                ),
                child: Icon(
                  Icons.speed_rounded,
                  size: 19,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  t.advisorCheckInStepDetails,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          _FuelDial(
            title: t.advisorCheckInFuel,
            value: _fuelLevel,
            labels: {
              for (final detent in _fuelDetents)
                detent: _fuelLabel(t, detent),
            },
            onChanged: (v) => setState(() => _fuelLevel = v),
          ),
          const SizedBox(height: AppDimensions.s8),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: AppDimensions.s16),
          _OdometerDrums(
            value: _odometer,
            unit: t.advisorCheckInOdoUnit,
            title: t.advisorCheckInOdoTitle,
            add1kLabel: t.advisorCheckInOdoPlus1k,
            add10kLabel: t.advisorCheckInOdoPlus10k,
            resetLabel: t.advisorCheckInOdoClear,
            onChanged: (v) => setState(() => _odometer = v),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorCheckInNotes,
            isOptional: true,
            child: AppTextField(
              controller: _notesCtrl,
              hint: t.advisorCheckInNotesHint,
              maxLines: 3,
              minLines: 3,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionCard(StaffLocalizations t) {
    final areas = <String>[
      t.advisorCheckInFront,
      t.advisorCheckInRear,
      t.advisorCheckInLeft,
      t.advisorCheckInRight,
      t.advisorCheckInRoof,
    ];
    return AppFormPanel(
      title: t.advisorCheckInSectionDamage,
      subtitle: t.advisorCheckInSectionDamageSub,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 3 : 2;
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: columns,
                mainAxisSpacing: AppDimensions.s10,
                crossAxisSpacing: AppDimensions.s10,
                childAspectRatio: 2.6,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final area in areas)
                    OutlinedButton(
                      onPressed: () => _addDamage(area),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, AppDimensions.touchTarget),
                      ),
                      child: Text(
                        area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.s16),
          if (_damages.isEmpty)
            EmptyState(
              icon: Icons.verified_outlined,
              message: t.advisorCheckInEmptyDamages,
            )
          else ...[
            for (var i = 0; i < _damages.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.s8),
                child: AppCard.subtle(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s14,
                    vertical: AppDimensions.s8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        size: 18,
                        color: context
                            .semanticColors
                            .damageModerate
                            .base,
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          _damages[i],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: t.advisorCheckInRemoveDamage,
                        onPressed: () => setState(() => _damages.removeAt(i)),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Pre-submit review: the explicit confirmation state for the handover to
  /// inspection. Nothing here changes the submit payload.
  Widget _confirmationPanel(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final rows = <(String, String)>[
      (
        t.advisorCheckInOdometer,
        // LTR numerals: odometer values never mirror in RTL.
        '${_odometer.toString()} ${t.advisorCheckInOdoUnit}',
      ),
      (t.advisorCheckInFuel, _fuelLabel(t, _fuelLevel)),
      (
        t.advisorCheckInSectionDamage,
        _damages.isEmpty
            ? t.advisorCheckInEmptyDamages
            : _damages.join('\n'),
      ),
      if (_notesCtrl.text.trim().isNotEmpty)
        (t.advisorCheckInNotes, _notesCtrl.text.trim()),
    ];
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: semantic.inspectionAdvisory.subtle,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCard,
                  ),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: semantic.inspectionAdvisory.base,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.advisorCheckInConfirmTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.advisorCheckInConfirmBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          for (final row in rows) ...[
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.s10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.$1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.$2,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBar(StaffLocalizations t) {
    if (_confirming) {
      return AppActionBar(
        sticky: true,
        isLoading: _isLoading,
        secondary: [
          AppButton.secondary(
            label: t.advisorCheckInBack,
            leadingIcon: Icons.arrow_back_rounded,
            isExpanded: context.adaptive.isCompact,
            onPressed: _isLoading
                ? null
                : () => setState(() => _confirming = false),
          ),
        ],
        primary: AppButton.primary(
          label: t.advisorCheckInComplete,
          icon: Icons.check_rounded,
          isLoading: _isLoading,
          isExpanded: context.adaptive.isCompact,
          onPressed: _isLoading ? null : _submit,
        ),
      );
    }
    return AppActionBar(
      sticky: true,
      primary: AppButton.primary(
        label: t.advisorCheckInComplete,
        icon: Icons.fact_check_outlined,
        isExpanded: context.adaptive.isCompact,
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _confirming = true);
        },
      ),
    );
  }
}

/// Interactive semicircular fuel gauge over the five domain detents.
///
/// The filled arc takes the selected level's semantic color (danger at Empty
/// through success at Full); the track and ticks resolve from the active
/// theme. Taps on the arc snap to the nearest detent, and the detent rail
/// below gives every level a ≥48 dp target plus full screen-reader support.
class _FuelDial extends StatelessWidget {
  final String title;
  final String value;
  final Map<String, String> labels;
  final ValueChanged<String> onChanged;

  const _FuelDial({
    required this.title,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final selected = _fuelDetents.indexOf(value).clamp(0, 4);

    Color levelColor(int index) {
      switch (index) {
        case 0:
          return semantic.danger.base;
        case 1:
          return semantic.warning.base;
        case 2:
          return semantic.info.base;
        default:
          return semantic.success.base;
      }
    }

    return Semantics(
      container: true,
      label: title,
      value: labels[value],
      increasedValue: labels[_fuelDetents[(selected + 1).clamp(0, 4)]],
      decreasedValue: labels[_fuelDetents[(selected - 1).clamp(0, 4)]],
      onIncrease: selected < 4 ? () => onChanged(_fuelDetents[selected + 1]) : null,
      onDecrease: selected > 0 ? () => onChanged(_fuelDetents[selected - 1]) : null,
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final local = box.globalToLocal(details.globalPosition);
              final index = _FuelDialPainter.indexForPosition(
                local,
                box.size,
              );
              if (index != null) {
                HapticFeedback.selectionClick();
                onChanged(_fuelDetents[index]);
              }
            },
            child: CustomPaint(
              painter: _FuelDialPainter(
                selected: selected,
                track: colors.outlineVariant,
                needle: colors.onSurface,
                tick: colors.onSurfaceVariant,
                level: levelColor(selected),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.mono(
                        color: colors.onSurface,
                      ).copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      labels[value]!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: levelColor(selected),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s8),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Row(
            children: [
              for (var i = 0; i < _fuelDetents.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    label: labels[_fuelDetents[i]],
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(_fuelDetents[i]);
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: AppDimensions.touchTarget,
                        ),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i == selected
                              ? colors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusControl,
                          ),
                          border: Border.all(
                            color: i == selected
                                ? colors.primary
                                : colors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          labels[_fuelDetents[i]]!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: i == selected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FuelDialPainter extends CustomPainter {
  final int selected;
  final Color track;
  final Color needle;
  final Color tick;
  final Color level;

  const _FuelDialPainter({
    required this.selected,
    required this.track,
    required this.needle,
    required this.tick,
    required this.level,
  });

  static double _angleFor(int index) => 180 - index * 45;

  /// Maps a tap position inside [size] to the nearest detent, or null when
  /// the tap falls outside the gauge band.
  static int? indexForPosition(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width / 2 - 16;
    final dx = local.dx - center.dx;
    final dy = center.dy - local.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist > radius + 44 || dist < math.max(radius - 72, 0)) {
      return null;
    }
    var degrees = math.atan2(dy, dx) * 180 / math.pi;
    if (degrees < 0) degrees = 0;
    if (degrees > 180) degrees = 180;
    return ((180 - degrees) / 45).round().clamp(0, 4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width / 2 - 16;
    const stroke = 14.0;

    double rad(double degrees) => degrees * math.pi / 180;

    // Track: full 180° band.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rad(180),
      rad(180),
      false,
      Paint()
        ..color = track
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    // Filled portion from Empty (180°) to the selected detent.
    final sweep = selected * 45.0;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        rad(180),
        rad(sweep),
        false,
        Paint()
          ..color = level
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
    // Ticks at every detent.
    for (var i = 0; i < 5; i++) {
      final a = rad(_angleFor(i));
      final outer = Offset(
        center.dx + (radius + stroke) * math.cos(a),
        center.dy - (radius + stroke) * math.sin(a),
      );
      canvas.drawCircle(
        outer,
        i == selected ? 5 : 3.5,
        Paint()..color = i == selected ? level : tick,
      );
    }
    // Needle to the selected detent.
    final a = rad(_angleFor(selected));
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius - stroke - 6) * math.cos(a),
        center.dy - (radius - stroke - 6) * math.sin(a),
      ),
      Paint()
        ..color = needle
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 5, Paint()..color = needle);
  }

  @override
  bool shouldRepaint(covariant _FuelDialPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.level != level ||
      oldDelegate.track != track ||
      oldDelegate.needle != needle ||
      oldDelegate.tick != tick;
}

/// Digital odometer drum picker: six LTR digit wheels with quick scrollers.
///
/// Values stay plain LTR numerals in both locales (RTL spec non-mirroring
/// rule for odometer readings).
class _OdometerDrums extends StatelessWidget {
  final int value;
  final String unit;
  final String title;
  final String add1kLabel;
  final String add10kLabel;
  final String resetLabel;
  final ValueChanged<int> onChanged;

  const _OdometerDrums({
    required this.value,
    required this.unit,
    required this.title,
    required this.add1kLabel,
    required this.add10kLabel,
    required this.resetLabel,
    required this.onChanged,
  });

  List<int> get _digits {
    final clamped = value.clamp(0, 999999);
    return List<int>.generate(
      6,
      (i) => (clamped ~/ _pow10(5 - i)) % 10,
    );
  }

  int _pow10(int e) {
    var r = 1;
    for (var i = 0; i < e; i++) {
      r *= 10;
    }
    return r;
  }

  int _withDigit(int position, int digit) {
    final digits = _digits;
    digits[position] = digit;
    return digits.fold(0, (acc, d) => acc * 10 + d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final digits = _digits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
            Text(
              '$value $unit',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.mono(color: colors.primary).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Semantics(
            container: true,
            label: title,
            value: '$value $unit',
            increasedValue: '${(value + 1).clamp(0, 999999)} $unit',
            decreasedValue: '${(value - 1).clamp(0, 999999)} $unit',
            onIncrease: () => onChanged((value + 1).clamp(0, 999999)),
            onDecrease: () => onChanged((value - 1).clamp(0, 999999)),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusCard,
                ),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  for (var position = 0; position < 6; position++)
                    Expanded(
                      child: _DrumWheel(
                        digit: digits[position],
                        onSelected: (d) =>
                            onChanged(_withDigit(position, d)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      onChanged((value + 1000).clamp(0, 999999)),
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(0, AppDimensions.touchTarget),
                  ),
                  child: Text(add1kLabel, maxLines: 1),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      onChanged((value + 10000).clamp(0, 999999)),
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(0, AppDimensions.touchTarget),
                  ),
                  child: Text(add10kLabel, maxLines: 1),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onChanged(0),
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(0, AppDimensions.touchTarget),
                  ),
                  child: Text(resetLabel, maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrumWheel extends StatefulWidget {
  final int digit;
  final ValueChanged<int> onSelected;

  const _DrumWheel({required this.digit, required this.onSelected});

  @override
  State<_DrumWheel> createState() => _DrumWheelState();
}

class _DrumWheelState extends State<_DrumWheel> {
  FixedExtentScrollController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.digit);
  }

  @override
  void didUpdateWidget(covariant _DrumWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit &&
        _controller!.selectedItem != widget.digit) {
      _controller!.jumpToItem(widget.digit);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: 40,
      perspective: 0.004,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: widget.onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 10,
        builder: (context, index) {
          final active = index == widget.digit;
          return Center(
            child: Text(
              '$index',
              style: AppTextStyles.mono(
                color: active ? colors.onSurface : colors.onSurfaceVariant,
              ).copyWith(
                fontSize: active ? 26 : 20,
                fontWeight: active ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
