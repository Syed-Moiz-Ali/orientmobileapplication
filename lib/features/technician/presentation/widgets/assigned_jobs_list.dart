import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/technician/domain/entities/technician_entities.dart';
import 'package:orientmobileapplication/features/technician/providers/technician_providers.dart';
import 'package:orientmobileapplication/features/technician/presentation/widgets/section_card.dart';
import 'package:orientmobileapplication/features/technician/presentation/widgets/job_search_bar.dart';
import 'package:orientmobileapplication/features/technician/presentation/widgets/job_card_tile.dart';
import 'package:orientmobileapplication/features/technician/presentation/widgets/job_detail_sheet.dart';

class AssignedJobsList extends ConsumerWidget {
  const AssignedJobsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    return SectionCard(
      title: 'Assigned Jobs',
      icon: Icons.work_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JobSearchBar(
            onJobFound: () => _openDetail(context, ref, state.selectedJob!),
          ),
          SizedBox(height: AppDimensions.s14),
          ...state.assignedJobs.map((job) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.s10),
              child: JobCardTile(
                job: job,
                onStatusChanged: (s) =>
                    notifier.updateAssignedJobStatus(job.id, s),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openDetail(
      BuildContext context, WidgetRef ref, TechnicianJobEntity job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDetailSheet(job: job),
    ).whenComplete(() {
      ref.read(technicianDashboardProvider.notifier).closeJob();
    });
  }
}
