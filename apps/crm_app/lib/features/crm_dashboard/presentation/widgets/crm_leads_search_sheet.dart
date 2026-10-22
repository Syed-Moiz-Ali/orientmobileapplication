// List-scoped leads search (CRM leads list).
//
// Presentation only: filters the already-loaded leads by name, lead number,
// phone or email substring (case-insensitive). No new routes, no server
// queries, no invented entries. Result taps close the sheet and reveal the
// record; record actions stay on the record itself.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

Future<void> showCrmLeadsSearchSheet(
  BuildContext context, {
  required List<CrmLeadEntity> leads,
  required ValueChanged<CrmLeadEntity> onSelect,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.leadsSearchTitle,
    builder: (_) => _LeadsSearchSheet(leads: leads, onSelect: onSelect),
  );
}

class _LeadsSearchSheet extends StatefulWidget {
  final List<CrmLeadEntity> leads;
  final ValueChanged<CrmLeadEntity> onSelect;

  const _LeadsSearchSheet({required this.leads, required this.onSelect});

  @override
  State<_LeadsSearchSheet> createState() => _LeadsSearchSheetState();
}

class _LeadsSearchSheetState extends State<_LeadsSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<CrmLeadEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.leads;
    return widget.leads.where((lead) {
      return lead.customerName.toLowerCase().contains(q) ||
          lead.leadNumber.toLowerCase().contains(q) ||
          lead.phone.toLowerCase().contains(q) ||
          lead.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.leadsSearch,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.leadsSearchNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                        child: Text(t.leadsFilterClear),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (rowContext, index) {
                    final lead = results[index];
                    final name = lead.customerName.isEmpty ? lead.leadNumber : lead.customerName;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(rowContext).pop();
                        widget.onSelect(lead);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s10),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                lead.phone.isEmpty ? lead.email : lead.phone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
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
      ],
    );
  }
}
