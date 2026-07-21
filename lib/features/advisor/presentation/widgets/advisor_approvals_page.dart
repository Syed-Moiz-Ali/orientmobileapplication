import 'package:flutter/material.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';
import 'advisor_approval_row.dart';
import 'advisor_see_all_button.dart';

class AdvisorApprovalsPage extends StatelessWidget {
  final List<PendingApprovalEntity> approvals;
  final void Function(PendingApprovalEntity) onTap;
  final VoidCallback onViewAll;
  const AdvisorApprovalsPage({
    super.key,
    required this.approvals,
    required this.onTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          itemCount: approvals.length,
          itemBuilder: (_, i) => AdvisorApprovalRow(pa: approvals[i], onTap: onTap),
        ),
      ),
      AdvisorSeeAllButton('View all approvals', onViewAll),
    ],
  );
}
