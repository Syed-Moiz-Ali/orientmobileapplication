import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart';

class LeadDetailSheet extends ConsumerStatefulWidget {
  final CrmLeadEntity lead;
  const LeadDetailSheet({super.key, required this.lead});

  static Future<void> show(BuildContext context, CrmLeadEntity lead) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LeadDetailSheet(lead: lead),
    );
  }

  @override
  ConsumerState<LeadDetailSheet> createState() => _LeadDetailSheetState();
}

class _LeadDetailSheetState extends ConsumerState<LeadDetailSheet> {
  bool _busy = false;
  List<LeadActivityEntity> _activities = [];

  static const _statuses = [
    ('ACTIVE', Icons.fiber_manual_record_rounded),
    ('WON', Icons.emoji_events_outlined),
    ('LOST', Icons.trending_down_rounded),
    ('UNANSWERED', Icons.mark_chat_unread_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final repo = ref.read(crmRepositoryProvider);
    final activities = await repo.getLeadActivities(widget.lead.id);
    if (!mounted) return;
    setState(() => _activities = activities);
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.customerName,
                        style: const TextStyle(
                          color: CrmColors.textH,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.leadNumber,
                        style: const TextStyle(color: CrmColors.textM, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => LeadFormSheet.show(context, lead: lead),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CrmColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 18, color: CrmColors.accent),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(lead),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CrmColors.redBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 18, color: CrmColors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.phone_outlined, 'Phone', lead.phone),
            _infoRow(Icons.email_outlined, 'Email', lead.email),
            _infoRow(Icons.track_changes_rounded, 'Source', lead.source),
            _infoRow(Icons.person_outline_rounded, 'Assigned to', lead.assignedTo.isEmpty ? 'Unassigned' : lead.assignedTo),
            if (lead.leadValue > 0)
              _infoRow(Icons.payments_outlined, 'Lead Value', 'AED ${lead.leadValue.toStringAsFixed(0)}'),
            if (lead.followUpDate.isNotEmpty)
              _infoRow(Icons.event_outlined, 'Follow-up', lead.followUpDate),
            _infoRow(Icons.access_time_rounded, 'Last activity', lead.lastActivity),
            if (lead.notes.isNotEmpty) ...[
              const Divider(height: 24, color: CrmColors.border),
              const Text(
                'Notes',
                style: TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CrmColors.accentLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  lead.notes,
                  style: const TextStyle(color: CrmColors.textB, fontSize: 12, height: 1.4),
                ),
              ),
            ],
            if (_activities.isNotEmpty) ...[
              const Divider(height: 28, color: CrmColors.border),
              const Text(
                'Activity History',
                style: TextStyle(color: CrmColors.textH, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._activities.map((a) => _activityRow(a)),
            ],
            const Divider(height: 28, color: CrmColors.border),
            const Text(
              'Change Status',
              style: TextStyle(color: CrmColors.textH, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((s) {
                final sel = lead.status.toUpperCase() == s.$1;
                return GestureDetector(
                  onTap: _busy ? null : () => _changeStatus(s.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? CrmColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? CrmColors.primary : CrmColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.$2, size: 13, color: sel ? Colors.white : CrmColors.textM),
                        const SizedBox(width: 6),
                        Text(
                          s.$1,
                          style: TextStyle(
                            color: sel ? Colors.white : CrmColors.textB,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_busy) ...[
              const SizedBox(height: 14),
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: CrmColors.accent),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: CrmColors.textM),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 12)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: CrmColors.textH,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(String status) async {
    if (status == widget.lead.status) return;
    setState(() => _busy = true);
    await ref.read(crmLeadProvider.notifier).updateLead(widget.lead.id, {
      'customerName': widget.lead.customerName,
      'phone': widget.lead.phone,
      'email': widget.lead.email,
      'source': widget.lead.source,
      'assignedTo': widget.lead.assignedTo,
      'status': status,
      'lastActivity': 'Status changed to $status',
      'notes': widget.lead.notes,
      'leadValue': widget.lead.leadValue,
      'followUpDate': widget.lead.followUpDate,
    });
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lead marked as $status'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _activityRow(LeadActivityEntity a) {
    final (icon, color) = switch (a.action) {
      'CREATED' || 'IMPORTED' => (Icons.add_circle_outline_rounded, CrmColors.green),
      'STATUS' => (Icons.swap_horiz_rounded, CrmColors.accent),
      'ASSIGNED' => (Icons.person_add_alt_1_rounded, CrmColors.amber),
      _ => (Icons.edit_outlined, CrmColors.textM),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.actionLabel,
                  style: const TextStyle(
                    color: CrmColors.textH,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (a.detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    a.detail,
                    style: const TextStyle(color: CrmColors.textB, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  a.createdAt,
                  style: const TextStyle(color: CrmColors.textM, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(CrmLeadEntity lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lead', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Delete ${lead.customerName} (${lead.leadNumber})? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: CrmColors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.pop(context);
    await ref.read(crmLeadProvider.notifier).deleteLead(lead.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lead deleted'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
