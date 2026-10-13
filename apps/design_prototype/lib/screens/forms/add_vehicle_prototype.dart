// D4 · Add Vehicle form prototype.
//
// Fields mirror `CustomerVehicleEntity` (add_vehicle_view.dart: make, model,
// plate, VIN, year, colour, mileage) extended with the Ownership section used
// by the intake/lead form patterns (owner name, phone) and Notes.
// Three quiet sections · label-above fields · inline validation on submit ·
// sticky action bar with honest busy state · LTR identifier fields inside
// RTL layouts (mixed-input proof: Arabic owner name beside Latin plate).
// States: pristine / focused-invalid / saving / save-error.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/prototype_theme.dart';
import '../../design/provisional_tokens.dart';
import '../../fixtures/vehicle_form_fixtures.dart';
import '../../l10n/provisional_strings.dart';
import '../../widgets/proto_primitives.dart';

class AddVehiclePrototype extends StatefulWidget {
  final String variant;

  const AddVehiclePrototype({super.key, required this.variant});

  @override
  State<AddVehiclePrototype> createState() => _AddVehiclePrototypeState();
}

class _AddVehiclePrototypeState extends State<AddVehiclePrototype> {
  final _plate = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _colour = TextEditingController();
  final _mileage = TextEditingController();
  final _vin = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  String _plateError = '';
  String _makeError = '';
  String _modelError = '';
  String _yearError = '';
  String _saveError = '';
  bool _saving = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    if (widget.variant == 'invalid') {
      // Partially filled with deliberate mistakes; validation runs on the
      // first frame (Localizations are not readable during initState).
      _make.text = 'Toyota';
      _year.text = '2040';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _validate();
      });
    }
    if (widget.variant == 'saveError') {
      // A real save-error happens after the user filled the form: show the
      // full valid form plus the failure notice with retry.
      _plate.text = vehicleFormFixture.plate;
      _make.text = vehicleFormFixture.make;
      _model.text = vehicleFormFixture.model;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _owner.text = vehicleFormFixture.owner.of(context);
          _saveError = context.s('vehicle.error.save');
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_plate, _make, _model, _year, _colour, _mileage, _vin, _owner, _phone, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _dirty => [_plate, _make, _model, _year, _colour, _mileage, _vin, _owner, _phone, _notes]
      .any((c) => c.text.trim().isNotEmpty);

  bool get _savingState => widget.variant == 'saving' || _saving;

  bool _validate() {
    final plate = _plate.text.trim();
    final make = _make.text.trim();
    final model = _model.text.trim();
    final yearRaw = _year.text.trim();
    final year = yearRaw.isEmpty ? 0 : int.tryParse(yearRaw) ?? -1;

    setState(() {
      _plateError = plate.isEmpty ? context.s('vehicle.error.plate') : '';
      _makeError = make.isEmpty ? context.s('vehicle.error.make') : '';
      _modelError = model.isEmpty ? context.s('vehicle.error.model') : '';
      _yearError = year != 0 && (year == -1 || year < 1950 || year > 2027)
          ? context.s('vehicle.error.year')
          : '';
      _showErrors = true;
    });
    return _plateError.isEmpty && _makeError.isEmpty && _modelError.isEmpty && _yearError.isEmpty;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_validate()) return;
    setState(() {
      _saving = true;
      _saveError = '';
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (widget.variant == 'saveError') {
      setState(() {
        _saving = false;
        _saveError = context.s('vehicle.error.save');
      });
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.s('vehicle.saved'))));
  }

  Future<void> _confirmDiscard() async {
    if (!_dirty) {
      Navigator.pop(context);
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: context.palette.warning, size: 30),
        title: Text(context.s('vehicle.discard.title')),
        content: Text(context.s('vehicle.discard.body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.s('vehicle.discard.stay')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.palette.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.s('vehicle.discard.leave')),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final wide = !context.windowClass.isCompact;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_saveError.isNotEmpty) ...[
          ProtoErrorBanner(
            title: context.s('common.errorTitle'),
            body: _saveError,
            onRetry: _save,
          ),
          const SizedBox(height: ProtoSpace.s16),
        ],
        _FormSection(
          title: context.s('vehicle.section.vehicle'),
          subtitle: context.s('vehicle.section.vehicleSub'),
          children: [
            ProtoField(
              label: context.s('vehicle.field.plate'),
              hint: context.s('vehicle.hint.plate'),
              icon: Icons.pin_outlined,
              controller: _plate,
              ltrContent: true,
              marker: context.s('common.required'),
              helperText: context.s('vehicle.helper.plate'),
              errorText: _showErrors ? _plateError : null,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
            if (_plate.text.trim().isNotEmpty) ...[
              const SizedBox(height: ProtoSpace.s10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ProtoPlateChip(plate: _plate.text.trim()),
              ),
            ],
            const SizedBox(height: ProtoSpace.s16),
            _ResponsiveFieldPair(
              first: ProtoField(
                label: context.s('vehicle.field.make'),
                hint: context.s('vehicle.hint.make'),
                controller: _make,
                marker: context.s('common.required'),
                errorText: _showErrors ? _makeError : null,
                onChanged: (_) => setState(() {}),
              ),
              second: ProtoField(
                label: context.s('vehicle.field.model'),
                hint: context.s('vehicle.hint.model'),
                controller: _model,
                marker: context.s('common.required'),
                errorText: _showErrors ? _modelError : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: ProtoSpace.s16),
            _ResponsiveFieldPair(
              first: ProtoField(
                label: context.s('vehicle.field.year'),
                hint: context.s('vehicle.hint.year'),
                controller: _year,
                marker: context.s('common.optional'),
                ltrContent: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                errorText: _showErrors ? _yearError : null,
                onChanged: (_) => setState(() {}),
              ),
              second: ProtoField(
                label: context.s('vehicle.field.colour'),
                hint: context.s('vehicle.hint.colour'),
                controller: _colour,
                marker: context.s('common.optional'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: ProtoSpace.s16),
            ProtoField(
              label: context.s('vehicle.field.mileage'),
              hint: context.s('vehicle.hint.mileage'),
              controller: _mileage,
              marker: context.s('common.optional'),
              ltrContent: true,
              keyboardType: TextInputType.number,
              suffix: Text(
                context.s('vehicle.unit.km'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: ProtoSpace.s16),
            ProtoField(
              label: context.s('vehicle.field.vin'),
              hint: context.s('vehicle.hint.vin'),
              icon: Icons.tag_rounded,
              controller: _vin,
              marker: context.s('common.optional'),
              ltrContent: true,
              helperText: context.s('vehicle.helper.vin'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        const SizedBox(height: ProtoSpace.s16),
        _FormSection(
          title: context.s('vehicle.section.ownership'),
          subtitle: context.s('vehicle.section.ownershipSub'),
          children: [
            ProtoField(
              label: context.s('vehicle.field.owner'),
              hint: context.s('vehicle.hint.owner'),
              icon: Icons.person_outline_rounded,
              controller: _owner,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: ProtoSpace.s16),
            ProtoField(
              label: context.s('vehicle.field.phone'),
              hint: context.s('vehicle.hint.phone'),
              icon: Icons.call_outlined,
              controller: _phone,
              ltrContent: true,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        const SizedBox(height: ProtoSpace.s16),
        _FormSection(
          title: context.s('vehicle.section.notes'),
          subtitle: context.s('vehicle.section.notesSub'),
          children: [
            ProtoField(
              label: context.s('vehicle.field.notes'),
              hint: context.s('vehicle.hint.notes'),
              controller: _notes,
              marker: context.s('common.optional'),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ],
    );

    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        ProtoSpace.s16,
        ProtoSpace.s16,
        ProtoSpace.s16,
        ProtoSpace.actionBarClearance,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: form),
                    const SizedBox(width: ProtoSpace.s20),
                    SizedBox(width: 280, child: _SummaryPanel(state: this)),
                  ],
                )
              : form,
        ),
      ),
    );

    return Column(
      children: [
        ProtoTopBar(
          title: context.s('vehicle.title'),
          onBack: _confirmDiscard,
          actions: [
            Tooltip(
              message: context.s('vehicle.discard.leave'),
              child: IconButton(
                onPressed: _confirmDiscard,
                icon: Icon(Icons.close_rounded, size: 20, color: p.textMuted),
              ),
            ),
          ],
        ),
        Expanded(child: body),
        _StickySaveBar(
          saving: _savingState,
          onCancel: _confirmDiscard,
          onSave: _save,
        ),
      ],
    );
  }
}

/// Two fields side-by-side on tablet+ but stacked on phones, so hints and
/// values keep their full width at 320–430 px (spec §12 form rhythm).
class _ResponsiveFieldPair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsiveFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    if (context.windowClass.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, const SizedBox(height: ProtoSpace.s16), second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: ProtoSpace.s12),
        Expanded(child: second),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _FormSection({required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.isRtl ? title : title.toUpperCase(),
            style: types.eyebrow.copyWith(color: p.textMuted, letterSpacing: context.isRtl ? 0 : 0.6),
          ),
          const SizedBox(height: ProtoSpace.s4),
          Text(subtitle, style: types.bodySmall.copyWith(color: p.textMuted, height: 1.45)),
          const SizedBox(height: ProtoSpace.s16),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final _AddVehiclePrototypeState state;

  const _SummaryPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final make = state._make.text.trim();
    final model = state._model.text.trim();
    final plate = state._plate.text.trim();
    final owner = state._owner.text.trim();
    final empty = make.isEmpty && model.isEmpty && plate.isEmpty && owner.isEmpty;

    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.s('vehicle.summary.title'),
            style: types.cardTitle.copyWith(color: p.textPrimary),
          ),
          const SizedBox(height: ProtoSpace.s12),
          if (empty)
            Text(
              context.s('vehicle.summary.empty'),
              style: types.caption.copyWith(color: p.textMuted),
            )
          else ...[
            if (plate.isNotEmpty) ...[
              Align(alignment: AlignmentDirectional.centerStart, child: ProtoPlateChip(plate: plate)),
              const SizedBox(height: ProtoSpace.s12),
            ],
            if (make.isNotEmpty || model.isNotEmpty)
              ProtoKeyValueRow(
                label: context.s('vehicle.summary.vehicle'),
                value: '$make $model'.trim(),
              ),
            if (owner.isNotEmpty)
              ProtoKeyValueRow(label: context.s('vehicle.summary.owner'), value: owner),
            if (state._year.text.trim().isNotEmpty)
              ProtoKeyValueRow(
                label: context.s('vehicle.field.year'),
                value: state._year.text.trim(),
              ),
          ],
          const SizedBox(height: ProtoSpace.s12),
          Divider(height: 1, color: p.borderSubtle),
          const SizedBox(height: ProtoSpace.s10),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: p.textMuted),
              const SizedBox(width: ProtoSpace.s6),
              Expanded(
                child: Text(
                  context.s('vehicle.sticky.hint'),
                  style: types.caption.copyWith(color: p.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickySaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _StickySaveBar({required this.saving, required this.onCancel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.borderDefault)),
        boxShadow: ProtoElevation.surface,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ProtoSpace.s16, ProtoSpace.s10, ProtoSpace.s16, ProtoSpace.s10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : onCancel,
                  child: Text(context.s('vehicle.action.cancel')),
                ),
              ),
              const SizedBox(width: ProtoSpace.s12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            // Visible against the disabled (sunken) fill.
                            valueColor: AlwaysStoppedAnimation(p.textDisabled),
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    saving ? context.s('vehicle.action.saving') : context.s('vehicle.action.save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
