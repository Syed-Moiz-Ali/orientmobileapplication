import 'package:flutter/material.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'advisor_job_card_row.dart';
import 'advisor_see_all_button.dart';

class AdvisorJobCardsPage extends StatelessWidget {
  final List<JobCardEntity> jobCards;
  final void Function(JobCardEntity) onTap;
  final VoidCallback onViewAll;
  const AdvisorJobCardsPage({
    super.key,
    required this.jobCards,
    required this.onTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          itemCount: jobCards.length,
          itemBuilder: (_, i) => AdvisorJobCardRow(jc: jobCards[i], onTap: onTap),
        ),
      ),
      AdvisorSeeAllButton('View all job cards', onViewAll),
    ],
  );
}

