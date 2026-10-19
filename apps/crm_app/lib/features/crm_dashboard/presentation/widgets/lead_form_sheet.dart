import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

/// Lead create/edit sheet with instant lookup (source + team assignee
/// dropdowns) and phone handling through the canonical [PhoneNumber] value
/// object: a present phone must parse as a UAE mobile (inline error
/// otherwise) and is saved in canonical display format. Empty phone stays
/// empty — the name rule is unchanged.
class LeadFormSheet extends ConsumerStatefulWidget {
  final CrmLeadEntity? lead;
  const LeadFormSheet({super.key, this.lead});

  static Future<void> show(BuildContext context, {CrmLeadEntity? lead}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LeadFormSheet(lead: lead),
    );
  }

  @override
  ConsumerState<LeadFormSheet> createState() => _LeadFormSheetState();
}

class _LeadFormSheetState extends ConsumerState<LeadFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _assignCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _followUpCtrl;
  late final TextEditingController _notesCtrl;
  late String _status;
  bool _busy = false;
  String? _error;

  static const _statuses = ['ACTIVE', 'WON', 'LOST', 'UNANSWERED', 'NO_RESPONSE'];
  static const _sources = ['META', 'ZOHO', 'WhatsApp', 'Instagram', 'Google Ads', 'Website', 'Referral', 'Manual'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.lead?.customerName ?? '');
    _phoneCtrl = TextEditingController(text: widget.lead?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.lead?.email ?? '');
    _sourceCtrl = TextEditingController(text: widget.lead?.source ?? '');
    _assignCtrl = TextEditingController(text: widget.lead?.assignedTo ?? '');
    _valueCtrl = TextEditingController(text: widget.lead != null && widget.lead!.leadValue > 0 ? widget.lead!.leadValue.toStringAsFixed(0) : '');
    _followUpCtrl = TextEditingController(text: widget.lead?.followUpDate ?? '');
    _notesCtrl = TextEditingController(text: widget.lead?.notes ?? '');
    _status = widget.lead?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _sourceCtrl.dispose();
    _assignCtrl.dispose();
    _valueCtrl.dispose();
    _followUpCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final isEdit = widget.lead != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CrmColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEdit ? t.fmEditLead : t.fmAddLead,
              style: const TextStyle(
                color: CrmColors.textH,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _field(t.fmName, _nameCtrl, Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _field(
              t.fmPhone,
              _phoneCtrl,
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
              hint: t.fmPhoneHint,
              ltr: true,
            ),
            const SizedBox(height: 12),
            _field(t.fmEmail, _emailCtrl, Icons.email_outlined, keyboard: TextInputType.emailAddress, ltr: true),
            const SizedBox(height: 12),
            _dropdownField(t.fmSource, _sourceCtrl, _sources, t.fmSelectOption(t.fmSource)),
            const SizedBox(height: 12),
            _assigneeDropdown(),
            const SizedBox(height: 12),
            _field(t.fmValue, _valueCtrl, Icons.payments_outlined, keyboard: TextInputType.number, ltr: true),
            const SizedBox(height: 12),
            // FIX (audit P2): follow-up date was free text ("tomorrow",
            // "12/25") — no picker, no sortable/overdue logic. Now a real
            // date picker writing ISO-8601.
            _followUpField(),
            const SizedBox(height: 12),
            _notesField(),
            _statusLabel(t.fmStatus),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _statuses.map((s) {
                final sel = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? CrmColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? CrmColors.primary : CrmColors.border,
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: sel ? Colors.white : CrmColors.textB,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CrmColors.redBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: CrmColors.red, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const ValueKey('leadSaveButton'),
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(isEdit ? Icons.save_outlined : Icons.add_rounded, size: 18),
                label: Text(_busy ? t.fmSaving : (isEdit ? t.fmSaveChanges : t.fmAddLead)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CrmColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboard, String? hint, bool ltr = false}) {
    final field = TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(color: CrmColors.textH, fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 17, color: CrmColors.textM),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CrmColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CrmColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CrmColors.primary, width: 1.5),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (ltr)
          Directionality(textDirection: TextDirection.ltr, child: field)
        else
          field,
      ],
    );
  }

  Widget _dropdownField(String label, TextEditingController ctrl, List<String> options, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CrmColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(ctrl.text) ? ctrl.text : null,
              hint: Text(ctrl.text.isEmpty ? hint : ctrl.text, style: const TextStyle(color: CrmColors.textM, fontSize: 13)),
              dropdownColor: Colors.white,
              style: const TextStyle(color: CrmColors.textH, fontSize: 13),
              isExpanded: true,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) => setState(() => ctrl.text = v ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusLabel(String text) => Text(
    text,
    style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700),
  );

  Widget _assigneeDropdown() {
    final t = context.cx;
    final teamAsync = ref.watch(teamMembersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.fmAssigned, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        teamAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CrmColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Text(t.fmLoadingTeam, style: const TextStyle(color: CrmColors.textM, fontSize: 13)),
              ],
            ),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CrmColors.redBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(t.fmTeamFail, style: const TextStyle(color: CrmColors.red, fontSize: 12)),
          ),
          data: (members) {
            final options = [...members.map((m) => m.name), t.fmUnassigned];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CrmColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: options.contains(_assignCtrl.text) ? _assignCtrl.text : null,
                  hint: Text(
                    _assignCtrl.text.isEmpty ? t.fmSelectAssignee : _assignCtrl.text,
                    style: const TextStyle(color: CrmColors.textM, fontSize: 13),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: CrmColors.textH, fontSize: 13),
                  isExpanded: true,
                  items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) => setState(() => _assignCtrl.text = v ?? ''),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _followUpField() {
    final t = context.cx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.fmFollowUp, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(_followUpCtrl.text) ?? now.add(const Duration(days: 7)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 365 * 2)),
            );
            if (picked != null) {
              setState(() {
                _followUpCtrl.text = picked.toIso8601String().substring(0, 10);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CrmColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_outlined, size: 18, color: CrmColors.textM),
                const SizedBox(width: 10),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _followUpCtrl.text.isEmpty ? t.fmSelectDate : _followUpCtrl.text,
                      style: TextStyle(
                        color: _followUpCtrl.text.isEmpty ? CrmColors.textM : CrmColors.textH,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (_followUpCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _followUpCtrl.clear()),
                    child: const Icon(Icons.close_rounded, size: 16, color: CrmColors.textM),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesField() {
    final t = context.cx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.fmNotes, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          style: const TextStyle(color: CrmColors.textH, fontSize: 13),
          decoration: InputDecoration(
            hintText: t.fmNotesHint,
            hintStyle: const TextStyle(color: CrmColors.textM, fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CrmColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CrmColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CrmColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final t = context.cx;
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = t.fmNameRequired);
      return;
    }
    // A present phone must parse as a UAE mobile; empty stays empty.
    final rawPhone = _phoneCtrl.text.trim();
    PhoneNumber? parsed;
    if (rawPhone.isNotEmpty) {
      parsed = PhoneNumber.tryParse(rawPhone);
      if (parsed == null) {
        setState(() => _error = t.fmPhoneInvalid);
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final data = {
      'customerName': _nameCtrl.text.trim(),
      'phone': parsed?.format() ?? '',
      'email': _emailCtrl.text.trim(),
      'source': _sourceCtrl.text.trim().isEmpty ? 'Manual' : _sourceCtrl.text.trim(),
      'assignedTo': _assignCtrl.text.trim() == t.fmUnassigned || _assignCtrl.text.trim() == 'Unassigned' ? '' : _assignCtrl.text.trim(),
      'status': _status,
      'lastActivity': widget.lead?.lastActivity ?? 'Just now',
      'leadValue': double.tryParse(_valueCtrl.text.trim()) ?? 0,
      'followUpDate': _followUpCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };
    final notifier = ref.read(crmLeadProvider.notifier);
    if (widget.lead != null) {
      await notifier.updateLead(widget.lead!.id, data);
    } else {
      await notifier.createLead(data);
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.lead != null ? t.fmUpdated : t.fmCreated),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
