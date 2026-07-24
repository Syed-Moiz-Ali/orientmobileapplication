import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';

class JobCardDetailView extends ConsumerWidget {
  const JobCardDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobCard = ref.watch(selectedJobCardProvider);
    if (jobCard == null) return const Scaffold(body: Center(child: Text('No job card selected')));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18), onPressed: () => context.pop()),
        title: Text(jobCard.id, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 22), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeaderCard(jobCard),
          const SizedBox(height: 14),
          _buildSection(title: 'Services', icon: Icons.build_outlined, child: Column(children: jobCard.services.map((s) => _ServiceRow(service: s)).toList())),
          const SizedBox(height: 14),
          _buildSection(title: 'Job Details', icon: Icons.info_outline, child: Column(children: [
            _DetailRow(label: 'Technician', value: jobCard.technician),
            const Divider(height: 20, color: AppColors.line),
            _DetailRow(label: 'Est. Completion', value: jobCard.estCompletion),
            const Divider(height: 20, color: AppColors.line),
            _DetailRow(label: 'Status', value: _statusLabel(jobCard.status), valueColor: _statusColor(jobCard.status)),
          ])),
          const SizedBox(height: 14),
          _buildSection(title: 'Amount', icon: Icons.attach_money, child: Row(children: [
            const Text('Total', style: TextStyle(fontSize: 13, color: AppColors.text3)),
            const Spacer(),
            Text(_formatAmount(jobCard.amount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ])),
          const SizedBox(height: 24),
          _buildActions(context),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildHeaderCard(JobCard jc) {
    final color = _statusColor(jc.status);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.r12), border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(jc.customerName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          Container(padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12, vertical: 5), decoration: BoxDecoration(color: _statusBg(jc.status), borderRadius: BorderRadius.circular(AppDimensions.r20)),
            child: Text(_statusLabel(jc.status), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
        ]),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.text3), const SizedBox(width: 4),
          Text(jc.vehicleDisplay, style: const TextStyle(fontSize: 13, color: AppColors.text3))]),
      ]),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(padding: const EdgeInsets.all(AppDimensions.s16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: AppColors.border, width: 0.8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 16, color: AppColors.primary), const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text2))]),
        const SizedBox(height: 12), const Divider(height: 1, color: AppColors.line), const SizedBox(height: 12), child,
      ]),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(children: [
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle_outline, size: 18),
        label: const Text('Mark as Complete'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r10)), elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)))),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.print_outlined, size: 16), label: const Text('Print'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r10)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Share'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.text3, side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r10)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))),
      ]),
    ]);
  }

  String _formatAmount(double amount) {
    final s = amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return 'AED $s';
  }

  Color _statusColor(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => AppColors.primary, JobCardStatus.waitingParts => AppColors.warning,
    JobCardStatus.qualityCheck => AppColors.info, JobCardStatus.completed => AppColors.success,
    JobCardStatus.cancelled => AppColors.danger, JobCardStatus.pendingApproval => AppColors.warning,
  };

  Color _statusBg(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => AppColors.primaryBg, JobCardStatus.waitingParts => AppColors.warningBg,
    JobCardStatus.qualityCheck => AppColors.infoBg, JobCardStatus.completed => AppColors.successBg,
    JobCardStatus.cancelled => AppColors.dangerBg, JobCardStatus.pendingApproval => AppColors.warningBg,
  };

  String _statusLabel(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => 'In Progress', JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'Quality Check', JobCardStatus.completed => 'Completed',
    JobCardStatus.cancelled => 'Cancelled', JobCardStatus.pendingApproval => 'Pending Approval',
  };
}

class _ServiceRow extends StatelessWidget {
  final String service;
  const _ServiceRow({required this.service});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)), const SizedBox(width: 10),
    Text(service, style: const TextStyle(fontSize: 13, color: AppColors.text2)),
  ]));
}

class _DetailRow extends StatelessWidget {
  final String label; final String value; final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text3)), const Spacer(),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
  ]);
}
