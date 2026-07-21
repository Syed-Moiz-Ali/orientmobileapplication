import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_providers.dart';

class JobStatusView extends ConsumerStatefulWidget {
  const JobStatusView({super.key});
  @override
  ConsumerState<JobStatusView> createState() => _JobStatusViewState();
}

class _JobStatusViewState extends ConsumerState<JobStatusView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobStatusProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.gray700), onPressed: () => context.pop()),
        title: const Text('Job Status Tracking', style: TextStyle(color: AppColors.gray900, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.gray700), onPressed: () {}))],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Container(height: 42, decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(AppDimensions.r8)), child: TextField(onChanged: (q) => ref.read(jobStatusProvider.notifier).onSearch(q), style: const TextStyle(fontSize: 14), decoration: const InputDecoration(hintText: 'Search job cards...', hintStyle: TextStyle(color: AppColors.gray400, fontSize: 13), prefixIcon: Icon(Icons.search, color: AppColors.gray400, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12))))),
              _FilterStrip(currentStage: state.filterStage, onFilter: (s) => ref.read(jobStatusProvider.notifier).setFilter(s)),
              Expanded(child: ListView.separated(itemCount: state.filtered.length, separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.gray200), itemBuilder: (_, i) => _JobStatusItem(job: state.filtered[i]))),
            ]),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  final JobStage? currentStage;
  final void Function(JobStage?) onFilter;
  const _FilterStrip({required this.currentStage, required this.onFilter});
  @override
  Widget build(BuildContext context) => SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
    _FilterChip(label: 'All', selected: currentStage == null, onTap: () => onFilter(null)),
    _FilterChip(label: 'Inspection', selected: currentStage == JobStage.waitingInspection, onTap: () => onFilter(JobStage.waitingInspection)),
    _FilterChip(label: 'Pre-Request', selected: currentStage == JobStage.waitingPreRequest, onTap: () => onFilter(JobStage.waitingPreRequest)),
    _FilterChip(label: 'Estimation', selected: currentStage == JobStage.waitingEstimation, onTap: () => onFilter(JobStage.waitingEstimation)),
    _FilterChip(label: 'Approval', selected: currentStage == JobStage.waitingApproval, onTap: () => onFilter(JobStage.waitingApproval)),
    _FilterChip(label: 'Parts', selected: currentStage == JobStage.waitingParts, onTap: () => onFilter(JobStage.waitingParts)),
    _FilterChip(label: 'WIP', selected: currentStage == JobStage.wip, onTap: () => onFilter(JobStage.wip)),
    _FilterChip(label: 'Completed', selected: currentStage == JobStage.completed, onTap: () => onFilter(JobStage.completed)),
    _FilterChip(label: 'Cancelled', selected: currentStage == JobStage.cancelled, onTap: () => onFilter(JobStage.cancelled)),
  ]));
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.gray100, borderRadius: BorderRadius.circular(AppDimensions.r16)), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.gray500)))));
}

class _JobStatusItem extends StatelessWidget {
  final JobStatus job;
  const _JobStatusItem({required this.job});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Text(job.jobCardId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900)), const Spacer(), _StatusLabel(stage: job.stage)]),
    const SizedBox(height: 4), Text(job.customerName, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
    const SizedBox(height: 2), Text('${job.vehicleInfo} • ${job.assignedTo}', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
    const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.r4), child: LinearProgressIndicator(value: _progress(job.stage), minHeight: 4, backgroundColor: AppColors.gray200, valueColor: AlwaysStoppedAnimation(_progressColor(job.stage)))),
  ]));
  double _progress(JobStage s) => switch (s) { JobStage.waitingInspection => 0.1, JobStage.waitingPreRequest => 0.2, JobStage.waitingEstimation => 0.3, JobStage.waitingApproval => 0.4, JobStage.waitingParts => 0.5, JobStage.wip => 0.6, JobStage.completed => 0.8, JobStage.invoice => 0.9, JobStage.gatePassOut => 1.0, JobStage.cancelled => 0.0 };
  Color _progressColor(JobStage s) => switch (s) { JobStage.completed || JobStage.invoice || JobStage.gatePassOut => AppColors.success, JobStage.cancelled => AppColors.danger, _ => AppColors.primary };
}

class _StatusLabel extends StatelessWidget {
  final JobStage stage;
  const _StatusLabel({required this.stage});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _color(stage).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimensions.r4)), child: Text(_label(stage), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _color(stage))));
  String _label(JobStage s) => switch (s) { JobStage.waitingInspection => 'Inspection', JobStage.waitingPreRequest => 'Pre-Request', JobStage.waitingEstimation => 'Estimation', JobStage.waitingApproval => 'Approval', JobStage.waitingParts => 'Parts', JobStage.wip => 'WIP', JobStage.completed => 'Completed', JobStage.invoice => 'Invoice', JobStage.gatePassOut => 'Gate Pass', JobStage.cancelled => 'Cancelled' };
  Color _color(JobStage s) => switch (s) { JobStage.completed || JobStage.invoice || JobStage.gatePassOut => AppColors.success, JobStage.cancelled => AppColors.danger, JobStage.wip => AppColors.primary, _ => AppColors.warning };
}
