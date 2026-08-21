import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';

class JobCardDetailView extends ConsumerWidget {
  const JobCardDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final jobCard = ref.watch(selectedJobCardProvider);

    if (jobCard == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(backgroundColor: colorScheme.surface, elevation: 0),
        body: const Center(child: Text('No job card selected')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          jobCard.id,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            fontFamily: AppFontFamilies.mono,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: colorScheme.onSurface, size: 22),
            tooltip: 'Share job card',
            onPressed: () => _shareJobCard(jobCard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, jobCard, colorScheme, textTheme),
            const SizedBox(height: 14),
            _buildSection(
              context: context,
              title: 'Authorized Work & Services',
              icon: Icons.build_circle_rounded,
              child: Column(
                children: jobCard.services.map((s) => _ServiceRow(service: s)).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _buildSection(
              context: context,
              title: 'Workshop & Job Meta',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  _DetailRow(label: 'Assigned Specialist', value: jobCard.technician),
                  Divider(height: 20, color: colorScheme.outlineVariant),
                  _DetailRow(label: 'Est. Handover Time', value: jobCard.estCompletion),
                  Divider(height: 20, color: colorScheme.outlineVariant),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Stage',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      StatusPill(
                        label: _statusLabel(jobCard.status).toUpperCase(),
                        showDot: true,
                        bg: _statusBg(jobCard.status),
                        fg: _statusColor(jobCard.status),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(18),
              borderRadius: AppDimensions.r20,
              color: colorScheme.surface,
              borderColor: colorScheme.outlineVariant,
              child: Row(
                children: [
                  Text(
                    'Total Job Estimate',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'AED ${jobCard.amount.toStringAsFixed(2)}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildActions(context, ref, jobCard, colorScheme),
          ],
        ),
      ),
    );
  }

  Future<void> _shareJobCard(JobCard jc) async {
    final summary = '''
${jc.id}
Customer: ${jc.customerName}
Vehicle: ${jc.vehicleDisplay}
Services: ${jc.services.join(', ')}
Technician: ${jc.technician}
Est. Completion: ${jc.estCompletion}
Status: ${_statusLabel(jc.status)}
Amount: AED ${jc.amount.toStringAsFixed(2)}
''';
    await Share.share(summary, subject: 'Job Card ${jc.id}');
  }

  Widget _buildHeaderCard(BuildContext context, JobCard jc, ColorScheme colorScheme, TextTheme textTheme) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: AppDimensions.r24,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  jc.customerName,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              StatusPill(
                label: _statusLabel(jc.status).toUpperCase(),
                showDot: true,
                bg: _statusBg(jc.status),
                fg: _statusColor(jc.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.directions_car_outlined, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                jc.vehicleDisplay,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, JobCard jobCard, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () async {
              final ok = await ref
                  .read(jobCardsProvider.notifier)
                  .markComplete(jobCard.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Job card marked as completed'
                        : 'Could not complete the job card. Try again.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            label: const Text('Mark Job as Complete', style: TextStyle(fontWeight: FontWeight.w900)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareJobCard(jobCard),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Print / Export', style: TextStyle(fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareJobCard(jobCard),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share PDF', style: TextStyle(fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _statusColor(JobCardStatus s) => switch (s) {
        JobCardStatus.inProgress => const Color(0xFF3B82F6),
        JobCardStatus.waitingParts => const Color(0xFFD97706),
        JobCardStatus.qualityCheck => const Color(0xFF8B5CF6),
        JobCardStatus.completed => const Color(0xFF10B981),
        JobCardStatus.cancelled => const Color(0xFFEF4444),
        JobCardStatus.pendingApproval => const Color(0xFFD97706),
        JobCardStatus.pending => const Color(0xFFD97706),
        JobCardStatus.awaitingSupervisor => const Color(0xFFD97706),
        JobCardStatus.vehicleReceived => const Color(0xFF3B82F6),
        JobCardStatus.waitingCustomerApproval => const Color(0xFFD97706),
        JobCardStatus.delivered => const Color(0xFF10B981),
        JobCardStatus.qualityCheckPassed => const Color(0xFF10B981),
      };

  Color _statusBg(JobCardStatus s) => _statusColor(s).withValues(alpha: 0.12);

  String _statusLabel(JobCardStatus s) => switch (s) {
        JobCardStatus.inProgress => 'In Progress',
        JobCardStatus.waitingParts => 'Waiting Parts',
        JobCardStatus.qualityCheck => 'Quality Check',
        JobCardStatus.completed => 'Completed',
        JobCardStatus.cancelled => 'Cancelled',
        JobCardStatus.pendingApproval => 'Pending Approval',
        JobCardStatus.pending => 'Pending',
        JobCardStatus.awaitingSupervisor => 'Awaiting Supervisor',
        JobCardStatus.vehicleReceived => 'Vehicle Received',
        JobCardStatus.waitingCustomerApproval => 'Waiting Customer Approval',
        JobCardStatus.delivered => 'Delivered',
        JobCardStatus.qualityCheckPassed => 'QC Passed',
      };
}

class _ServiceRow extends StatelessWidget {
  final String service;
  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              service,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
