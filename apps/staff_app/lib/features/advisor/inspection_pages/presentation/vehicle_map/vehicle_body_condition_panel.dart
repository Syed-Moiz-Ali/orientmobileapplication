import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';

import 'vehicle_inspection_map.dart';

class VehicleBodyConditionPanel extends ConsumerStatefulWidget {
  final bool readOnly;
  final bool embedded;
  final bool showTitle;
  final Map<String, dynamic>? bodyCondition;
  const VehicleBodyConditionPanel({
    super.key,
    this.readOnly = false,
    this.embedded = false,
    this.showTitle = true,
    this.bodyCondition,
  });

  @override
  ConsumerState<VehicleBodyConditionPanel> createState() =>
      _VehicleBodyConditionPanelState();
}

class _VehicleBodyConditionPanelState
    extends ConsumerState<VehicleBodyConditionPanel> {
  late final Future<VehicleMapDefinition> _definition = VehicleMapLoader.load();
  final GlobalKey _mapKey = GlobalKey();
  String? _selectedPartId;
  Offset? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    final state = widget.bodyCondition == null
        ? ref.watch(inspectionProvider)
        : InspectionState.fromPersistableMap({
            'vehicleBodyCondition': widget.bodyCondition,
          });
    return FutureBuilder<VehicleMapDefinition>(
      future: _definition,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.directions_car_filled_outlined,
            message: 'Vehicle map could not be loaded',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final definition = snapshot.data!;
        final selected = _selectedPartId == null
            ? null
            : definition.partById(_selectedPartId!);
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final map = _map(definition, state);
            final details = _details(definition, selected, state);
            return ListView(
              // This panel is embedded in the job-card form/detail scroll view.
              // Let the parent own scrolling so this viewport always receives
              // a finite height and does not throw an unbounded-height error.
              shrinkWrap: widget.embedded,
              primary: false,
              physics: widget.embedded
                  ? const NeverScrollableScrollPhysics()
                  : null,
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                widget.embedded ? 16 : 100,
              ),
              children: [
                if (widget.showTitle) ...[
                  Text(
                    'Vehicle Body Condition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.readOnly
                            ? Icons.visibility_outlined
                            : Icons.touch_app_outlined,
                        size: 19,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          widget.readOnly
                              ? 'Recorded body condition and damage locations.'
                              : 'Tap the exact area, choose its condition, then add damage if needed.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: map),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: details),
                    ],
                  )
                else ...[
                  map,
                  const SizedBox(height: 14),
                  details,
                ],
                const SizedBox(height: 14),
                _legend(context),
                const SizedBox(height: 14),
                _summary(definition, state),
              ],
            );
          },
        );
      },
    );
  }

  Widget _map(VehicleMapDefinition definition, InspectionState state) =>
      AspectRatio(
        key: _mapKey,
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: VehicleInspectionMap(
              definition: definition,
              inspections: state.vehiclePartInspections,
              selectedPartId: _selectedPartId,
              editable: !widget.readOnly,
              placingMarker: false,
              onPartSelected: (part, normalized) {
                setState(() {
                  _selectedPartId = part.id;
                  _selectedPoint = normalized;
                });
              },
              onFindingSelected: (finding) {
                final part = definition.partById(finding.partId);
                if (part != null) {
                  setState(() => _selectedPartId = part.id);
                  _openFindingSheet(definition, part, existing: finding);
                }
              },
            ),
          ),
        ),
      );

  Widget _details(
    VehicleMapDefinition definition,
    VehicleMapPart? part,
    InspectionState state,
  ) {
    if (part == null) {
      return const EmptyState(
        icon: Icons.touch_app_outlined,
        message: 'Select a mapped vehicle part',
      );
    }
    final inspection =
        state.vehiclePartInspections[part.id] ??
        VehiclePartInspection(partId: part.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(part.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Condition', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VehiclePartCondition.values
                  .where((value) => value != VehiclePartCondition.uninspected)
                  .map(
                    (condition) => ChoiceChip(
                      label: Text(_conditionLabel(condition)),
                      selected: inspection.condition == condition,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                      labelStyle: TextStyle(
                        color: inspection.condition == condition
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(
                        color: inspection.condition == condition
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (_) => ref
                                .read(inspectionProvider.notifier)
                                .setVehiclePartCondition(part.id, condition),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Damage Findings (${inspection.findings.length})',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (!widget.readOnly)
                  TextButton.icon(
                    onPressed: () =>
                        _addDamageAtSelectedPoint(definition, part),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Add Damage'),
                  ),
              ],
            ),
            for (var i = 0; i < inspection.findings.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(radius: 12, child: Text('${i + 1}')),
                title: Text(_damageLabel(inspection.findings[i].damageType)),
                subtitle: Text(_severityLabel(inspection.findings[i].severity)),
                onTap: () => _openFindingSheet(
                  definition,
                  part,
                  existing: inspection.findings[i],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addDamageAtSelectedPoint(
    VehicleMapDefinition definition,
    VehicleMapPart part,
  ) {
    _openFindingSheet(
      definition,
      part,
      normalized: _selectedPoint ?? const Offset(0.5, 0.5),
    );
  }

  Future<void> _openFindingSheet(
    VehicleMapDefinition definition,
    VehicleMapPart part, {
    Offset? normalized,
    VehicleDamageFinding? existing,
  }) async {
    if (widget.readOnly && existing == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _VehicleFindingSheet(
        part: part,
        normalized: normalized,
        existing: existing,
        readOnly: widget.readOnly,
      ),
    );
  }

  Widget _legend(BuildContext context) => Wrap(
    spacing: 14,
    runSpacing: 8,
    children: [
      _legendItem('Good', AppColors.success),
      _legendItem('Minor', AppColors.warning),
      _legendItem('Major', AppColors.danger),
      _legendItem('Not inspected', AppColors.text4),
    ],
  );

  Widget _legendItem(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );

  Widget _summary(VehicleMapDefinition definition, InspectionState state) {
    final parts = state.vehiclePartInspections.values
        .where(
          (part) =>
              part.condition != VehiclePartCondition.uninspected ||
              part.findings.isNotEmpty,
        )
        .toList();
    final findings = parts.expand((part) => part.findings).toList();
    final good = parts
        .where((part) => part.effectiveCondition == VehiclePartCondition.good)
        .length;
    final minor = parts
        .where((part) => part.effectiveCondition == VehiclePartCondition.minor)
        .length;
    final major = parts
        .where((part) => part.effectiveCondition == VehiclePartCondition.major)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${parts.length} parts inspected · ${findings.length} findings',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('Good: $good  ·  Minor: $minor  ·  Major: $major'),
        for (final partInspection in parts)
          if (partInspection.findings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${definition.partById(partInspection.partId)?.label ?? partInspection.partId}: '
                '${partInspection.findings.map((finding) => '${_damageLabel(finding.damageType)} (${_severityLabel(finding.severity)})').join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
      ],
    );
  }
}

class _VehicleFindingSheet extends ConsumerStatefulWidget {
  final VehicleMapPart part;
  final Offset? normalized;
  final VehicleDamageFinding? existing;
  final bool readOnly;

  const _VehicleFindingSheet({
    required this.part,
    this.normalized,
    this.existing,
    required this.readOnly,
  });

  @override
  ConsumerState<_VehicleFindingSheet> createState() =>
      _VehicleFindingSheetState();
}

class _VehicleFindingSheetState extends ConsumerState<_VehicleFindingSheet> {
  late VehicleDamageType _type =
      widget.existing?.damageType ?? VehicleDamageType.scratch;
  late VehicleDamageSeverity _severity =
      widget.existing?.severity ?? VehicleDamageSeverity.minor;
  late VehicleRecommendedAction _action =
      widget.existing?.recommendedAction ?? VehicleRecommendedAction.noAction;
  late final TextEditingController _note = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late final TextEditingController _location = TextEditingController(
    text: widget.existing?.damageLocation ?? '',
  );
  late List<String> _photos = [...?widget.existing?.photos];

  @override
  void dispose() {
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.part.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<VehicleDamageType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Damage Type'),
              items: VehicleDamageType.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_damageLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: widget.readOnly ? null : (value) => _type = value!,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VehicleDamageSeverity>(
              initialValue: _severity,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: VehicleDamageSeverity.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_severityLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: widget.readOnly ? null : (value) => _severity = value!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(labelText: 'Damage Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              enabled: !widget.readOnly,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VehicleRecommendedAction>(
              initialValue: _action,
              decoration: const InputDecoration(
                labelText: 'Recommended Action',
              ),
              items: VehicleRecommendedAction.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_actionLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: widget.readOnly ? null : (value) => _action = value!,
            ),
            const SizedBox(height: 12),
            if (!widget.readOnly)
              OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text('Add Photos (${_photos.length})'),
              ),
            if (_photos.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var index = 0; index < _photos.length; index++)
                    InputChip(
                      avatar: const Icon(Icons.image_outlined, size: 18),
                      label: Text('Photo ${index + 1}'),
                      onDeleted: widget.readOnly
                          ? null
                          : () => setState(() => _photos.removeAt(index)),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            if (!widget.readOnly)
              FilledButton(onPressed: _save, child: const Text('Save Finding')),
            if (widget.existing != null && !widget.readOnly)
              TextButton(
                onPressed: _delete,
                child: const Text('Delete Finding'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 80);
    final dir = await getApplicationDocumentsDirectory();
    final saved = <String>[];
    for (final file in files) {
      final extension = file.path.contains('.')
          ? '.${file.path.split('.').last}'
          : '';
      saved.add(
        await persistMediaFile(
          file.path,
          '${dir.path}/vehicle_damage_${DateTime.now().microsecondsSinceEpoch}$extension',
        ),
      );
    }
    if (mounted) setState(() => _photos = [..._photos, ...saved]);
  }

  void _save() {
    final point =
        widget.normalized ??
        Offset(
          widget.existing?.normalizedX ?? 0.5,
          widget.existing?.normalizedY ?? 0.5,
        );
    final finding = VehicleDamageFinding(
      id: widget.existing?.id ?? 'VDF-${DateTime.now().microsecondsSinceEpoch}',
      partId: widget.part.id,
      damageType: _type,
      severity: _severity,
      damageLocation: _location.text.trim(),
      note: _note.text.trim(),
      photos: _photos,
      recommendedAction: _action,
      normalizedX: point.dx,
      normalizedY: point.dy,
    );
    final notifier = ref.read(inspectionProvider.notifier);
    if (widget.existing == null) {
      notifier.addVehicleDamageFinding(finding);
    } else {
      notifier.updateVehicleDamageFinding(finding);
    }
    Navigator.pop(context);
  }

  void _delete() {
    ref
        .read(inspectionProvider.notifier)
        .removeVehicleDamageFinding(widget.part.id, widget.existing!.id);
    Navigator.pop(context);
  }
}

String _conditionLabel(VehiclePartCondition value) => switch (value) {
  VehiclePartCondition.uninspected => 'Not inspected',
  VehiclePartCondition.good => 'Good',
  VehiclePartCondition.minor => 'Minor Issue',
  VehiclePartCondition.major => 'Major Issue',
};

String _damageLabel(VehicleDamageType value) => switch (value) {
  VehicleDamageType.scratch => 'Scratch',
  VehicleDamageType.deepScratch => 'Deep Scratch',
  VehicleDamageType.dent => 'Dent',
  VehicleDamageType.paintChip => 'Paint Chip',
  VehicleDamageType.crack => 'Crack',
  VehicleDamageType.repainted => 'Repainted',
  VehicleDamageType.faded => 'Faded',
  VehicleDamageType.rust => 'Rust',
  VehicleDamageType.broken => 'Broken / Damaged',
  VehicleDamageType.other => 'Other',
};

String _severityLabel(VehicleDamageSeverity value) => switch (value) {
  VehicleDamageSeverity.minor => 'Minor',
  VehicleDamageSeverity.moderate => 'Moderate',
  VehicleDamageSeverity.major => 'Major',
};

String _actionLabel(VehicleRecommendedAction value) => switch (value) {
  VehicleRecommendedAction.noAction => 'No Action',
  VehicleRecommendedAction.monitor => 'Monitor',
  VehicleRecommendedAction.repair => 'Repair',
  VehicleRecommendedAction.repaint => 'Repaint',
  VehicleRecommendedAction.replace => 'Replace',
};
